using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
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

        // Assign tag to product
        [HttpPost]
        public async Task<IActionResult> AssignTag([FromBody] ProductTag pt)
        {
            pt.ProductId = new ObjectId(pt.ProductId.ToString());  // Convert ProductId to ObjectId
            pt.TagId = new ObjectId(pt.TagId.ToString());  // Convert TagId to ObjectId
            await _productTagCol.InsertOneAsync(pt);
            return Ok(new { message = "Tag assigned." });
        }

        // Get tags of product by productId
        [HttpGet("by-product/{productId}")]
        public async Task<IActionResult> GetTagsOfProduct(string productId)
        {
            try
            {
                var objectId = new ObjectId(productId);  // Convert productId to ObjectId
                var productTags = await _productTagCol
                    .Find(pt => pt.ProductId == objectId)
                    .ToListAsync();
                var tagIds = productTags.Select(pt => pt.TagId).ToList();
                var tags = await _tagCol
                    .Find(t => tagIds.Contains(t.Id))
                    .ToListAsync();
                return Ok(tags);
            }
            catch (FormatException)
            {
                return BadRequest("Invalid ProductId format.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // Get products by tagId
        [HttpGet("by-tag/{tagId}")]
        public async Task<IActionResult> GetProductsByTag(string tagId)
        {
            try
            {
                var objectId = new ObjectId(tagId);  // Convert tagId to ObjectId
                var links = await _productTagCol
                    .Find(pt => pt.TagId == objectId)
                    .ToListAsync();
                var productIds = links.Select(pt => pt.ProductId).ToList();
                var products = await _productCol
                    .Find(p => productIds.Contains(p.Id))
                    .ToListAsync();
                return Ok(products);
            }
            catch (FormatException)
            {
                return BadRequest("Invalid TagId format.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // Remove tag from product
        [HttpDelete]
        public async Task<IActionResult> RemoveTagFromProduct([FromQuery] string productId, [FromQuery] string tagId)
        {
            try
            {
                var productObjectId = new ObjectId(productId);  // Convert productId to ObjectId
                var tagObjectId = new ObjectId(tagId);  // Convert tagId to ObjectId
                var result = await _productTagCol.DeleteOneAsync(pt => pt.ProductId == productObjectId && pt.TagId == tagObjectId);
                return result.DeletedCount == 0 ? NotFound() : Ok(new { message = "Tag removed." });
            }
            catch (FormatException)
            {
                return BadRequest("Invalid ProductId or TagId format.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}
