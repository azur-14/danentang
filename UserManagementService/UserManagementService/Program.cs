using UserManagementService.Data;
using Microsoft.Extensions.Options;
using UserManagementService.Sockets;

var builder = WebApplication.CreateBuilder(args);

// Thêm dịch vụ controller
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
// Thêm dòng này để inject cấu hình vào controller
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

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
// Add before `app.UseAuthorization();`
app.UseWebSockets();

app.Use(async (context, next) =>
{
    if (context.Request.Path == "/ws/complaint")
    {
        if (context.WebSockets.IsWebSocketRequest)
        {
            using var webSocket = await context.WebSockets.AcceptWebSocketAsync();

            // Lấy service context
            var mongo = context.RequestServices.GetRequiredService<MongoDbContext>();
            ComplaintSocketHandler.Configure(mongo.ComplaintMessages);

            await ComplaintSocketHandler.Handle(context, webSocket);
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

app.UseAuthorization();

app.MapControllers();

app.Run();
