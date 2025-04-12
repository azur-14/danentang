using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserManagementService.Data;
using UserManagementService.Models;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IdentityModel.Tokens.Jwt;
using System.Threading.Tasks;                // <<--
using Microsoft.Extensions.Configuration;    // <<--


namespace UserManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly UserDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(UserDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }
        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmail(string email)
        {
            var exists = await _context.Users.AnyAsync(u => u.Email == email);
            return Ok(new { exists });
        }

        // Đăng ký người dùng
        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
                return BadRequest("Email already exists.");

            var user = new User
            {
                Email = dto.Email,
                FullName = dto.FullName,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password)
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Thêm địa chỉ giao hàng nếu có
            if (!string.IsNullOrEmpty(dto.AddressLine1))
            {
                var address = new Address
                {
                    UserId = user.Id,
                    AddressLine1 = dto.AddressLine1,
                    AddressLine2 = dto.AddressLine2,
                    City = dto.City,
                    State = dto.State,
                    ZipCode = dto.ZipCode,
                    Country = dto.Country,
                    IsDefault = true
                };
                _context.Addresses.Add(address);
                await _context.SaveChangesAsync();
            }

            return Ok("User registered successfully.");
        }

        // Đăng nhập người dùng
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized("Invalid credentials.");

            // Tạo JWT token
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Email),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["TokenKey"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: creds
            );
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);
            return Ok(new { token = tokenString });
        }
    }

    // DTO cho đăng ký
    public class RegisterDto
    {
        public string Email { get; set; }
        public string FullName { get; set; }
        public string Password { get; set; }
        public string AddressLine1 { get; set; }
        public string AddressLine2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string ZipCode { get; set; }
        public string Country { get; set; }
    }

    // DTO cho đăng nhập
    public class LoginDto
    {
        public string Email { get; set; }
        public string Password { get; set; }
    }
}
