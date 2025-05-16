// ProductManagementService/Controllers/ReviewsController.cs
using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/products/{productId:length(24)}/reviews")]
    public class ReviewsController : ControllerBase
    {
        private readonly IMongoCollection<Review> _reviews;
        private readonly IMongoCollection<Product> _products;

        public ReviewsController(MongoDbContext ctx)
        {
            _reviews = ctx.Reviews;
            _products = ctx.Products;
        }

        // GET /api/products/{productId}/reviews
        [HttpGet]
        public async Task<IActionResult> GetReviews(string productId)
        {
            // Kiểm tra product tồn tại
            var exists = await _products.Find(p => p.Id == productId).AnyAsync();
            if (!exists) return NotFound("Product not found.");

            var reviews = await _reviews
                .Find(r => r.ProductId == productId)
                .SortByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(reviews);
        }

        // POST /api/products/{productId}/reviews
        [HttpPost]
        public async Task<IActionResult> PostReview(
            string productId,
            [FromBody] ReviewCreateModel model)
        {
            // Validate product
            var exists = await _products.Find(p => p.Id == productId).AnyAsync();
            if (!exists) return NotFound("Product not found.");

            // Nếu chưa login (no user claim), bạn có thể để UserId = null và bắt guestName
            var userId = User.Identity?.IsAuthenticated == true
                ? User.FindFirst("sub")?.Value // hoặc claim nameIdentifier
                : null;

            if (userId == null && string.IsNullOrWhiteSpace(model.GuestName))
                return BadRequest("GuestName is required for anonymous reviews.");

            var review = new Review
            {
                Id = ObjectId.GenerateNewId().ToString(),
                ProductId = productId,
                UserId = userId,
                GuestName = userId == null ? model.GuestName : null,
                Comment = model.Comment,
                Rating = model.Rating,
                CreatedAt = DateTime.UtcNow
            };

            await _reviews.InsertOneAsync(review);
            return CreatedAtAction(
                nameof(GetReviews),
                new { productId = productId },
                review
            );
        }

        [HttpGet]
        public async Task<IActionResult> GetRating(string productId)
        {
            // Lọc các review có rating != null cho product này
            var filter = Builders<Review>.Filter.Eq(r => r.ProductId, productId)
                         & Builders<Review>.Filter.Ne(r => r.Rating, null);

            // Dùng aggregation để tính trung bình và đếm
            var agg = await _reviews.Aggregate()
                .Match(filter)
                .Group(r => r.ProductId, g => new {
                    Avg = g.Average(x => x.Rating.Value),
                    Count = g.Count()
                })
                .FirstOrDefaultAsync();

            // Nếu chưa có review nào, trả về 0/0
            if (agg == null)
                return Ok(new
                {
                    averageRating = 0.0,
                    reviewCount = 0
                });

            return Ok(new
            {
                averageRating = agg.Avg,
                reviewCount = agg.Count
            });
        }
    }
    public class ReviewCreateModel
    {
        public string Comment { get; set; } = null!;
        public int? Rating { get; set; }
        public string? GuestName { get; set; }
    }
}
