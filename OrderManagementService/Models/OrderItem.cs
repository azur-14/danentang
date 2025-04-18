using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace OrderManagementService.Models

{
    public class OrderItem
    {
        public string ProductVariantId { get; set; }

        public string ProductName { get; set; }

        public string VariantName { get; set; }

        public int Quantity { get; set; }

        public decimal Price { get; set; }
    }
}
