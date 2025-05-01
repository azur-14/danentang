using Microsoft.AspNetCore.Mvc;
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

        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Product data is required.");

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

        [HttpGet("category/{categoryId}")]
        public async Task<IActionResult> GetByCategory(string categoryId)
        {
            var products = await _products
                .Find(p => p.CategoryId == categoryId)
                .ToListAsync();

            if (!products.Any())
                return NotFound($"No products found for category {categoryId}.");

            return Ok(products);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var product = await _products
                .Find(p => p.Id == id)
                .FirstOrDefaultAsync();

            if (product == null)
                return NotFound("Product not found.");

            return Ok(product);
        }
    }
}
