using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using OrderService.Models;

namespace OrderService.Controllers
{
    [ApiController]
    [Route("api/orders")]
    public class OrderController : ControllerBase
    {
        private readonly IMongoCollection<Order> _orders;
        private readonly IMongoCollection<Cart> _carts;
        private readonly IMongoCollection<Coupon> _coupons;

        public OrderController(IMongoDatabase db)
        {
            _orders = db.GetCollection<Order>("orders");
            _carts = db.GetCollection<Cart>("carts");
            _coupons = db.GetCollection<Coupon>("coupons");
        }

        // ✅ Tạo đơn hàng
        [HttpPost("place")]
        public async Task<IActionResult> PlaceOrder([FromBody] Order newOrder)
        {
            // Validate coupon
            if (!string.IsNullOrEmpty(newOrder.CouponCode))
            {
                var coupon = await _coupons.Find(c => c.Code == newOrder.CouponCode).FirstOrDefaultAsync();
                if (coupon == null || coupon.UsageCount >= coupon.UsageLimit)
                    return BadRequest("Invalid or expired coupon.");

                // Trừ lượt dùng
                var update = Builders<Coupon>.Update.Inc(c => c.UsageCount, 1);
                await _coupons.UpdateOneAsync(c => c.Id == coupon.Id, update);
            }

            // Gắn thêm thời gian tạo, mã đơn, status
            newOrder.OrderNumber = "ODR" + DateTime.UtcNow.Ticks;
            newOrder.CreatedAt = DateTime.UtcNow;
            newOrder.UpdatedAt = DateTime.UtcNow;
            newOrder.Status = "pending";
            newOrder.StatusHistory = new List<OrderStatusHistory> {
                new OrderStatusHistory { Status = "pending", Timestamp = DateTime.UtcNow }
            };

            await _orders.InsertOneAsync(newOrder);

            // Xoá giỏ hàng sau khi đặt hàng thành công
            await _carts.DeleteOneAsync(c => c.UserId == newOrder.UserId);

            return Ok(new { message = "Order placed successfully", orderId = newOrder.Id });
        }

        // ✅ Lấy danh sách đơn theo user
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetOrdersByUser(string userId)
        {
            var orders = await _orders.Find(o => o.UserId == userId)
                                      .SortByDescending(o => o.CreatedAt)
                                      .ToListAsync();
            return Ok(orders);
        }

        // ✅ Xem chi tiết đơn hàng
        [HttpGet("{orderId}")]
        public async Task<IActionResult> GetOrderById(string orderId)
        {
            var order = await _orders.Find(o => o.Id == orderId).FirstOrDefaultAsync();
            if (order == null) return NotFound("Order not found.");
            return Ok(order);
        }

        // ✅ Admin cập nhật trạng thái đơn
        [HttpPut("{orderId}/status")]
        public async Task<IActionResult> UpdateOrderStatus(string orderId, [FromBody] string newStatus)
        {
            var order = await _orders.Find(o => o.Id == orderId).FirstOrDefaultAsync();
            if (order == null) return NotFound("Order not found.");

            order.Status = newStatus;
            order.StatusHistory.Add(new OrderStatusHistory
            {
                Status = newStatus,
                Timestamp = DateTime.UtcNow
            });
            order.UpdatedAt = DateTime.UtcNow;

            var result = await _orders.ReplaceOneAsync(o => o.Id == orderId, order);
            return Ok(new { message = "Order status updated." });
        }
    }
}
