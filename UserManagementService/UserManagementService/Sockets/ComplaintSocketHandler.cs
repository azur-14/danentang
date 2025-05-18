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

            var buffer = new byte[1024 * 4];
            while (socket.State == WebSocketState.Open)
            {
                var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    _clients.Remove(socket);
                    await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Client disconnected", CancellationToken.None);
                    return;
                }

                var json = Encoding.UTF8.GetString(buffer, 0, result.Count);
                var message = JsonSerializer.Deserialize<ComplaintMessage>(json);
                if (message != null && _collection != null)
                {
                    message.CreatedAt = DateTime.UtcNow;
                    await _collection.InsertOneAsync(message);

                    var response = JsonSerializer.Serialize(message);
                    var bytes = Encoding.UTF8.GetBytes(response);

                    foreach (var client in _clients.Where(c => c.State == WebSocketState.Open))
                    {
                        await client.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                }
            }
        }
    }
}
