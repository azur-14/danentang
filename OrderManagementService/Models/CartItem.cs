using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

namespace OrderManagementService.Models

{

    public class CartItem
    {
        // ID sản phẩm chung
        [BsonRepresentation(BsonType.ObjectId)]
        public string ProductId { get; set; }

        // Nếu sản phẩm có variant thì gán, nếu không thì null và sẽ bị BsonIgnore khi lưu
        [BsonRepresentation(BsonType.ObjectId)]
        [BsonIgnoreIfNull]
        public string ProductVariantId { get; set; }

        public int Quantity { get; set; }
    }
}
