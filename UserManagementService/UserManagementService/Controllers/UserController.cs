using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UserManagementService.Data;
using UserManagementService.Models;
using MongoDB.Bson;
using System.Linq;
namespace UserManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly MongoDbContext _context;

        public UserController(MongoDbContext context)
        {
            _context = context;
        }

        [HttpGet("complained")]
        public async Task<IActionResult> GetUsersWhoComplained()
        {
            // 1) Lấy tất cả senderId (string)
            var allSenderIds = await _context.ComplaintMessages
                .Find(c => c.IsFromCustomer)
                .Project(c => c.SenderId)
                .ToListAsync();

            // 2) Distinct + loại bỏ null/empty
            var distinctSenderIds = allSenderIds
                .Where(id => !string.IsNullOrWhiteSpace(id))
                .Distinct()
                .ToList();

            // 3) Nếu không có thì trả mảng rỗng
            if (!distinctSenderIds.Any())
                return Ok(new object[0]);

            // 4) Query users với $in
            var users = await _context.Users
                .Find(u => distinctSenderIds.Contains(u.Id!))
                .ToListAsync();

            // 5) Map về DTO trả client
            var result = users.Select(u => new
            {
                id = u.Id,
                fullName = u.FullName,
                avatarUrl = u.AvatarUrl,
                email = u.Email
            });

            return Ok(result);
        }


        // --- 1. GET all users, optional excludeRole (e.g. admin)  ---
        // GET /api/user?excludeRole=admin
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] string? excludeRole)
        {
            var filter = Builders<User>.Filter.Empty;
            if (!string.IsNullOrEmpty(excludeRole))
                filter = Builders<User>.Filter.Ne(u => u.Role, excludeRole);

            var users = await _context.Users.Find(filter).ToListAsync();
            return Ok(users);
        }

        // --- 2. GET single user by ID ---
        // GET /api/user/{id}
        [HttpGet("{id:length(24)}")]
        public async Task<IActionResult> GetById(string id)
        {
            var user = await _context.Users.Find(u => u.Id == id).FirstOrDefaultAsync();
            if (user == null) return NotFound();
            return Ok(user);
        }

        // --- 3. PUT update entire user (profile + addresses) ---
        // PUT /api/user/{id}
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] User dto)
        {
            if (dto.Id != id)
                return BadRequest("ID in URL must match ID in payload.");

            // preserve CreatedAt from existing doc
            var existing = await _context.Users.Find(u => u.Id == id).FirstOrDefaultAsync();
            if (existing == null) return NotFound();

            dto.CreatedAt = existing.CreatedAt;
            dto.UpdatedAt = DateTime.UtcNow;

            var result = await _context.Users.ReplaceOneAsync(u => u.Id == id, dto);
            if (result.MatchedCount == 0) return NotFound();

            return NoContent();
        }

        // --- 4. DELETE a user entirely ---
        // DELETE /api/user/{id}
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _context.Users.DeleteOneAsync(u => u.Id == id);
            if (result.DeletedCount == 0) return NotFound();
            return NoContent();
        }

        // --- 5. Change status (e.g. ban user) ---
        // PUT /api/user/{id}/status
        [HttpPut("{id:length(24)}/status")]
        public async Task<IActionResult> ChangeStatus(string id, [FromBody] StatusDto dto)
        {
            var update = Builders<User>.Update
                .Set(u => u.Status, dto.Status)
                .Set(u => u.UpdatedAt, DateTime.UtcNow);

            var result = await _context.Users.UpdateOneAsync(u => u.Id == id, update);
            if (result.MatchedCount == 0) return NotFound();

            return NoContent();
        }

        // --- 6. Address sub‐resource CRUD ---

        // GET all addresses for a user
        // GET /api/user/{id}/addresses
        [HttpGet("{id:length(24)}/addresses")]
        public async Task<IActionResult> GetAddresses(string id)
        {
            var user = await _context.Users.Find(u => u.Id == id).FirstOrDefaultAsync();
            if (user == null) return NotFound();
            return Ok(user.Addresses);
        }

        // POST add a new address
        // POST /api/user/{id}/addresses
        [HttpPost("{id:length(24)}/addresses")]
        public async Task<IActionResult> AddAddress(string id, [FromBody] Address a)
        {
            a.CreatedAt = DateTime.UtcNow;
            var update = Builders<User>.Update
                .Push(u => u.Addresses, a)
                .Set(u => u.UpdatedAt, DateTime.UtcNow);

            var result = await _context.Users.UpdateOneAsync(u => u.Id == id, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // PUT update an existing address by index
        // PUT /api/user/{id}/addresses/{index}
        [HttpPut("{id:length(24)}/addresses/{index:int}")]
        public async Task<IActionResult> UpdateAddress(string id, int index, [FromBody] Address a)
        {
            a.CreatedAt = DateTime.UtcNow; // or preserve original?
            var update = Builders<User>.Update
                .Set(u => u.Addresses[index], a)
                .Set(u => u.UpdatedAt, DateTime.UtcNow);

            var result = await _context.Users.UpdateOneAsync(u => u.Id == id, update);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // DELETE an address by index
        // DELETE /api/user/{id}/addresses/{index}
        [HttpDelete("{id:length(24)}/addresses/{index:int}")]
        public async Task<IActionResult> DeleteAddress(string id, int index)
        {
            // pull by position: we read, remove in-memory, then replace entire array
            var user = await _context.Users.Find(u => u.Id == id).FirstOrDefaultAsync();
            if (user == null) return NotFound();
            if (index < 0 || index >= user.Addresses.Count) return BadRequest("Invalid address index.");

            user.Addresses.RemoveAt(index);
            user.UpdatedAt = DateTime.UtcNow;

            var result = await _context.Users.ReplaceOneAsync(u => u.Id == id, user);
            return result.MatchedCount == 1 ? NoContent() : NotFound();
        }
        // --- 7. GET user by email ---
        // GET /api/user/by-email?email=abc@example.com
        [HttpGet("by-email")]
        public async Task<IActionResult> GetByEmail([FromQuery] string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return BadRequest("Email is required.");

            var user = await _context.Users.Find(u => u.Email == email).FirstOrDefaultAsync();
            if (user == null)
                return NotFound();

            return Ok(user);
        }
        // PATCH: api/users/{id}/loyalty
        [HttpPatch("{id:length(24)}/loyalty")]
        public async Task<IActionResult> UpdateLoyalty(string id, [FromBody] LoyaltyPointDto dto)
        {
            // dto.LoyaltyPointsDelta là số điểm muốn cộng (+) hoặc trừ (-)
            var update = Builders<User>.Update
                .Inc(u => u.LoyaltyPoints, dto.LoyaltyPointsDelta)
                .Set(u => u.UpdatedAt, DateTime.UtcNow);

            var result = await _context.Users.UpdateOneAsync(u => u.Id == id, update);

            if (result.MatchedCount == 0)
                return NotFound("User not found.");

            return NoContent();
        }
    }
    public class LoyaltyPointDto
    {
        public int LoyaltyPointsDelta { get; set; }
    }
    public class StatusDto
    {
        public string Status { get; set; } = null!;
    }
}
