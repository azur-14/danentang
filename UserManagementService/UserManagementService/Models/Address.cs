using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace UserManagementService.Models
{
    public class Address
    {
        [BsonElement("receiverName")]
        public string ReceiverName { get; set; } = null!;

        [BsonElement("phone")]
        public string Phone { get; set; } = string.Empty;

        [BsonElement("addressLine")]
        public string AddressLine { get; set; } = null!;

        [BsonElement("commune")]
        public string? Commune { get; set; }

        [BsonElement("district")]
        public string? District { get; set; }

        [BsonElement("city")]
        public string? City { get; set; }

        [BsonElement("isDefault")]
        public bool IsDefault { get; set; } = false;

        [BsonElement("createdAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
