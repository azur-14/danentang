using OrderManagementService.Data;
using OrderManagementService.Services;
using RabbitMQ.Client;

var builder = WebApplication.CreateBuilder(args);

// 0. Đọc cấu hình 2 URL service từ appsettings.json
var productServiceUrl = builder.Configuration["ProductServiceUrl"]!;
var userServiceUrl = builder.Configuration["UserServiceUrl"]!;

// 1. MongoDbContext
builder.Services.AddSingleton<MongoDbContext>();

// 2. Đăng ký HttpClient cho ProductService và UserService
builder.Services.AddHttpClient("ProductService", client =>
{
    client.BaseAddress = new Uri(productServiceUrl);
});
builder.Services.AddHttpClient("UserService", client =>
{
    client.BaseAddress = new Uri(userServiceUrl);
});

// 3. CORS cho Flutter/web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
});

// 4. Controllers + Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 5. RabbitMQ – khởi tạo Connection/Channel chung
var factory = new ConnectionFactory { HostName = builder.Configuration["RabbitMQ:Host"] ?? "localhost" };
var connection = factory.CreateConnection();
var channel = connection.CreateModel();
builder.Services.AddSingleton<IModel>(channel);
builder.Services.AddSingleton<RabbitMQPublisher>();

var app = builder.Build();

// 6. Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();
app.Run();
