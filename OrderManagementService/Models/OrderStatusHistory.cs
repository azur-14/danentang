using System;
using MongoDB.Bson.Serialization.Attributes;


namespace OrderManagementService.Models
{
    public class OrderStatusHistory
    {
        [BsonElement("status")]
        public string Status { get; set; }

        [BsonElement("timestamp")]
        public DateTime Timestamp { get; set; }
    }

}
