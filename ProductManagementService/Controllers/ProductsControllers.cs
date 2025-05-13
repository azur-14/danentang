using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/products")]
    public class ProductsController : ControllerBase
    {
        private readonly IMongoCollection<Product> _products;

        public ProductsController(MongoDbContext context)
        {
            _products = context.Products;
        }

        // -----------------------
        // PRODUCT CRUD
        // -----------------------
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> UpdateProduct(string id, [FromBody] Product updated)
        {
            updated.Id = id;
            updated.UpdatedAt = DateTime.UtcNow;

            // Kiểm tra variant nào bị thiếu id
            if (updated.Variants.Any(v => string.IsNullOrEmpty(v.Id)))
                return BadRequest("All variants must have valid id.");

            var existing = await _products.Find(p => p.Id == id).FirstOrDefaultAsync();
            if (existing == null)
                return NotFound("Product not found.");

            // Khởi tạo product item collection
            var _productItems = HttpContext
                .RequestServices
                .GetService(typeof(MongoDbContext)) is MongoDbContext ctx
                ? ctx.ProductItems
                : throw new Exception("Cannot resolve ProductItems collection");

            // Tạo thêm product items nếu tăng số lượng
            foreach (var updatedVariant in updated.Variants)
            {
                var oldVariant = existing.Variants.FirstOrDefault(v => v.Id == updatedVariant.Id);
                if (oldVariant != null && updatedVariant.Inventory > oldVariant.Inventory)
                {
                    int addedCount = updatedVariant.Inventory - oldVariant.Inventory;
                    var now = DateTime.UtcNow;

                    var items = Enumerable.Range(0, addedCount)
                        .Select(_ => new ProductItem
                        {
                            Id = ObjectId.GenerateNewId().ToString(),
                            ProductId = id,
                            VariantId = updatedVariant.Id,
                            Status = "available",
                            CreatedAt = now,
                            UpdatedAt = now
                        }).ToList();

                    if (items.Count > 0)
                        await _productItems.InsertManyAsync(items);
                }
            }

            var result = await _products.ReplaceOneAsync(p => p.Id == id, updated);
            if (result.MatchedCount == 0)
                return NotFound("Product not found during update.");

            return NoContent();
        }

        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Product data is required.");

            product.Id = ObjectId.GenerateNewId().ToString();
            product.CreatedAt = DateTime.UtcNow;
            product.UpdatedAt = DateTime.UtcNow;

            if (product.Price <= 0 || product.DiscountPercentage < 0)
                return BadRequest("Invalid price or discount.");

            await _products.InsertOneAsync(product);
            return Ok(product);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var products = await _products.Find(_ => true).ToListAsync();
            return Ok(products);
        }

        [HttpGet("category/{categoryId:length(24)}")]
        public async Task<IActionResult> GetByCategory(string categoryId)
        {
            var products = await _products.Find(p => p.CategoryId == categoryId).ToListAsync();
            if (!products.Any())
                return NotFound($"No products found for category {categoryId}.");
            return Ok(products);
        }

        [HttpGet("{id:length(24)}")]
        public async Task<IActionResult> GetById(string id)
        {
            var product = await _products.Find(p => p.Id == id).FirstOrDefaultAsync();
            if (product == null)
                return NotFound("Product not found.");
            return Ok(product);
        }

        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> DeleteProduct(string id)
        {
            var result = await _products.DeleteOneAsync(p => p.Id == id);
            if (result.DeletedCount == 0)
                return NotFound("Product not found.");
            return NoContent();
        }

        // -----------------------
        // IMAGE CRUD
        // -----------------------

        [HttpGet("{productId:length(24)}/images")]
        public async Task<IActionResult> GetImages(string productId)
        {
            var images = await _products
                .Find(p => p.Id == productId)
                .Project(p => p.Images)
                .FirstOrDefaultAsync();

            if (images == null)
                return NotFound("Product not found.");
            return Ok(images);
        }

        [HttpPost("{productId:length(24)}/images")]
        public async Task<IActionResult> AddImage(string productId, [FromBody] ProductImage image)
        {
            image.Id = ObjectId.GenerateNewId().ToString();

            var update = Builders<Product>.Update
                .Push(p => p.Images, image)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(p => p.Id == productId, update);
            if (result.MatchedCount == 0)
                return NotFound("Product not found.");
            return Ok(image);
        }

        [HttpPut("{productId:length(24)}/images/{imageId:length(24)}")]
        public async Task<IActionResult> UpdateImage(string productId, string imageId, [FromBody] ProductImage updated)
        {
            updated.Id = imageId;

            var filter = Builders<Product>.Filter.And(
                Builders<Product>.Filter.Eq(p => p.Id, productId),
                Builders<Product>.Filter.Eq("images.id", imageId)
            );

            var update = Builders<Product>.Update
                .Set("images.$.url", updated.Url)
                .Set("images.$.sortOrder", updated.SortOrder)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(filter, update);
            if (result.MatchedCount == 0)
                return NotFound("Image or product not found.");
            return NoContent();
        }

        [HttpDelete("{productId:length(24)}/images/{imageId:length(24)}")]
        public async Task<IActionResult> DeleteImage(string productId, string imageId)
        {
            var update = Builders<Product>.Update
                .PullFilter(p => p.Images, img => img.Id == imageId)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(p => p.Id == productId, update);
            if (result.MatchedCount == 0)
                return NotFound("Image or product not found.");
            return NoContent();
        }

        // -----------------------
        // VARIANT CRUD
        // -----------------------

        [HttpGet("{productId:length(24)}/variants")]
        public async Task<IActionResult> GetVariants(string productId)
        {
            var variants = await _products
                .Find(p => p.Id == productId)
                .Project(p => p.Variants)
                .FirstOrDefaultAsync();

            if (variants == null)
                return NotFound("Product not found.");
            return Ok(variants);
        }

        [HttpPost("{productId:length(24)}/variants")]
        public async Task<IActionResult> AddVariant(string productId, [FromBody] ProductVariant variant)
        {
            variant.Id = ObjectId.GenerateNewId().ToString();
            variant.CreatedAt = variant.UpdatedAt = DateTime.UtcNow;

            var update = Builders<Product>.Update
                .Push(p => p.Variants, variant)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(p => p.Id == productId, update);
            if (result.MatchedCount == 0)
                return NotFound("Product not found.");
            return Ok(variant);
        }

        [HttpPut("{productId:length(24)}/variants/{variantId:length(24)}")]
        public async Task<IActionResult> UpdateVariant(string productId, string variantId, [FromBody] ProductVariant updated)
        {
            updated.Id = variantId;
            updated.UpdatedAt = DateTime.UtcNow;

            var filter = Builders<Product>.Filter.And(
                Builders<Product>.Filter.Eq(p => p.Id, productId),
                Builders<Product>.Filter.Eq("variants.id", variantId)
            );

            var update = Builders<Product>.Update
                .Set("variants.$.variantName", updated.VariantName)
                .Set("variants.$.additionalPrice", updated.AdditionalPrice)
                .Set("variants.$.inventory", updated.Inventory)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(filter, update);
            if (result.MatchedCount == 0)
                return NotFound("Variant or product not found.");
            return NoContent();
        }

        [HttpDelete("{productId:length(24)}/variants/{variantId:length(24)}")]
        public async Task<IActionResult> DeleteVariant(string productId, string variantId)
        {
            var update = Builders<Product>.Update
                .PullFilter(p => p.Variants, v => v.Id == variantId)
                .CurrentDate(p => p.UpdatedAt);

            var result = await _products.UpdateOneAsync(p => p.Id == productId, update);
            if (result.MatchedCount == 0)
                return NotFound("Variant or product not found.");
            return NoContent();
        }
    }
}
