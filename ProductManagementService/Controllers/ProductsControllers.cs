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

        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Product data is required.");

            product.Id        = ObjectId.GenerateNewId().ToString();
            product.CreatedAt = DateTime.UtcNow;
            product.UpdatedAt = DateTime.UtcNow;

            // Validate & assign IDs/timestamps for variants
            foreach (var v in product.Variants)
            {
                v.Id            = ObjectId.GenerateNewId().ToString();
                v.CreatedAt     = DateTime.UtcNow;
                v.UpdatedAt     = DateTime.UtcNow;
                if (v.AdditionalPrice < 0)
                    return BadRequest("Each variant must have non-negative additionalPrice.");
                if (v.Inventory < 0)
                    return BadRequest("Each variant must have non-negative inventory.");
            }

            await _products.InsertOneAsync(product);
            return Ok(product);
        }

        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> UpdateProduct(string id, [FromBody] Product updated)
        {
            if (updated == null)
                return BadRequest("Product data is required.");

            updated.Id        = id;
            updated.UpdatedAt = DateTime.UtcNow;

            if (updated.Variants.Any(v => string.IsNullOrEmpty(v.Id)))
                return BadRequest("All variants must have valid id.");

            foreach (var v in updated.Variants)
            {
                if (v.AdditionalPrice < 0)
                    return BadRequest("Each variant must have non-negative additionalPrice.");
                if (v.Inventory < 0)
                    return BadRequest("Each variant must have non-negative inventory.");
            }

            var result = await _products.ReplaceOneAsync(p => p.Id == id, updated);
            if (result.MatchedCount == 0)
                return NotFound("Product not found.");

            return NoContent();
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var products = await _products.Find(_ => true).ToListAsync();
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
                Builders<Product>.Filter.Eq("images._id", imageId)
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
            variant.Id        = ObjectId.GenerateNewId().ToString();
            variant.CreatedAt = DateTime.UtcNow;
            variant.UpdatedAt = DateTime.UtcNow;

            if (variant.AdditionalPrice < 0)
                return BadRequest("Variant must have non-negative additionalPrice.");
            if (variant.Inventory < 0)
                return BadRequest("Variant must have non-negative inventory.");

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
            updated.Id        = variantId;
            updated.UpdatedAt = DateTime.UtcNow;

            if (updated.AdditionalPrice < 0)
                return BadRequest("Variant must have non-negative additionalPrice.");
            if (updated.Inventory < 0)
                return BadRequest("Variant must have non-negative inventory.");

            var filter = Builders<Product>.Filter.And(
                Builders<Product>.Filter.Eq(p => p.Id, productId),
                Builders<Product>.Filter.Eq("variants._id", variantId)
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
        [HttpGet("available/{variantId}")]
        public async Task<ActionResult<int>> GetAvailable(string variantId)
        {
            variantId = variantId.Trim();

            // Tìm sản phẩm chứa variant có id trùng
            var product = await _products
                .Find(p => p.Variants.Any(v => v.Id == variantId))
                .FirstOrDefaultAsync();

            if (product == null)
                return NotFound("Product or variant not found.");

            var variant = product.Variants.FirstOrDefault(v => v.Id == variantId);
            if (variant == null)
                return NotFound("Variant not found.");

            return Ok(variant.Inventory);
        }
        [HttpGet("variants/{variantId}")]
        public async Task<IActionResult> GetVariantById(string variantId)
        {
            var product = await _products.Find(p => p.Variants.Any(v => v.Id == variantId)).FirstOrDefaultAsync();
            if (product == null) return NotFound("Variant not found.");
            var variant = product.Variants.FirstOrDefault(v => v.Id == variantId);
            if (variant == null) return NotFound("Variant not found.");
            return Ok(variant);
        }


        // PATCH giảm tồn kho khi xác nhận đơn hàng
        [HttpPatch("variants/{variantId}/decrease")]
        public async Task<IActionResult> DecreaseVariantInventory(string variantId, [FromBody] int quantity)
        {
            var filter = Builders<Product>.Filter.ElemMatch(p => p.Variants, v => v.Id == variantId);
            var update = Builders<Product>.Update.Inc("variants.$.inventory", -quantity);

            var result = await _products.UpdateOneAsync(filter, update);

            if (result.ModifiedCount == 0)
                return BadRequest("Không giảm được tồn kho (variant không tồn tại hoặc số lượng không hợp lệ).");
            return NoContent();
        }
    }
}
