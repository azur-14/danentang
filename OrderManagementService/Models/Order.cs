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

        [BsonElement("userId")]
        public string UserId { get; set; }

        [BsonElement("orderNumber")]
        public string OrderNumber { get; set; }

        [BsonElement("shippingAddress")]
        public ShippingAddress ShippingAddress { get; set; }

        [BsonElement("items")]
        public List<OrderItem> Items { get; set; }

        [BsonElement("totalAmount")]
        public decimal TotalAmount { get; set; }

        [BsonElement("discountAmount")]
        public decimal DiscountAmount { get; set; } = 0;

        [BsonElement("couponCode")]
        public string CouponCode { get; set; }

        [BsonElement("loyaltyPointsUsed")]
        public int LoyaltyPointsUsed { get; set; } = 0;

        [BsonElement("loyaltyPointsEarned")]
        public int LoyaltyPointsEarned { get; set; } = 0;

        [BsonElement("status")]
        public string Status { get; set; } = "pending";

        [BsonElement("statusHistory")]
        public List<OrderStatusHistory> StatusHistory { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class ShippingAddress
    {
        [BsonElement("receiverName")]
        public string ReceiverName { get; set; }

        [BsonElement("phoneNumber")]
        public string PhoneNumber { get; set; }

        [BsonElement("addressLine")]
        public string AddressLine { get; set; }

        [BsonElement("ward")]
        public string Ward { get; set; }

        [BsonElement("district")]
        public string District { get; set; }

        [BsonElement("city")]
        public string City { get; set; }
    }


}
