using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace ProductManagementService.Models
{
    [BsonIgnoreExtraElements]
    public class Product
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = null!;

        [BsonElement("name")]
        public string Name { get; set; } = null!;

        [BsonElement("brand")]
        public string? Brand { get; set; }

        [BsonElement("description")]
        public string? Description { get; set; }

        // ⭐ Đã bỏ hoàn toàn trường Price ở Product

        [BsonElement("discountPercentage")]
        public int DiscountPercentage { get; set; }

        [BsonElement("categoryId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string CategoryId { get; set; } = null!;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; }

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; }

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
        public string Id { get; set; } = null!;

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
        public string Id { get; set; } = null!;

        [BsonElement("variantName")]
        public string VariantName { get; set; } = null!;

        // ⭐ Giữ nguyên AdditionalPrice để tránh lỗi
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
