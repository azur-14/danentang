using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;
using MongoDB.Bson;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/product-items")]
    public class ProductItemsController : ControllerBase
    {
        private readonly IMongoCollection<ProductItem> _productItems;

        public ProductItemsController(MongoDbContext context)
        {
            _productItems = context.ProductItems;
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProductItem item)
        {
            item.Id = ObjectId.GenerateNewId().ToString();
            item.Status = "available";
            item.CreatedAt = item.UpdatedAt = DateTime.UtcNow;

            await _productItems.InsertOneAsync(item);
            return Ok(item);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var items = await _productItems.Find(_ => true).ToListAsync();
            return Ok(items);
        }

        [HttpGet("{id:length(24)}")]
        public async Task<IActionResult> GetById(string id)
        {
            var item = await _productItems.Find(i => i.Id == id).FirstOrDefaultAsync();
            if (item == null)
                return NotFound("Product item not found.");
            return Ok(item);
        }

        [HttpGet("by-product/{productId:length(24)}")]
        public async Task<IActionResult> GetByProductId(string productId)
        {
            var items = await _productItems.Find(i => i.ProductId == productId).ToListAsync();
            return Ok(items);
        }

        [HttpGet("by-variant/{variantId:length(24)}")]
        public async Task<IActionResult> GetByVariantId(string variantId)
        {
            var items = await _productItems.Find(i => i.VariantId == variantId).ToListAsync();
            return Ok(items);
        }

        [HttpGet("available/{variantId:length(24)}")]
        public async Task<IActionResult> GetAvailableItems(string variantId)
        {
            var items = await _productItems.Find(i => i.VariantId == variantId && i.Status == "available").ToListAsync();
            return Ok(items);
        }

        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] ProductItem updated)
        {
            updated.Id = id;
            updated.UpdatedAt = DateTime.UtcNow;

            var result = await _productItems.ReplaceOneAsync(i => i.Id == id, updated);
            if (result.MatchedCount == 0)
                return NotFound("Product item not found.");

            return NoContent();
        }

        [HttpPatch("{id:length(24)}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] string newStatus)
        {
            var update = Builders<ProductItem>.Update
                .Set(i => i.Status, newStatus)
                .CurrentDate(i => i.UpdatedAt);

            var result = await _productItems.UpdateOneAsync(i => i.Id == id, update);
            if (result.MatchedCount == 0)
                return NotFound("Product item not found.");

            return NoContent();
        }

        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _productItems.DeleteOneAsync(i => i.Id == id);
            if (result.DeletedCount == 0)
                return NotFound("Product item not found.");
            return NoContent();
        }
    }
}
