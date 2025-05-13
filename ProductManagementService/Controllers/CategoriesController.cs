using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/categories")]
    public class CategoriesController : ControllerBase
    {
        private readonly MongoDbContext _context;

        public CategoriesController(MongoDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> CreateCategory([FromBody] Category category)
        {
            ModelState.Remove(nameof(category.Id)); // 👈 Dòng cần thêm để tránh lỗi validation

            category.CreatedAt = DateTime.UtcNow;
            await _context.Categories.InsertOneAsync(category);
            return Ok(category);
        }
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> UpdateCategory(string id, [FromBody] Category updated)
        {
            var existing = await _context.Categories.Find(c => c.Id == id).FirstOrDefaultAsync();
            if (existing == null)
                return NotFound();

            // Ghi đè thông tin mới
            updated.Id = id;
            updated.CreatedAt = existing.CreatedAt; // Giữ nguyên thời điểm tạo

            var result = await _context.Categories.ReplaceOneAsync(c => c.Id == id, updated);

            return result.MatchedCount > 0 ? NoContent() : StatusCode(500, "Update failed.");
        }

        [HttpGet("{id:length(24)}")]
        public async Task<IActionResult> GetById(string id)
        {
            var category = await _context.Categories.Find(c => c.Id == id).FirstOrDefaultAsync();
            return category == null ? NotFound() : Ok(category);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var categories = await _context.Categories.Find(_ => true).ToListAsync();
            return Ok(categories);
        }
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> DeleteCategory(string id)
        {
            // Kiểm tra xem có sản phẩm nào đang dùng category này không
            var hasProducts = await _context.Products
                .Find(p => p.CategoryId == id)
                .AnyAsync();

            if (hasProducts)
            {
                return BadRequest("Không thể xóa vì vẫn còn sản phẩm thuộc danh mục này.");
            }

            // Thực hiện xóa
            var result = await _context.Categories.DeleteOneAsync(c => c.Id == id);

            if (result.DeletedCount == 0)
            {
                return NotFound("Danh mục không tồn tại.");
            }

            return NoContent();
        }

    }
}
