using System.Net.WebSockets;
using System.Text;

namespace ProductManagementService.WebSockets
{
    public static class ReviewWebSocketHandler
    {
        private static readonly List<WebSocket> _connectedClients = new();

        public static async Task HandleAsync(WebSocket socket)
        {
            _connectedClients.Add(socket);

            var buffer = new byte[1024 * 4];

            try
            {
                while (socket.State == WebSocketState.Open)
                {
                    var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                    if (result.MessageType == WebSocketMessageType.Close)
                    {
                        await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Client closed", CancellationToken.None);
                        break;
                    }

                    // Optional: handle client message
                }
            }
            finally
            {
                _connectedClients.Remove(socket);
            }
        }

        public static async Task BroadcastNewReview(string productId, double averageRating, int reviewCount)
        {
            var message = new
            {
                productId,
                averageRating,
                reviewCount
            };

            var json = Encoding.UTF8.GetBytes(System.Text.Json.JsonSerializer.Serialize(message));
            var segment = new ArraySegment<byte>(json);

            foreach (var socket in _connectedClients.ToList())
            {
                if (socket.State == WebSocketState.Open)
                {
                    try
                    {
                        await socket.SendAsync(segment, WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    catch
                    {
                        _connectedClients.Remove(socket); // Remove bad connection
                    }
                }
            }
        }
    }
}
