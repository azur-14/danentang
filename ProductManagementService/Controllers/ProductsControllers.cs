using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/products")]
    public class ProductsController : ControllerBase
    {
        private readonly MongoDbContext _context;

        public ProductsController(MongoDbContext context)
        {
            _context = context;
        }

        // Create a new product
        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] Product product)
        {
            if (product == null)
            {
                return BadRequest("Product data is required.");
            }

            product.CreatedAt = DateTime.UtcNow;
            product.UpdatedAt = DateTime.UtcNow;

            // Ensure that the price is stored as decimal and discount as percentage (validate if needed)
            if (product.Price <= 0 || product.DiscountPercentage < 0)
            {
                return BadRequest("Invalid price or discount.");
            }

            await _context.Products.InsertOneAsync(product);
            return Ok(product);
        }

        // Get all products
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var products = await _context.Products.Find(_ => true).ToListAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // Get products by categoryId (using ObjectId)
        [HttpGet("category/{categoryId}")]
        public async Task<IActionResult> GetByCategory(string categoryId)
        {
            try
            {
                var objectId = new ObjectId(categoryId);  // Convert categoryId from string to ObjectId
                var products = await _context.Products
                    .Find(p => p.CategoryId == objectId)
                    .ToListAsync();

                if (products.Count == 0)
                {
                    return NotFound($"No products found for category with id {categoryId}.");  // Provide more specific message
                }

                return Ok(products);
            }
            catch (FormatException)
            {
                return BadRequest("Invalid CategoryId format.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // Get product by ID (using ObjectId)
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var objectId = new ObjectId(id);  // Convert id from string to ObjectId
                var product = await _context.Products.Find(p => p.Id == objectId).FirstOrDefaultAsync();

                if (product == null)
                {
                    return NotFound("Product not found.");
                }

                return Ok(product);
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
    }
}
