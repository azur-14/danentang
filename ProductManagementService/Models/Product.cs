using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ProductManagementService.Models
{

    public class Product
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        public string Name { get; set; } = null!;
        public string? Brand { get; set; }
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int DiscountPercentage { get; set; } = 0;
        public string CategoryId { get; set; } = null!;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("images")]
        public List<ProductImage> Images { get; set; } = new();

        [BsonElement("variants")]
        public List<ProductVariant> Variants { get; set; } = new();
    }

    public class ProductImage
    {
        public string Url { get; set; } = null!;
        public int SortOrder { get; set; } = 1;
    }

    public class ProductVariant
    {
        public string VariantName { get; set; } = null!;
        public decimal AdditionalPrice { get; set; } = 0;
        public int Inventory { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
