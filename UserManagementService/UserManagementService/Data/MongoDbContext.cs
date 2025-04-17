using MongoDB.Driver;
using Microsoft.Extensions.Configuration;
using UserManagementService.Models;

namespace UserManagementService.Data
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _database;

        public MongoDbContext(IConfiguration config)
        {
            var client = new MongoClient(config.GetConnectionString("MongoDb"));
            _database = client.GetDatabase("UserService");
        }

        public IMongoCollection<User> Users => _database.GetCollection<User>("Users");
    }
}
