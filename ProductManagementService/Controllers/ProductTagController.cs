using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;
// alias để không nhầm với MongoDB.Driver.Tag
using AppTag = ProductManagementService.Models.Tag;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/product-tags")]
    public class ProductTagController : ControllerBase
    {
        private readonly IMongoCollection<ProductTag> _productTags;
        private readonly IMongoCollection<AppTag> _tags;
        private readonly IMongoCollection<Product> _products;

        public ProductTagController(MongoDbContext context)
        {
            _productTags = context.ProductTags;
            _tags = context.Tags;
            _products = context.Products;
        }

        [HttpPost]
        public async Task<IActionResult> AssignTag([FromBody] ProductTag pt)
        {
            await _productTags.InsertOneAsync(pt);
            return Ok(new { message = "Tag assigned." });
        }

        [HttpGet("by-product/{productId}")]
        public async Task<IActionResult> GetTagsOfProduct(string productId)
        {
            var productTags = await _productTags
                .Find(pt => pt.ProductId == productId)
                .ToListAsync();

            var tagIds = productTags.Select(pt => pt.TagId).ToList();
            var tags = await _tags.Find(t => tagIds.Contains(t.Id)).ToListAsync();

            return Ok(tags);
        }

        [HttpGet("by-tag/{tagId}")]
        public async Task<IActionResult> GetProductsByTag(string tagId)
        {
            var links = await _productTags.Find(pt => pt.TagId == tagId).ToListAsync();
            var productIds = links.Select(pt => pt.ProductId).ToList();
            var products = await _products.Find(p => productIds.Contains(p.Id)).ToListAsync();

            return Ok(products);
        }

        [HttpDelete]
        public async Task<IActionResult> RemoveTagFromProduct(
            [FromQuery] string productId,
            [FromQuery] string tagId)
        {
            var result = await _productTags.DeleteOneAsync(pt =>
                pt.ProductId == productId && pt.TagId == tagId);

            return result.DeletedCount == 0
                ? NotFound()
                : Ok(new { message = "Tag removed." });
        }
    }
}

