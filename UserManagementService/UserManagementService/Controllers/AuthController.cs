using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using System;
using System.Net;
using System.Net.Mail;
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

        // --- 1. Kiểm tra email kèm isEmailVerified ---
        // GET /api/auth/check-email?email=...
        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmail([FromQuery] string email)
        {
            var user = await _context.Users
                .Find(u => u.Email == email)
                .FirstOrDefaultAsync();

            if (user == null)
                return Ok(new { exists = false, isEmailVerified = false });

            return Ok(new { exists = true, isEmailVerified = user.IsEmailVerified });
        }


        // --- 2. Đăng ký hoặc cập nhật thông tin user ---
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            // Tìm user theo email
            var existing = await _context.Users
                .Find(u => u.Email == dto.Email)
                .FirstOrDefaultAsync();

            if (existing != null)
            {
                // Cập nhật thông tin mới, bật verify
                var update = Builders<User>.Update
                    .Set(u => u.FullName, dto.FullName)
                    .Set(u => u.PasswordHash, BCrypt.Net.BCrypt.HashPassword(dto.Password))
                    .Set(u => u.IsEmailVerified, true)
                    .Set(u => u.Status, "Active")
                    .Set(u => u.UpdatedAt, DateTime.UtcNow);

                // Nếu có AddressLine, upsert Address mặc định
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
                    update = update.Push(u => u.Addresses, address);
                }

                await _context.Users.UpdateOneAsync(
                    u => u.Id == existing.Id,
                    update
                );

                return Ok("User thông tin đã được cập nhật và kích hoạt tài khoản.");
            }

            // Nếu chưa có user thì tạo mới
            var user = new User
            {
                Email = dto.Email,
                FullName = dto.FullName,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = "customer",
                Status = "Active",
                LoyaltyPoints = 0,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Addresses = new List<Address>()
            };
            if (!string.IsNullOrEmpty(dto.AddressLine))
            {
                user.Addresses.Add(new Address
                {
                    ReceiverName = dto.ReceiverName ?? dto.FullName,
                    Phone = dto.Phone ?? "",
                    AddressLine = dto.AddressLine,
                    Commune = dto.Commune,
                    District = dto.District,
                    City = dto.City,
                    IsDefault = true,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await _context.Users.InsertOneAsync(user);
            return Ok("User đăng ký thành công.");
        }

        // Đăng ký user guest (isEmailVerified = false)
        [HttpPost("register-guest")]
        public async Task<IActionResult> RegisterGuest([FromBody] RegisterGuestDto dto)
        {
            var exists = await _context.Users.Find(u => u.Email == dto.Email).FirstOrDefaultAsync();
            if (exists != null)
            {
                return Ok(new
                {
                    id = exists.Id,
                    email = exists.Email,
                    fullName = exists.FullName,
                    role = exists.Role,
                    status = exists.Status,
                    isEmailVerified = exists.IsEmailVerified,
                    createdAt = exists.CreatedAt,
                    updatedAt = exists.UpdatedAt
                });
            }

            var guest = new User
            {
                Email = dto.Email,
                FullName = dto.FullName ?? "Guest",
                PasswordHash = "",
                Role = "customer",
                Status = "Active",
                LoyaltyPoints = 0,
                IsEmailVerified = false,   // <-- Quan trọng: guest thì chưa xác thực mail
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Addresses = new List<Address>()
            };

            await _context.Users.InsertOneAsync(guest);
            return Ok(new
            {
                id = guest.Id,
                email = guest.Email,
                fullName = guest.FullName,
                role = guest.Role,
                status = guest.Status,
                isEmailVerified = guest.IsEmailVerified,
                createdAt = guest.CreatedAt,
                updatedAt = guest.UpdatedAt
            });
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
        [HttpPost("forgot-password")]
        public async Task<IActionResult> SendOtp([FromBody] ForgotPasswordDto dto)
        {
            // 1. Kiểm tra email tồn tại
            var userExists = await _context.Users
                .Find(u => u.Email == dto.Email)
                .AnyAsync();
            if (!userExists)
                return BadRequest("Email không tồn tại.");

            // 2. Sinh mã OTP 6 chữ số
            var otp = new Random().Next(100000, 999999).ToString();

            // 3. Đọc cấu hình SMTP
            var smtpHost = _configuration["Smtp:Host"]!;
            var smtpPort = int.Parse(_configuration["Smtp:Port"]!);
            var smtpUser = _configuration["Smtp:Username"]!;
            var smtpPass = _configuration["Smtp:Password"]!;
            var fromEmail = _configuration["Smtp:FromEmail"]!;

            // 4. Gửi email
            try
            {
                var mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Hoalahe");
                mail.To.Add(dto.Email);
                mail.Subject = "Mã OTP đặt lại mật khẩu";
                mail.Body = $"Mã OTP của bạn là: <b>{otp}</b> (hết hạn sau 5 phút)";
                mail.IsBodyHtml = true;

                using var client = new SmtpClient(smtpHost, smtpPort)
                {
                    Credentials = new NetworkCredential(smtpUser, smtpPass),
                    EnableSsl = true
                };
                await client.SendMailAsync(mail);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Gửi email thất bại: {ex.Message}");
            }

            // 5. Trả OTP về client
            return Ok(new { otp });
        }

        /// <summary>
        /// POST /api/auth/reset-password
        /// </summary>
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            // 1. Tìm user theo email
            var filter = Builders<User>.Filter.Eq(u => u.Email, dto.Email);
            var user = await _context.Users.Find(filter).FirstOrDefaultAsync();
            if (user == null)
                return NotFound("Không tìm thấy user với email này.");

            // 2. Hash mật khẩu mới
            var newHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);

            // 3. Update vào Mongo
            var update = Builders<User>.Update
                .Set(u => u.PasswordHash, newHash)
                .Set(u => u.UpdatedAt, DateTime.UtcNow);

            await _context.Users.UpdateOneAsync(filter, update);

            return Ok(new { message = "Đổi mật khẩu thành công." });
        }
    }

    // --- DTO cho đổi mật khẩu ---
    public class ResetPasswordDto
    {
        public string Email { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
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
    // DTO cho register guest
    public class RegisterGuestDto
    {
        public string Email { get; set; } = null!;
        public string? FullName { get; set; }
    }
    public class ForgotPasswordDto
    {
        public string Email { get; set; } = null!;
    }
    // --- DTO nhận từ client khi login ---
    public class LoginDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
    }
}
