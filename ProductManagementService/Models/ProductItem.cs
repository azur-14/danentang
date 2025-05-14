using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ProductManagementService.Models
{
    [BsonIgnoreExtraElements]
    public class ProductItem
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = null!;

        // Liên kết đến Product cha
        [BsonElement("productId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string ProductId { get; set; } = null!;

        // Liên kết đến Variant cụ thể
        [BsonElement("variantId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string VariantId { get; set; } = null!;

        [BsonElement("serialNumber")]
        public string? SerialNumber { get; set; }

        [BsonElement("status")]
        public string Status { get; set; } = "available"; // available, sold, reserved, etc.

        [BsonElement("soldToUserId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? SoldToUserId { get; set; } // Nếu đã bán, ghi nhận người mua

        [BsonElement("soldAt")]
        public DateTime? SoldAt { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; }

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}
