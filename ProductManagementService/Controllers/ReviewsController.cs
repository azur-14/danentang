using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/reviews")]
    public class ReviewsController : ControllerBase
    {
        private readonly MongoDbContext _context;

        public ReviewsController(MongoDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> AddReview([FromBody] Review review)
        {
            review.CreatedAt = DateTime.UtcNow;
            await _context.Reviews.InsertOneAsync(review);
            return Ok(review);
        }

        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetReviews(string productId)
        {
            var reviews = await _context.Reviews.Find(r => r.ProductId == productId).ToListAsync();
            return Ok(reviews);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReview(string id)
        {
            var result = await _context.Reviews.DeleteOneAsync(r => r.Id == id);
            return result.DeletedCount > 0 ? Ok("Deleted") : NotFound();
        }
    }
}
