using OrderManagementService.Data;
using OrderManagementService.Services;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

var builder = WebApplication.CreateBuilder(args);

// 1. Mongo + HttpClient
builder.Services.AddSingleton<MongoDbContext>();
builder.Services.AddHttpClient("ProductService", client =>
{
    client.BaseAddress = new Uri("http://localhost:5011/api/");
});

// 2. CORS cho Flutter/web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

// 3. Swagger + Controller
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 4. ✅ Khởi tạo RabbitMQ Connection/Channel duy trì sống suốt app
var factory = new ConnectionFactory() { HostName = "localhost" };
var connection = factory.CreateConnection();
var channel = connection.CreateModel();

// 5. Đăng ký RabbitMQPublisher dạng Singleton (inject được)
builder.Services.AddSingleton<IModel>(channel);
builder.Services.AddSingleton<RabbitMQPublisher>();

var app = builder.Build();

// 6. Swagger UI
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();
app.Run();
