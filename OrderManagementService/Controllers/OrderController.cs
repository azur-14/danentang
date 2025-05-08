using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using OrderManagementService.Data;
using OrderManagementService.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

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

        // GET api/orders
        [HttpGet]
        public async Task<ActionResult<List<Order>>> GetAll() =>
            await _orders.Find(_ => true).ToListAsync();

        // GET api/orders/{id}
        [HttpGet("{id:length(24)}")]
        public async Task<ActionResult<Order>> Get(string id)
        {
            var order = await _orders.Find(o => o.Id == id).FirstOrDefaultAsync();
            if (order == null) return NotFound();
            return order;
        }

        // POST api/orders
        [HttpPost]
        public async Task<ActionResult<Order>> Create([FromBody] Order order)
        {
            ModelState.Remove(nameof(order.Id));

            order.Id = ObjectId.GenerateNewId().ToString();
            order.CreatedAt = order.UpdatedAt = DateTime.UtcNow;
            await _orders.InsertOneAsync(order);
            return CreatedAtAction(nameof(Get), new { id = order.Id }, order);
        }

        // PUT api/orders/{id}
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] Order updated)
        {
            updated.Id = id;
            updated.UpdatedAt = DateTime.UtcNow;
            var result = await _orders.ReplaceOneAsync(o => o.Id == id, updated);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // DELETE api/orders/{id}
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _orders.DeleteOneAsync(o => o.Id == id);
            if (result.DeletedCount == 0) return NotFound();
            return NoContent();
        }

        // PATCH api/orders/{id}/status
        [HttpPatch("{id:length(24)}/status")]
        public async Task<IActionResult> UpdateStatus(
            string id,
            [FromBody] OrderStatusHistory history)
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
