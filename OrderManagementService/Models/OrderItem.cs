using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace OrderManagementService.Models

{
    public class OrderItem
    {
        [BsonElement("productId")]
        public string ProductId { get; set; }

        [BsonElement("productVariantId")]
        public string ProductVariantId { get; set; }

        [BsonElement("productName")]
        public string ProductName { get; set; }

        [BsonElement("variantName")]
        public string VariantName { get; set; }

        [BsonElement("quantity")]
        public int Quantity { get; set; }

        [BsonElement("price")]
        public decimal Price { get; set; }

        [BsonElement("productItemIds")]
        public List<string> ProductItemIds { get; set; } = new();
    }

}
