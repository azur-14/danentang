using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using OrderManagementService.Data;
using OrderManagementService.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace OrderManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly IMongoCollection<Order> _orders;
        private readonly IHttpClientFactory _httpClientFactory;

        public OrdersController(MongoDbContext context, IHttpClientFactory httpClientFactory)
        {
            _orders = context.Orders;
            _httpClientFactory = httpClientFactory;
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
            // Ensure server-side ID, timestamps
            ModelState.Remove(nameof(order.Id)); // Optional
            order.Id = ObjectId.GenerateNewId().ToString();
            order.CreatedAt = order.UpdatedAt = DateTime.UtcNow;

            // Validate inventory with ProductService
            var client = _httpClientFactory.CreateClient("ProductService");

            foreach (var item in order.Items)
            {
                var response = await client.GetAsync($"product-items/available/{item.ProductVariantId}");
                if (!response.IsSuccessStatusCode)
                    return BadRequest($"Không thể kiểm tra tồn kho của biến thể {item.ProductVariantId}");

                var json = await response.Content.ReadAsStringAsync();
                var availableItems = JsonSerializer.Deserialize<List<ProductItemDto>>(json);

                if (availableItems == null || availableItems.Count < item.Quantity)
                    return BadRequest($"Không đủ số lượng hàng tồn kho cho biến thể {item.ProductVariantId}");

                var selectedItems = availableItems.Take(item.Quantity).ToList();
                item.ProductItemIds = selectedItems.Select(i => i.Id).ToList();
            }

            // ✅ Tính điểm tích lũy dựa trên tổng tiền sau giảm
            var totalAfterDiscount = order.TotalAmount - order.DiscountAmount;
            order.LoyaltyPointsEarned = (int)(totalAfterDiscount / 10000); // ví dụ: 1 điểm / 10k

            await _orders.InsertOneAsync(order);
            return CreatedAtAction(nameof(Get), new { id = order.Id }, order);
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

    // Tạm dùng để deserialize từ ProductService
    public class ProductItemDto
    {
        public string Id { get; set; }
        public string ProductId { get; set; }
        public string VariantId { get; set; }
        public string Status { get; set; }
    }
}
