using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using UserManagementService.Models;   // <— thêm dòng này


[ApiController]
[Route("api/[controller]")]
public class ComplaintController : ControllerBase
{
    private readonly IMongoCollection<ComplaintMessage> _collection;

    public ComplaintController(IConfiguration config)
    {
        // Đọc đúng key từ "MongoConnection" section
        var client = new MongoClient(config["MongoConnection:ConnectionString"]);
        var db = client.GetDatabase(config["MongoConnection:Database"]);
        _collection = db.GetCollection<ComplaintMessage>("ComplaintMessages");

    }

    // GET: api/complaint/chat?user1Id=abc&user2Id=xyz
    [HttpGet("chat")]
    public async Task<IActionResult> GetChat([FromQuery] string user1Id, [FromQuery] string user2Id)
    {
        var filter = Builders<ComplaintMessage>.Filter.Or(
            Builders<ComplaintMessage>.Filter.And(
                Builders<ComplaintMessage>.Filter.Eq(m => m.SenderId, user1Id),
                Builders<ComplaintMessage>.Filter.Eq(m => m.ReceiverId, user2Id)
            ),
            Builders<ComplaintMessage>.Filter.And(
                Builders<ComplaintMessage>.Filter.Eq(m => m.SenderId, user2Id),
                Builders<ComplaintMessage>.Filter.Eq(m => m.ReceiverId, user1Id)
            )
        );

        var messages = await _collection.Find(filter)
                                        .SortBy(m => m.CreatedAt)
                                        .ToListAsync();
        return Ok(messages);
    }

    // POST: api/complaint/send
    [HttpPost("send")]
    public async Task<IActionResult> SendMessage([FromBody] ComplaintMessage message)
    {
        message.CreatedAt = DateTime.UtcNow;
        await _collection.InsertOneAsync(message);
        return Ok(message);
    }
}
