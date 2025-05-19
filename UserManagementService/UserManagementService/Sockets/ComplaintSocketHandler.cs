using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using UserManagementService.Models;
using MongoDB.Driver;

namespace UserManagementService.Sockets
{
    public static class ComplaintSocketHandler
    {
        private static IMongoCollection<ComplaintMessage>? _collection;
        private static readonly List<WebSocket> _clients = new();

        public static void Configure(IMongoCollection<ComplaintMessage> collection)
        {
            _collection = collection;
        }

        public static async Task Handle(HttpContext context, WebSocket socket)
        {
            _clients.Add(socket);
            Console.WriteLine($"🔌 WebSocket client connected ({_clients.Count} total)");

            var buffer = new byte[1024 * 4];
            while (socket.State == WebSocketState.Open)
            {
                var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                if (result.MessageType == WebSocketMessageType.Close)
                {
                    _clients.Remove(socket);
                    await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Client disconnected", CancellationToken.None);
                    Console.WriteLine($"❌ Client disconnected. Total: {_clients.Count}");
                    return;
                }

                var json = Encoding.UTF8.GetString(buffer, 0, result.Count);
                Console.WriteLine($"📥 Tin nhắn nhận được: {json}");

                try
                {
                    var message = JsonSerializer.Deserialize<ComplaintMessage>(json);
                    if (message != null && _collection != null)
                    {
                        message.CreatedAt = DateTime.UtcNow;
                        await _collection.InsertOneAsync(message);
                        Console.WriteLine($"✅ Đã lưu vào MongoDB: {message.Content}");

                        var response = JsonSerializer.Serialize(message, new JsonSerializerOptions
                        {
                            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                        });

                        var bytes = Encoding.UTF8.GetBytes(response);

                        foreach (var client in _clients.Where(c => c.State == WebSocketState.Open))
                        {
                            await client.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, CancellationToken.None);
                            Console.WriteLine("📡 → Đã gửi lại tin nhắn cho 1 client");
                        }
                    }
                    else
                    {
                        Console.WriteLine("⚠️ Dữ liệu nhận bị null hoặc collection chưa được cấu hình");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ Lỗi xử lý tin nhắn: {ex.Message}");
                }
            }
        }
    }
}
