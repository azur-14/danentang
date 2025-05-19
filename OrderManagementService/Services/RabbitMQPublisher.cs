using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace OrderManagementService.Services
{
    public class RabbitMQPublisher
    {
        private readonly IModel _channel;

        public RabbitMQPublisher(IModel channel) // ✅ KHÔNG tự tạo trong đây nữa!
        {
            _channel = channel;

            _channel.QueueDeclare(queue: "stock.decrease",
                                  durable: false,
                                  exclusive: false,
                                  autoDelete: false,
                                  arguments: null);
        }

        public void PublishStockDecrease(string variantId, int quantity)
        {
            var message = new { variantId, quantity };
            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

            _channel.BasicPublish(exchange: "",
                                  routingKey: "stock.decrease",
                                  basicProperties: null,
                                  body: body);

            Console.WriteLine($"[RabbitMQPublisher] Stock decreased for {variantId}, quantity: {quantity}");
        }
    }
}
