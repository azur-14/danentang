using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;
using AppTag = ProductManagementService.Models.Tag;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductTagController : ControllerBase
    {
        private readonly IMongoCollection<ProductTag> _productTagCol;
        private readonly IMongoCollection<AppTag> _tagCol;
        private readonly IMongoCollection<Product> _productCol;

        public ProductTagController(MongoDbContext context)
        {
            _productTagCol = context.ProductTags;
            _tagCol = context.Tags;
            _productCol = context.Products;
        }

        [HttpPost]
        public async Task<IActionResult> AssignTag([FromBody] ProductTag pt)
        {
            await _productTagCol.InsertOneAsync(pt);
            return Ok(new { message = "Tag assigned." });
        }

        [HttpGet("by-product/{productId}")]
        public async Task<IActionResult> GetTagsOfProduct(string productId)
        {
            var productTags = await _productTagCol.Find(pt => pt.ProductId == productId).ToListAsync();
            var tagIds = productTags.Select(pt => pt.TagId).ToList();
            var tags = await _tagCol.Find(t => tagIds.Contains(t.Id)).ToListAsync();
            return Ok(tags);
        }

        [HttpGet("by-tag/{tagId}")]
        public async Task<IActionResult> GetProductsByTag(string tagId)
        {
            var links = await _productTagCol.Find(pt => pt.TagId == tagId).ToListAsync();
            var productIds = links.Select(pt => pt.ProductId).ToList();
            var products = await _productCol.Find(p => productIds.Contains(p.Id)).ToListAsync();
            return Ok(products);
        }

        [HttpDelete]
        public async Task<IActionResult> RemoveTagFromProduct([FromQuery] string productId, [FromQuery] string tagId)
        {
            var result = await _productTagCol.DeleteOneAsync(pt => pt.ProductId == productId && pt.TagId == tagId);
            return result.DeletedCount == 0 ? NotFound() : Ok(new { message = "Tag removed." });
        }
    }
}
