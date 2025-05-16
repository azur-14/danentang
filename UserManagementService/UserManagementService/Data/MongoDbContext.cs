using MongoDB.Driver;
using UserManagementService.Models;
using Microsoft.Extensions.Configuration;

namespace UserManagementService.Data
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _database;

        public MongoDbContext(IConfiguration config)
        {
            var client = new MongoClient(config["MongoConnection:ConnectionString"]);
            _database = client.GetDatabase(config["MongoConnection:Database"]);
        }

        public IMongoCollection<User> Users => _database.GetCollection<User>("users");
        public IMongoCollection<ComplaintMessage> ComplaintMessages => _database.GetCollection<ComplaintMessage>("ComplaintMessages");
    }
}
