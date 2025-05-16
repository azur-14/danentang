using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using MongoDB.Bson;
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
            // 1) Filter the product_tags collection by the raw "tag_id" field
            var linkFilter = Builders<ProductTag>.Filter.Eq("tag_id", tagId);
            var links = await _productTags
              .Find(linkFilter)
              .ToListAsync();

            // 2) Pull out the product_id values
            var productIds = links.Select(l => l.ProductId).ToList();

            // 3) Fetch the actual products whose Id is in that list
            var prodFilter = Builders<Product>.Filter.In(p => p.Id, productIds);
            var products = await _products
              .Find(prodFilter)
              .ToListAsync();

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
        [HttpPut("by-product/{productId:length(24)}")]
        public async Task<IActionResult> UpsertTags(string productId, [FromBody] TagAssignmentModel model)
        {
            await _productTags.DeleteManyAsync(pt => pt.ProductId == productId);

            var docs = model.TagIds.Select(tagId => new ProductTag
            {
                Id = ObjectId.GenerateNewId().ToString(),  // ObjectId giờ được nhận diện
                ProductId = productId,
                TagId = tagId
            });
            if (docs.Any())
                await _productTags.InsertManyAsync(docs);

            return NoContent();
        }

        public class TagAssignmentModel { public List<string> TagIds { get; set; } = new(); }
    }
}

