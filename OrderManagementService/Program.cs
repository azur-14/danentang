using OrderManagementService.Data;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

// Thêm dịch vụ controller
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Thêm MongoDbContext
builder.Services.AddSingleton<MongoDbContext>();

// Thêm Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Thêm CORS cho Flutter Web/Mobile
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});
builder.Services.AddHttpClient("ProductService", client =>
{
    client.BaseAddress = new Uri("http://localhost:5011/api/"); // URL ProductService
});

var app = builder.Build();

// Kích hoạt Swagger ở môi trường dev
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
    });
}

app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();
