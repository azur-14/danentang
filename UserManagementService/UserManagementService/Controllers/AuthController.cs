using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
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
        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmail(string email)
        {
            var exists = await _context.Users.Find(u => u.Email == email).AnyAsync();
            return Ok(new { exists });
        }

        // --- 2. Đăng ký tài khoản ---
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
                LoyaltyPoints = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Addresses = new List<Address>()
            };

            // Thêm địa chỉ nếu có
            if (!string.IsNullOrEmpty(dto.AddressLine1))
            {
                var address = new Address
                {
                    AddressLine1 = dto.AddressLine1,
                    AddressLine2 = dto.AddressLine2,
                    City = dto.City,
                    State = dto.State,
                    ZipCode = dto.ZipCode,
                    Country = dto.Country,
                    IsDefault = true,
                    CreatedAt = DateTime.UtcNow
                };

                user.Addresses.Add(address);
            }

            await _context.Users.InsertOneAsync(user);
            return Ok("User registered successfully.");
        }

        // --- 3. Đăng nhập và sinh JWT ---
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var user = await _context.Users.Find(u => u.Email == dto.Email).FirstOrDefaultAsync();
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

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["TokenKey"] ?? throw new Exception("TokenKey is missing")));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.AddHours(1),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
    public class RegisterDto
    {
        public string Email { get; set; } = null!;
        public string FullName { get; set; } = null!;
        public string Password { get; set; } = null!;

        public string? AddressLine1 { get; set; }
        public string? AddressLine2 { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? ZipCode { get; set; }
        public string? Country { get; set; }
    }

    public class LoginDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
    }
}
