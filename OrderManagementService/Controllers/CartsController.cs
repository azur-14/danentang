using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using OrderManagementService.Data;
using OrderManagementService.Models;
using System;
using System.Threading.Tasks;

namespace OrderManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartsController : ControllerBase
    {
        private readonly IMongoCollection<Cart> _carts;

        public CartsController(MongoDbContext context)
        {
            _carts = context.Carts;
        }

        // GET api/carts/{userId}
        [HttpGet("{userId}")]
        public async Task<ActionResult<Cart>> GetByUser(string userId)
        {
            var cart = await _carts.Find(c => c.UserId == userId).FirstOrDefaultAsync();
            if (cart == null) return NotFound();
            return cart;
        }

        // POST api/carts
        [HttpPost]
        public async Task<ActionResult<Cart>> Create([FromBody] Cart cart)
        {
            // Remove validation error for Id so we can generate it here
            ModelState.Remove(nameof(cart.Id));

            cart.Id = ObjectId.GenerateNewId().ToString();
            cart.CreatedAt = cart.UpdatedAt = DateTime.UtcNow;

            await _carts.InsertOneAsync(cart);
            return CreatedAtAction(nameof(GetByUser), new { userId = cart.UserId }, cart);
        }
        [HttpPatch("{cartId:length(24)}")]
        public async Task<IActionResult> UpdateCart(string cartId, [FromBody] List<CartItem> items)
        {
            var update = Builders<Cart>.Update
                .Set(c => c.Items, items)
                .CurrentDate(c => c.UpdatedAt);

            var result = await _carts.UpdateOneAsync(c => c.Id == cartId, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // PATCH api/carts/{cartId}/items
        [HttpPatch("{cartId:length(24)}/items")]
        public async Task<IActionResult> UpsertItem(string cartId, [FromBody] CartItem item)
        {
            var update = Builders<Cart>.Update
                .CurrentDate(c => c.UpdatedAt)
                .AddToSet(c => c.Items, item);

            var result = await _carts.UpdateOneAsync(c => c.Id == cartId, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // DELETE api/carts/{cartId}/items/{variantOrProductId}
        [HttpDelete("{cartId:length(24)}/items/{variantOrProductId}")]
        public async Task<IActionResult> RemoveItem(string cartId, string variantOrProductId)
        {
            var update = Builders<Cart>.Update
                .CurrentDate(c => c.UpdatedAt)
                .PullFilter(c => c.Items,
                    i => i.ProductVariantId == variantOrProductId
                         || i.ProductId == variantOrProductId);

            var result = await _carts.UpdateOneAsync(c => c.Id == cartId, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }
    }
}
