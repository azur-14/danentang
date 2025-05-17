using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReviewBackend.Data;
using ReviewBackend.Models;

namespace ReviewBackend.Controllers
{
    [Route("api/reviews")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly ReviewDbContext _context;

        public ReviewsController(ReviewDbContext context)
        {
            _context = context;
        }

        // POST: api/reviews/save
        [HttpPost("save")]
        public async Task<IActionResult> SaveReview([FromBody] Review review)
        {
            try
            {
                Console.WriteLine($"Received review data: {System.Text.Json.JsonSerializer.Serialize(review)}"); // Log dữ liệu nhận được
                if (review == null || string.IsNullOrEmpty(review.UserId))
                {
                    return BadRequest(new { error = "Invalid review data: UserId is required" });
                }

                await _context.Reviews!.AddAsync(review);
                await _context.SaveChangesAsync();
                return Ok(new { _id = review.Id });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving review: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to save: {ex.Message}" });
            }
        }

        // PUT: api/reviews/update/{id}
        [HttpPut("update/{id}")]
        public async Task<IActionResult> UpdateReview(string id, [FromBody] Review review)
        {
            try
            {
                Console.WriteLine($"Updating review with ID: {id}, Data: {System.Text.Json.JsonSerializer.Serialize(review)}"); // Log dữ liệu
                var existingReview = await _context.Reviews!.FindAsync(id);
                if (existingReview == null)
                {
                    return NotFound(new { error = "Review not found" });
                }

                existingReview.UserId = review.UserId;
                existingReview.Name = review.Name;
                existingReview.Reviews = review.Reviews;
                existingReview.CreatedAt = review.CreatedAt;

                await _context.SaveChangesAsync();
                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating review: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to update: {ex.Message}" });
            }
        }

        // GET: api/reviews/latest/{userId}
        [HttpGet("latest/{userId}")]
        public async Task<IActionResult> GetLatestReview(string userId)
        {
            try
            {
                var review = await _context.Reviews!
                    .Where(r => r.UserId == userId)
                    .OrderByDescending(r => r.CreatedAt)
                    .FirstOrDefaultAsync();
                return Ok(review ?? new Review());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching latest review: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to fetch: {ex.Message}" });
            }
        }

        // GET: api/reviews/all/{userId}
        [HttpGet("all/{userId}")]
        public async Task<IActionResult> GetAllReviews(string userId)
        {
            try
            {
                var reviews = await _context.Reviews!
                    .Where(r => r.UserId == userId)
                    .OrderByDescending(r => r.CreatedAt)
                    .ToListAsync();
                return Ok(reviews);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching all reviews: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to fetch: {ex.Message}" });
            }
        }

        // GET: api/reviews/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetReviewById(string id)
        {
            try
            {
                var review = await _context.Reviews!.FindAsync(id);
                return Ok(review ?? new Review());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching review by ID: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to fetch: {ex.Message}" });
            }
        }

        // DELETE: api/reviews/delete/{id}
        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteReview(string id)
        {
            try
            {
                var review = await _context.Reviews!.FindAsync(id);
                if (review == null)
                {
                    return NotFound(new { error = "Review not found" });
                }

                _context.Reviews.Remove(review);
                await _context.SaveChangesAsync();
                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting review: {ex.Message}"); // Log lỗi
                return StatusCode(500, new { error = $"Failed to delete: {ex.Message}" });
            }
        }
    }
}