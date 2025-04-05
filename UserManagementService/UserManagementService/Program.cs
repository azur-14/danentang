using Microsoft.EntityFrameworkCore;
using UserManagementService.Data;

var builder = WebApplication.CreateBuilder(args);

// Thêm dịch vụ cho controllers
builder.Services.AddControllers();

// Thêm Swagger generator vào DI container
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Cấu hình Swagger: 
if (app.Environment.IsDevelopment())
{
    // Kích hoạt middleware tạo Swagger JSON
    app.UseSwagger();

    // Kích hoạt Swagger UI, bạn có thể tùy chỉnh đường dẫn hiển thị Swagger UI
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
        // c.RoutePrefix = string.Empty; // nếu muốn Swagger UI hiển thị tại root (ví dụ: https://localhost:5001/)
    });
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
