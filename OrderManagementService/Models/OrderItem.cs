using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace OrderManagementService.Models

{
    public class OrderItem
    {
        [BsonRepresentation(BsonType.ObjectId)]
        public string ProductId { get; set; }

        [BsonRepresentation(BsonType.ObjectId)]
        public string ProductVariantId { get; set; }

        // ✅ Danh sách các ProductItem đã gán
        [BsonRepresentation(BsonType.ObjectId)]
        public List<string> ProductItemIds { get; set; } = new();

        public string ProductName { get; set; }

        public string VariantName { get; set; }

        public int Quantity { get; set; }

        public decimal Price { get; set; }
    }
}
