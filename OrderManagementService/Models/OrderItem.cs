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
        [BsonIgnoreIfNull]
        public string ProductVariantId { get; set; }

        public string ProductName { get; set; }

        // Nếu có variant, show VariantName; nếu không, có thể dùng chính ProductName
        public string VariantName { get; set; }

        public int Quantity { get; set; }

        public decimal Price { get; set; }
    }
}
