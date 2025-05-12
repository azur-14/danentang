using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using UserManagementService.Data;
using UserManagementService.Models;

namespace UserManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly MongoDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(MongoDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // --- 1. Kiểm tra email ---
        // GET /api/auth/check-email?email=...
        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmail([FromQuery] string email)
        {
            var exists = await _context.Users
                .Find(u => u.Email == email)
                .AnyAsync();
            return Ok(new { exists });
        }

        // --- 2. Đăng ký tài khoản ---
        // POST /api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            // Kiểm tra email trùng
            var exists = await _context.Users.Find(u => u.Email == dto.Email).AnyAsync();
            if (exists)
                return BadRequest("Email already exists.");

            // Tạo user mới
            var user = new User
            {
                Email = dto.Email,
                FullName = dto.FullName,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = "customer",
                Status = "Active",
                LoyaltyPoints = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Addresses = new List<Address>()
            };

            // Thêm địa chỉ nếu có
            if (!string.IsNullOrEmpty(dto.AddressLine))
            {
                var address = new Address
                {
                    ReceiverName = dto.ReceiverName ?? dto.FullName,
                    Phone = dto.Phone ?? "",
                    AddressLine = dto.AddressLine,
                    Commune = dto.Commune,
                    District = dto.District,
                    City = dto.City,
                    IsDefault = true,
                    CreatedAt = DateTime.UtcNow
                };
                user.Addresses.Add(address);
            }

            await _context.Users.InsertOneAsync(user);
            return Ok("User registered successfully.");
        }

        // --- 3. Đăng nhập và sinh JWT ---
        // POST /api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var user = await _context.Users
                .Find(u => u.Email == dto.Email)
                .FirstOrDefaultAsync();

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized("Invalid credentials.");

            var token = GenerateJwtToken(user);
            return Ok(new { token });
        }

        // --- 4. Tạo JWT Token ---
        private string GenerateJwtToken(User user)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Email),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var keyBytes = Encoding.UTF8.GetBytes(
                _configuration["TokenKey"] 
                ?? throw new Exception("TokenKey is missing"));
            var key = new SymmetricSecurityKey(keyBytes);
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var jwt = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.AddHours(1),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(jwt);
        }

        // --- DTO trả về UI, loại bỏ PasswordHash, địa chỉ, v.v. ---
        public class UserDto
        {
            public string Id { get; set; } = null!;
            public string Email { get; set; } = null!;
            public string FullName { get; set; } = null!;
            public string Role { get; set; } = null!;
            public string Status { get; set; } = null!;
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        // --- 5. Lấy danh sách user, có thể exclude theo role --- 
        // GET /api/auth/users?excludeRole=admin
        [HttpGet("users")]
        public async Task<IActionResult> GetUsers([FromQuery] string? excludeRole)
        {
            var filter = Builders<User>.Filter.Empty;
            if (!string.IsNullOrEmpty(excludeRole))
            {
                filter = Builders<User>.Filter.Ne(u => u.Role, excludeRole);
            }

            var users = await _context.Users.Find(filter).ToListAsync();
            var dtos = users.Select(u => new UserDto
            {
                Id = u.Id!,
                Email = u.Email,
                FullName = u.FullName,
                Role = u.Role,
                Status = u.Status,
                CreatedAt = u.CreatedAt,
                UpdatedAt = u.UpdatedAt
            }).ToList();

            return Ok(dtos);
        }

        // --- 6. Lấy chi tiết một user theo id ---
        // GET /api/auth/users/{id}
        [HttpGet("users/{id:length(24)}")]
        public async Task<IActionResult> GetUserById(string id)
        {
            var u = await _context.Users.Find(u => u.Id == id).FirstOrDefaultAsync();
            if (u == null) return NotFound();

            var dto = new UserDto
            {
                Id = u.Id!,
                Email = u.Email,
                FullName = u.FullName,
                Role = u.Role,
                Status = u.Status,
                CreatedAt = u.CreatedAt,
                UpdatedAt = u.UpdatedAt
            };

            return Ok(dto);
        }
    }

    // ---  DTO nhận từ client khi register ---
public class RegisterDto
{
    public string Email { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string Password { get; set; } = null!;

    // Address fields
    public string? ReceiverName { get; set; }
    public string? Phone { get; set; }
    public string? AddressLine { get; set; }
    public string? Commune { get; set; }
    public string? District { get; set; }
    public string? City { get; set; }
}


    // --- DTO nhận từ client khi login ---
    public class LoginDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
    }
}
