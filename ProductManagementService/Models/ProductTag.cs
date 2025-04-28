using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ProductManagementService.Models
{
    public class ProductTag
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // Sử dụng ObjectId thay vì string cho ProductId
        [BsonElement("product_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId ProductId { get; set; }

        // Sử dụng ObjectId thay vì string cho TagId
        [BsonElement("tag_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId TagId { get; set; }
    }
}
