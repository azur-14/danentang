// UserManagementService/Models/Address.cs

using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace UserManagementService.Models
{
    public class Address
    {
        [BsonElement("addressLine")]
        public string AddressLine { get; set; } = null!;

        [BsonElement("city")]
        public string? City { get; set; }

        [BsonElement("state")]
        public string? State { get; set; }

        [BsonElement("zipCode")]
        public string? ZipCode { get; set; }

        [BsonElement("country")]
        public string? Country { get; set; }

        [BsonElement("isDefault")]
        public bool IsDefault { get; set; } = false;

        [BsonElement("createdAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
