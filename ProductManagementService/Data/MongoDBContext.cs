using MongoDB.Driver;
using Microsoft.Extensions.Configuration;
using ProductManagementService.Models;
using AppTag = ProductManagementService.Models.Tag;

namespace ProductManagementService.Data
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _db;

        public MongoDbContext(IConfiguration config)
        {
            var client = new MongoClient(config["MongoConnection:ConnectionString"]);
            _db = client.GetDatabase(config["MongoConnection:Database"]);
        }
        public IMongoCollection<AppTag> Tags => _db.GetCollection<AppTag>("tags");
        public IMongoCollection<ProductTag> ProductTags => _db.GetCollection<ProductTag>("product_tags");
        public IMongoCollection<Product> Products => _db.GetCollection<Product>("products");
        public IMongoCollection<Category> Categories => _db.GetCollection<Category>("categories");
        public IMongoCollection<Review> Reviews => _db.GetCollection<Review>("reviews");
    }
}
