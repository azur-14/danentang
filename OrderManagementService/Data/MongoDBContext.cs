using MongoDB.Driver;
using Microsoft.Extensions.Configuration;
using OrderManagementService.Models;

namespace OrderManagementService.Data
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _db;

        public MongoDbContext(IConfiguration config)
        {
            var client = new MongoClient(config["MongoConnection:ConnectionString"]);
            _db = client.GetDatabase(config["MongoConnection:Database"]);
        }

        /// <summary>
        /// Collection for shopping carts
        /// </summary>
        public IMongoCollection<Cart> Carts =>
            _db.GetCollection<Cart>("Carts");

        /// <summary>
        /// Collection for orders
        /// </summary>
        public IMongoCollection<Order> Orders =>
            _db.GetCollection<Order>("Orders");

        /// <summary>
        /// Collection for coupons
        /// </summary>
        public IMongoCollection<Coupon> Coupons =>
            _db.GetCollection<Coupon>("Coupons");
    }
}
