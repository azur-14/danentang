using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ProductManagementService.Models
{
    public class Tag
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("name")]
        public string Name { get; set; } = null!;

        [BsonElement("description")]
        public string Description { get; set; } = null!;
    }
}
