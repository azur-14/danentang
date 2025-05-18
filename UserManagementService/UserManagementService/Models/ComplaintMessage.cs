using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace UserManagementService.Models
{
    public class ComplaintMessage
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("senderId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string SenderId { get; set; } = null!;

        [BsonElement("receiverId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string ReceiverId { get; set; } = null!;

        [BsonElement("content")]
        public string Content { get; set; } = null!;

        [BsonElement("isFromCustomer")]
        public bool IsFromCustomer { get; set; }

        [BsonElement("createdAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime CreatedAt { get; set; }

        // Nếu bạn muốn hỗ trợ gửi ảnh (imageUrl) như trong dữ liệu Mongo:
        [BsonElement("imageUrl")]
        public string? ImageUrl { get; set; }
    }
}
