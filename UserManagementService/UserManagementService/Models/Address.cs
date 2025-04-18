using MongoDB.Bson.Serialization.Attributes;


namespace UserManagementService.Models
{
    public class Address
    {
        [BsonElement("addressLine1")]
        public string AddressLine1 { get; set; } = null!;

        [BsonElement("addressLine2")]
        public string? AddressLine2 { get; set; }

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
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }


}
