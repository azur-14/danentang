using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using ProductManagementService.Data;
using AppTag = ProductManagementService.Models.Tag;

namespace ProductManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TagController : ControllerBase
    {
        private readonly IMongoCollection<AppTag> _tagCollection;

        public TagController(MongoDbContext context)
        {
            _tagCollection = context.Tags;
        }

        [HttpPost]
        public async Task<IActionResult> CreateTag([FromBody] AppTag tag)
        {
            await _tagCollection.InsertOneAsync(tag);
            return Ok(tag);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllTags()
        {
            var tags = await _tagCollection.Find(_ => true).ToListAsync();
            return Ok(tags);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTag(string id)
        {
            var tag = await _tagCollection.Find(t => t.Id == id).FirstOrDefaultAsync();
            return tag == null ? NotFound() : Ok(tag);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTag(string id, [FromBody] AppTag tag)
        {
            tag.Id = id;
            var result = await _tagCollection.ReplaceOneAsync(t => t.Id == id, tag);
            return result.MatchedCount == 0 ? NotFound() : Ok(tag);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTag(string id)
        {
            var result = await _tagCollection.DeleteOneAsync(t => t.Id == id);
            return result.DeletedCount == 0 ? NotFound() : Ok(new { message = "Tag deleted" });
        }
    }
}
