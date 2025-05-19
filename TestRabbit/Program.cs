using RabbitMQ.Client;

var factory = new ConnectionFactory() { HostName = "localhost" };
using var conn = factory.CreateConnection();
using IModel channel = conn.CreateModel();

Console.WriteLine("✅ IModel OK!");
