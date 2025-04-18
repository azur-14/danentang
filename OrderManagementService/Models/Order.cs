using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace OrderManagementService.Models
{
    public class Order
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        public string UserId { get; set; }

        public string OrderNumber { get; set; }

        public ShippingAddress ShippingAddress { get; set; }

        public List<OrderItem> Items { get; set; }

        public decimal TotalAmount { get; set; }

        public decimal DiscountAmount { get; set; } = 0;

        public string CouponCode { get; set; }

        public int LoyaltyPointsUsed { get; set; } = 0;

        public string Status { get; set; } = "pending";

        public List<OrderStatusHistory> StatusHistory { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
