using System.ComponentModel.DataAnnotations;
using System.Net;

namespace UserManagementService.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required, EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string FullName { get; set; } = string.Empty;

        // Nếu bạn chắc chắn luôn gán PasswordHash
        // -> gán mặc định là string.Empty
        public string PasswordHash { get; set; } = string.Empty;

        public string Role { get; set; } = "customer";

        public int LoyaltyPoints { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // Nếu Addresses không bao giờ null, gán = new List<Address>()
        public List<Address> Addresses { get; set; } = new List<Address>();
    }


}
