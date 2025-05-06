using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace ProductManagementService.Models
{
    public class Product
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }
        [BsonElement("name")]
        public string Name { get; set; } = null!;

        [BsonElement("brand")]
        public string? Brand { get; set; }

        [BsonElement("description")]
        public string? Description { get; set; }

        [BsonElement("price")]
        public decimal Price { get; set; }

        [BsonElement("discountPercentage")]
        public int DiscountPercentage { get; set; } = 0;

        [BsonElement("categoryId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string CategoryId { get; set; } = null!;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("images")]
        public List<ProductImage> Images { get; set; } = new();

        [BsonElement("variants")]
        public List<ProductVariant> Variants { get; set; } = new();
    }

    public class ProductImage
    {
        [BsonElement("url")]
        public string Url { get; set; } = null!;

        [BsonElement("sortOrder")]
        public int SortOrder { get; set; } = 1;
    }

    public class ProductVariant
    {
        [BsonElement("variantName")]
        public string VariantName { get; set; } = null!;

        [BsonElement("additionalPrice")]
        public decimal AdditionalPrice { get; set; } = 0;

        [BsonElement("inventory")]
        public int Inventory { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
