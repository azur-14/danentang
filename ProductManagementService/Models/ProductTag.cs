using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ProductManagementService.Models
{
    public class ProductTag
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }
        [BsonElement("product_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string ProductId { get; set; } = null!;

        [BsonElement("tag_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string TagId { get; set; } = null!;
    }
}
