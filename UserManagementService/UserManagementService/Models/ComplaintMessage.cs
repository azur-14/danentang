using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Text.Json.Serialization;

namespace UserManagementService.Models
{
    public class ComplaintMessage
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        [JsonPropertyName("id")]
        public string? Id { get; set; }

        [BsonElement("senderId")]
        [BsonRepresentation(BsonType.ObjectId)]
        [JsonPropertyName("senderId")]
        public string SenderId { get; set; } = null!;

        [BsonElement("receiverId")]
        [BsonRepresentation(BsonType.ObjectId)]
        [JsonPropertyName("receiverId")]
        public string ReceiverId { get; set; } = null!;

        [BsonElement("content")]
        [JsonPropertyName("content")]
        public string Content { get; set; } = null!;

        [BsonElement("isFromCustomer")]
        [JsonPropertyName("isFromCustomer")]
        public bool IsFromCustomer { get; set; }

        [BsonElement("createdAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        [JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; }

        [BsonElement("imageUrl")]
        [JsonPropertyName("imageUrl")]
        public string? ImageUrl { get; set; }
    }

}
