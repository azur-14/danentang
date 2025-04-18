using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace OrderManagementService.Models
{
    public class Coupon
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        public string Code { get; set; }

        public decimal DiscountValue { get; set; }

        public int UsageLimit { get; set; } = 10;

        public int UsageCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
