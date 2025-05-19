// ProductManagementService/Controllers/ReviewsController.cs
using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;

namespace ProductManagementService.Controllers
{
    [ApiController]
    // Gốc route cho reviews
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

        // GET  /api/products/{productId}/reviews
        [HttpGet]
        public async Task<IActionResult> GetReviews(string productId)
        {
            if (!await _products.Find(p => p.Id == productId).AnyAsync())
                return NotFound("Product not found.");

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
            if (!await _products.Find(p => p.Id == productId).AnyAsync())
                return NotFound("Product not found.");

            var userId = User.Identity?.IsAuthenticated == true
                ? User.FindFirst("sub")?.Value
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
                Sentiment = model.Sentiment, // ✅ GÁN SENTIMENT TỪ CLIENT
                CreatedAt = DateTime.UtcNow
            };


            await _reviews.InsertOneAsync(review);

            // ✅ Broadcast sau khi insert
            var ratingAgg = await _reviews.Aggregate()
                .Match(r => r.ProductId == productId && r.Rating != null)
                .Group(r => r.ProductId, g => new
                {
                    Avg = g.Average(x => x.Rating.Value),
                    Count = g.Count()
                })
                .FirstOrDefaultAsync();

            if (ratingAgg != null)
            {
                await ProductManagementService.WebSockets.ReviewWebSocketHandler
                    .BroadcastNewReview(productId, Math.Round(ratingAgg.Avg, 2), ratingAgg.Count);
            }

            // ✅ return nằm SAU cùng
            return CreatedAtAction(
                nameof(GetReviews),
                new { productId },
                review
            );

        }

        // GET  /api/products/{productId}/reviews/rating    ← note the "rating" segment
        [HttpGet("rating")]
        public async Task<IActionResult> GetRating(string productId)
        {
            // chỉ lấy những review có Rating != null
            var filter = Builders<Review>.Filter.Eq(r => r.ProductId, productId)
                         & Builders<Review>.Filter.Ne(r => r.Rating, null);

            var agg = await _reviews.Aggregate()
                .Match(filter)
                .Group(r => r.ProductId, g => new {
                    Avg = g.Average(x => x.Rating.Value),
                    Count = g.Count()
                })
                .FirstOrDefaultAsync();

            if (agg == null)
            {
                return Ok(new
                {
                    averageRating = 0.0,
                    reviewCount = 0
                });
            }

            return Ok(new
            {
                averageRating = Math.Round(agg.Avg, 2),
                reviewCount = agg.Count
            });
        }
    }

    public class ReviewCreateModel
    {
        public string Comment { get; set; } = null!;
        public int? Rating { get; set; }
        public string? GuestName { get; set; }
        public string? Sentiment { get; set; } // ✅ THÊM DÒNG NÀY
    }

}
