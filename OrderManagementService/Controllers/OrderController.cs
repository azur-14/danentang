using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using OrderManagementService.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using OrderManagementService.Data;
namespace OrderManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly IMongoCollection<Order> _orders;

        public OrdersController(MongoDbContext context)
        {
            _orders = context.Orders;
        }

        [HttpGet]
        public async Task<ActionResult<List<Order>>> Get() =>
            await _orders.Find(_ => true).ToListAsync();

        [HttpGet("{id:length(24)}")]
        public async Task<ActionResult<Order>> Get(string id)
        {
            var order = await _orders.Find(o => o.Id == id).FirstOrDefaultAsync();
            if (order == null) return NotFound();
            return order;
        }

        [HttpPost]
        public async Task<ActionResult<Order>> Create(Order order)
        {
            order.CreatedAt = order.UpdatedAt = System.DateTime.UtcNow;
            await _orders.InsertOneAsync(order);
            return CreatedAtAction(nameof(Get), new { id = order.Id }, order);
        }

        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, Order updated)
        {
            updated.UpdatedAt = System.DateTime.UtcNow;
            var result = await _orders.ReplaceOneAsync(o => o.Id == id, updated);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _orders.DeleteOneAsync(o => o.Id == id);
            if (result.DeletedCount == 0) return NotFound();
            return NoContent();
        }

        // Cập nhật trạng thái và thêm lịch sử
        [HttpPatch("{id:length(24)}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] OrderStatusHistory history)
        {
            var update = Builders<Order>.Update
                .Set(o => o.Status, history.Status)
                .Push(o => o.StatusHistory, history)
                .CurrentDate(o => o.UpdatedAt);

            var result = await _orders.UpdateOneAsync(o => o.Id == id, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }
    }
}
