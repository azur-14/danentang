using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace ProductManagementService.Models
{
    // Ignore extra elements in Product documents
    [BsonIgnoreExtraElements]
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
        public int DiscountPercentage { get; set; }

        [BsonElement("categoryId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string CategoryId { get; set; } = null!;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; }

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; }

        // images mapped from array of sub‑documents that have a field "id"
        [BsonElement("images")]
        public List<ProductImage> Images { get; set; } = new();

        [BsonElement("variants")]
        public List<ProductVariant> Variants { get; set; } = new();
    }

    [BsonIgnoreExtraElements]
    public class ProductImage
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("url")]
        public string Url { get; set; } = null!;

        [BsonElement("sortOrder")]
        public int SortOrder { get; set; }
    }

    [BsonIgnoreExtraElements]
    public class ProductVariant
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("variantName")]
        public string VariantName { get; set; } = null!;

        [BsonElement("additionalPrice")]
        public decimal AdditionalPrice { get; set; }

        [BsonElement("inventory")]
        public int Inventory { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; }

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}
