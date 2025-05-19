using MongoDB.Driver;
using ProductManagementService.Models;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace ProductManagementService.Services
{
    public class RabbitMQConsumer
    {
        public static void Start(IMongoCollection<Product> productCollection)
        {
            var factory = new ConnectionFactory() { HostName = "localhost" }; // Nếu Docker thì là "rabbitmq"
            var connection = factory.CreateConnection();
            var channel = connection.CreateModel();

            channel.QueueDeclare(queue: "stock.decrease",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += async (model, ea) =>
            {
                try
                {
                    var body = ea.Body.ToArray();
                    var message = Encoding.UTF8.GetString(body);
                    var data = JsonSerializer.Deserialize<StockDecreaseMessage>(message);

                    if (data != null)
                    {
                        // ✅ Tìm và giảm tồn kho
                        var filter = Builders<Product>.Filter.ElemMatch(p => p.Variants, v => v.Id == data.variantId);
                        var update = Builders<Product>.Update.Inc("variants.$.inventory", -data.quantity);
                        var result = await productCollection.UpdateOneAsync(filter, update);

                        Console.WriteLine($"✅ Stock updated for variant {data.variantId} (-{data.quantity})");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ Error processing stock message: {ex.Message}");
                }
            };

            channel.BasicConsume(queue: "stock.decrease",
                                 autoAck: true,
                                 consumer: consumer);

            Console.WriteLine("📥 RabbitMQConsumer is running and waiting for messages...");
        }

        private class StockDecreaseMessage
        {
            public string variantId { get; set; }
            public int quantity { get; set; }
        }
    }
}
