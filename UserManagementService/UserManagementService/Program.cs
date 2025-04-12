using Microsoft.EntityFrameworkCore;
using UserManagementService.Data;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using System;

var builder = WebApplication.CreateBuilder(args);

// Thêm dịch vụ controller
builder.Services.AddControllers();

// Thêm DbContext sử dụng MySQL
builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        new MySqlServerVersion(new Version(8, 0, 25))  // Thay đổi phiên bản theo MySQL của bạn
    )
);

// Thêm Swagger
builder.Services.AddSwaggerGen();

// Thêm CORS cho Flutter Web/Mobile
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder => builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
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

// Bật CORS (quan trọng cho Flutter Web)
app.UseCors("AllowAll");

// 👉 Có thể bật HTTPS nếu bạn test bằng Postman hoặc mobile
// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
