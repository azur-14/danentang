using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ProductManagementService.Models
{
    public class Review
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }
        public string ProductId { get; set; } = null!;
        public string? UserId { get; set; }
        public string? GuestName { get; set; }
        public string Comment { get; set; } = null!;
        public int? Rating { get; set; } 
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

}