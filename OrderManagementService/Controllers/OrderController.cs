using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using OrderManagementService.Data;
using OrderManagementService.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net;
using System.Net.Mail;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Text;

namespace OrderManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly IMongoCollection<Order> _orders;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly IMongoCollection<Coupon> _coupons;

        public OrdersController(
    MongoDbContext context,
    IHttpClientFactory httpClientFactory,
    IConfiguration configuration)
        {
            _orders = context.Orders;
            _coupons = context.Coupons;  // THÊM DÒNG NÀY
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
        }


        // GET: api/orders
        [HttpGet]
        public async Task<ActionResult<List<Order>>> GetAll() =>
            await _orders.Find(_ => true).ToListAsync();

        // GET: api/orders/{id}
        [HttpGet("{id:length(24)}")]
        public async Task<ActionResult<Order>> Get(string id)
        {
            var order = await _orders.Find(o => o.Id == id).FirstOrDefaultAsync();
            if (order == null) return NotFound();
            return order;
        }

        // POST: api/orders
        [HttpPost]
        public async Task<ActionResult<Order>> Create([FromBody] Order order)
        {
            order.Id = ObjectId.GenerateNewId().ToString();
            order.CreatedAt = order.UpdatedAt = DateTime.UtcNow;

            // Cho phép UserId = null (khách vãng lai)
            if (string.IsNullOrEmpty(order.UserId))
                order.UserId = null;

            // Kiểm tra thông tin địa chỉ giao hàng (bắt buộc có email)
            if (order.ShippingAddress == null ||
                string.IsNullOrEmpty(order.ShippingAddress.ReceiverName) ||
                string.IsNullOrEmpty(order.ShippingAddress.PhoneNumber) ||
                string.IsNullOrEmpty(order.ShippingAddress.AddressLine) ||
                string.IsNullOrEmpty(order.ShippingAddress.Email))
            {
                return BadRequest("Địa chỉ giao hàng không hợp lệ!");
            }

            // Đảm bảo luôn có shippingFee (nếu không gửi lên thì mặc định 30000)
            if (order.ShippingFee <= 0) order.ShippingFee = 30000;

            // Kiểm tra tồn kho từng biến thể
            var client = _httpClientFactory.CreateClient("ProductService");
            foreach (var item in order.Items)
            {
                var response = await client.GetAsync($"products/variants/{item.ProductVariantId}");
                if (!response.IsSuccessStatusCode)
                    return BadRequest($"Không thể kiểm tra tồn kho của biến thể {item.ProductVariantId}");
                Console.WriteLine($"Gọi tới ProductService: products/variants/{item.ProductVariantId}");

                var json = await response.Content.ReadAsStringAsync();
                var variantDto = JsonSerializer.Deserialize<ProductVariantDto>(json);
                if (variantDto == null)
                    return BadRequest($"Không lấy được thông tin biến thể {item.ProductVariantId}");

                int availableInventory = variantDto.Inventory;
                Console.WriteLine($"VariantId: {item.ProductVariantId}, Inventory: {variantDto.Inventory}, Request: {item.Quantity}");

                if (availableInventory < item.Quantity)
                    return BadRequest($"Không đủ số lượng hàng tồn kho cho biến thể {item.ProductVariantId}");
            }

            // Tính điểm tích lũy (10k = 1 điểm)
            var totalAfterDiscount = order.TotalAmount - order.DiscountAmount;
            order.LoyaltyPointsEarned = (int)(totalAfterDiscount / 10000);

            try
            {
                await _orders.InsertOneAsync(order);

                // 1. Cộng lượt dùng coupon
                if (!string.IsNullOrEmpty(order.CouponCode))
                {
                    var filter = Builders<Coupon>.Filter.Eq(c => c.Code, order.CouponCode);
                    var update = Builders<Coupon>.Update
                        .Inc(c => c.UsageCount, 1)
                        .AddToSet(c => c.OrderIds, order.Id);
                    await _coupons.UpdateOneAsync(filter, update);
                }

                // 2. Trừ điểm loyalty nếu có
                if (!string.IsNullOrEmpty(order.UserId) && order.LoyaltyPointsUsed > 0)
                {
                    var userClient = _httpClientFactory.CreateClient();
                    userClient.BaseAddress = new Uri(_configuration["UserServiceUrl"] ?? "http://localhost:5012");
                    var patchBody = new { LoyaltyPointsDelta = -order.LoyaltyPointsUsed };
                    var jsonContent = new StringContent(JsonSerializer.Serialize(patchBody), Encoding.UTF8, "application/json");
                    var res = await userClient.PatchAsync($"/api/user/{order.UserId}/loyalty", jsonContent);

                    if (!res.IsSuccessStatusCode)
                    {
                        Console.WriteLine("Trừ điểm loyalty thất bại: " + await res.Content.ReadAsStringAsync());
                    }
                }
                foreach (var item in order.Items)
                {
                    var jsonContent = new StringContent(item.Quantity.ToString(), Encoding.UTF8, "application/json");
                    var res = await client.PatchAsync($"products/variants/{item.ProductVariantId}/decrease", jsonContent);

                    if (!res.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"Trừ kho thất bại cho biến thể {item.ProductVariantId}: {await res.Content.ReadAsStringAsync()}");
                        // Optional: rollback hoặc thông báo admin
                    }
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi lưu database: " + ex.Message);
                return StatusCode(500, "Lỗi lưu vào MongoDB: " + ex.Message);
            }


            // Gửi email xác nhận đơn hàng
            try
            {
                var receiverEmail = order.ShippingAddress.Email;
                var mailSubject = $"Xác nhận đơn hàng #{order.OrderNumber}";
                var mailBody = $@"
<b>Cảm ơn bạn đã đặt hàng tại Hoalahe!</b><br>
Người nhận: {order.ShippingAddress.ReceiverName}<br>
SĐT: {order.ShippingAddress.PhoneNumber}<br>
Địa chỉ: {order.ShippingAddress.AddressLine}, {order.ShippingAddress.Ward}, {order.ShippingAddress.District}, {order.ShippingAddress.City}<br>
<b>Danh sách sản phẩm:</b>
<ul>
{string.Join("", order.Items.Select(i => $"<li>{i.ProductName} ({i.VariantName}) x{i.Quantity}: {i.Price:N0}đ</li>"))}
</ul>
<b>Phí vận chuyển:</b> {order.ShippingFee:N0}đ<br>
<b>Tổng cộng:</b> {order.TotalAmount:N0}đ<br>
<b>Giảm giá:</b> {order.DiscountAmount:N0}đ<br>
<b>Điểm thưởng tích lũy:</b> {order.LoyaltyPointsEarned} điểm<br>
<b>Trạng thái đơn hàng:</b> {order.Status}
";
                await SendEmailAsync(receiverEmail, mailSubject, mailBody);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi gửi mail xác nhận đơn hàng: " + ex.Message);
                // Không return lỗi gửi mail để không ảnh hưởng đến lưu đơn hàng
            }

            return CreatedAtAction(nameof(Get), new { id = order.Id }, order);
        }

        /// <summary>
        /// Gửi mail xác nhận đơn hàng qua SMTP Gmail.
        /// </summary>
        private async Task SendEmailAsync(string toEmail, string subject, string htmlBody)
        {
            var smtpHost = _configuration["Smtp:Host"]!;
            var smtpPort = int.Parse(_configuration["Smtp:Port"]!);
            var smtpUser = _configuration["Smtp:Username"]!;
            var smtpPass = _configuration["Smtp:Password"]!;
            var fromEmail = _configuration["Smtp:FromEmail"]!;

            var mail = new MailMessage();
            mail.From = new MailAddress(fromEmail, "Hoalahe");
            mail.To.Add(toEmail);
            mail.Subject = subject;
            mail.Body = htmlBody;
            mail.IsBodyHtml = true;

            using var client = new SmtpClient(smtpHost, smtpPort)
            {
                Credentials = new NetworkCredential(smtpUser, smtpPass),
                EnableSsl = true
            };
            await client.SendMailAsync(mail);
        }
        // GET: api/orders/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<Order>>> GetOrdersByUserId(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
                return BadRequest("userId is required.");

            var orders = await _orders.Find(o => o.UserId == userId)
                                      .SortByDescending(o => o.CreatedAt)
                                      .ToListAsync();

            return Ok(orders);
        }

        // PUT: api/orders/{id}
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] Order updated)
        {
            updated.Id = id;
            updated.UpdatedAt = DateTime.UtcNow;

            var result = await _orders.ReplaceOneAsync(o => o.Id == id, updated);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // DELETE: api/orders/{id}
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _orders.DeleteOneAsync(o => o.Id == id);
            if (result.DeletedCount == 0) return NotFound();
            return NoContent();
        }

        // PATCH: api/orders/{id}/status
        [HttpPatch("{id:length(24)}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] OrderStatusHistory history)
        {
            var update = Builders<Order>.Update
                .Set(o => o.Status, history.Status)
                .Push(o => o.StatusHistory, history)
                .CurrentDate(o => o.UpdatedAt);

            var result = await _orders.UpdateOneAsync(o => o.Id == id, update);
            if (result.MatchedCount == 0) return NotFound();

            // Nếu đơn hàng được xác nhận (ví dụ: status == "confirmed")
            if (history.Status.ToLower() == "confirmed")
            {
                var order = await _orders.Find(o => o.Id == id).FirstOrDefaultAsync();
                if (order != null)
                {
                    var client = _httpClientFactory.CreateClient("ProductService");
                    foreach (var item in order.Items)
                    {
                        foreach (var productItemId in item.ProductItemIds)
                        {
                            var patchResp = await client.PatchAsync(
                                $"product-items/{productItemId}/status",
                                new StringContent("\"sold\"", System.Text.Encoding.UTF8, "application/json")
                            );

                            if (!patchResp.IsSuccessStatusCode)
                            {
                                return BadRequest($"Không thể cập nhật trạng thái sản phẩm {productItemId}");
                            }
                        }
                    }
                }
            }
            return NoContent();
        }
    }

    // Dùng cho kiểm tra tồn kho variant
    public class ProductVariantDto
    {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("variantName")]
        public string VariantName { get; set; }

        [JsonPropertyName("additionalPrice")]
        public decimal AdditionalPrice { get; set; }

        [JsonPropertyName("inventory")]
        public int Inventory { get; set; }
    }
}
