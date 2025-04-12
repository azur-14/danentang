using Microsoft.EntityFrameworkCore;
using UserManagementService.Data;

var builder = WebApplication.CreateBuilder(args);

// Thêm dịch vụ controller
builder.Services.AddControllers();

// Thêm DbContext
builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

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
