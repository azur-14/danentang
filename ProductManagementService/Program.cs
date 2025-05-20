using ProductManagementService.Data;
using ProductManagementService.WebSockets; // ✅ Quan trọng!
using Microsoft.Extensions.Options;
using ProductManagementService.Services;
using RabbitMQ.Client;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Thêm MongoDbContext
builder.Services.AddSingleton<MongoDbContext>();

// CORS cho Flutter Web/Mobile
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

var app = builder.Build();

// Swagger UI cho môi trường dev
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
    });
}

app.UseCors("AllowAll");
// ĐÂY! WebSocketOptions nên đặt sau CORS, trước UseWebSockets:
var webSocketOptions = new WebSocketOptions
{
    KeepAliveInterval = TimeSpan.FromMinutes(2),
    AllowedOrigins = { "*" } // hoặc: { "https://your-frontend.com" }
};
app.UseWebSockets(webSocketOptions);

// Middleware xử lý WebSocket request
app.Use(async (context, next) =>
{
    if (context.Request.Path == "/ws/review-stream")
    {
        if (context.WebSockets.IsWebSocketRequest)
        {
            using var webSocket = await context.WebSockets.AcceptWebSocketAsync();
            await ReviewWebSocketHandler.HandleAsync(webSocket);
        }
        else
        {
            context.Response.StatusCode = 400;
        }
    }
    else
    {
        await next();
    }
});
// Lấy MongoDbContext
var mongoContext = app.Services.GetRequiredService<MongoDbContext>();

// ✅ Bắt đầu consumer cho RabbitMQ (bất đồng bộ)
Task.Run(() => RabbitMQConsumer.Start(mongoContext.Products));

app.UseAuthorization();
app.MapControllers();

app.Run();
