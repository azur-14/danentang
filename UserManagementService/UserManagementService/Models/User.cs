// UserManagementService/Models/User.cs

using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace UserManagementService.Models
{
    public class User
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("email")]
        public string Email { get; set; } = null!;

        [BsonElement("fullName")]
        public string FullName { get; set; } = null!;

        [BsonElement("passwordHash")]
        public string PasswordHash { get; set; } = null!;

        [BsonElement("role")]
        public string Role { get; set; } = "customer";

        // New: track account status
        [BsonElement("status")]
        public string Status { get; set; } = "Active";
        // e.g. "Active", "Suspended", "Banned"

        [BsonElement("loyaltyPoints")]
        public int LoyaltyPoints { get; set; } = 0;

        [BsonElement("gender")]
        public string? Gender { get; set; }

        [BsonElement("dateOfBirth")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime? DateOfBirth { get; set; }

        [BsonElement("phoneNumber")]
        public string? PhoneNumber { get; set; }

        [BsonElement("avatarUrl")]
        public string? AvatarUrl { get; set; }

        [BsonElement("isEmailVerified")]
        public bool IsEmailVerified { get; set; } = false;

        [BsonElement("createdAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("addresses")]
        public List<Address> Addresses { get; set; } = new();
    }
}
