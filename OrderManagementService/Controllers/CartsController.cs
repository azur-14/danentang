// OrderManagementService/Controllers/CartsController.cs

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
    public class CartsController : ControllerBase
    {
        private readonly IMongoCollection<Cart> _carts;
        public CartsController(MongoDbContext context) => _carts = context.Carts;

        // GET api/carts/user/{userId}
        [HttpGet("user/{userId}", Name = "GetCartByUser")]
        public async Task<ActionResult<Cart>> GetByUser(string userId)
        {
            var cart = await _carts.Find(c => c.UserId == userId).FirstOrDefaultAsync();
            if (cart == null) return NotFound();
            return cart;
        }

        // GET api/carts/{cartId}
        [HttpGet("{cartId:length(24)}", Name = "GetCartById")]
        public async Task<ActionResult<Cart>> GetByCartId(string cartId)
        {
            var cart = await _carts.Find(c => c.Id == cartId).FirstOrDefaultAsync();
            if (cart == null) return NotFound();
            return cart;
        }

        // POST api/carts
        [HttpPost]
        public async Task<ActionResult<Cart>> Create([FromBody] Cart cart)
        {
            ModelState.Remove(nameof(cart.Id));
            cart.Id = ObjectId.GenerateNewId().ToString();
            cart.CreatedAt = cart.UpdatedAt = DateTime.UtcNow;

            await _carts.InsertOneAsync(cart);

            if (!string.IsNullOrEmpty(cart.UserId))
            {
                // Tạo route /api/carts/user/{userId}
                return CreatedAtRoute(
                    "GetCartByUser",
                    new { userId = cart.UserId },
                    cart);
            }
            else
            {
                // Tạo route /api/carts/{cartId}
                return CreatedAtRoute(
                    "GetCartById",
                    new { cartId = cart.Id },
                    cart);
            }
        }

        // PATCH api/carts/{cartId}
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
            // Thử cập nhật số lượng nếu item đã tồn tại
            var filter = Builders<Cart>.Filter.And(
                Builders<Cart>.Filter.Eq(c => c.Id, cartId),
                Builders<Cart>.Filter.ElemMatch(c => c.Items,
                    i => i.ProductId == item.ProductId &&
                        (i.ProductVariantId == item.ProductVariantId || item.ProductVariantId == null))
            );

            var update = Builders<Cart>.Update
                .Set("Items.$.Quantity", item.Quantity)
                .CurrentDate(c => c.UpdatedAt);

            var result = await _carts.UpdateOneAsync(filter, update);

            // Nếu không tìm thấy item để cập nhật, thì thêm mới
            if (result.MatchedCount == 0)
            {
                // hoặc nếu dùng class thường:
                var newItem = new CartItem
                {
                    ProductId = item.ProductId,
                    ProductVariantId = item.ProductVariantId,
                    Quantity = 1
                };

                var pushUpdate = Builders<Cart>.Update
                    .Push(c => c.Items, newItem)
                    .CurrentDate(c => c.UpdatedAt);

                var pushResult = await _carts.UpdateOneAsync(c => c.Id == cartId, pushUpdate);
                if (pushResult.MatchedCount == 0) return NotFound();
            }


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
        // DELETE api/carts/{cartId}/items
        [HttpDelete("{cartId:length(24)}/items")]
        public async Task<IActionResult> ClearCartItems(string cartId)
        {
            var update = Builders<Cart>.Update
                .Set(c => c.Items, new List<CartItem>())
                .CurrentDate(c => c.UpdatedAt);

            var result = await _carts.UpdateOneAsync(c => c.Id == cartId, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }
    }
}
