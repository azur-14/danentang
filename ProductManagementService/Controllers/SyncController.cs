using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using ProductManagementService.Data;
using ProductManagementService.Models;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

[ApiController]
[Route("api/sync")]
public class SyncController : ControllerBase
{
    private readonly MongoDbContext _context;
    private readonly HttpClient _httpClient;
    private readonly string _elasticUrl;
    private readonly string _indexName;

    public SyncController(MongoDbContext context, IHttpClientFactory clientFactory, IConfiguration configuration)
    {
        _context = context;
        _httpClient = clientFactory.CreateClient();
        _elasticUrl = configuration["Elasticsearch:Url"] ?? "http://10.0.2.2:9200";
        _indexName = configuration["Elasticsearch:Index"] ?? "products";
    }

    [HttpPost("products")]
    public async Task<IActionResult> SyncProductsToElastic()
    {
        // Lấy tất cả sản phẩm từ MongoDB
        var products = await _context.Products.Find(FilterDefinition<Product>.Empty).ToListAsync();

        // Kiểm tra nếu không có sản phẩm
        if (!products.Any())
        {
            return Ok("✅ Không có sản phẩm để đồng bộ");
        }

        // Chuẩn bị dữ liệu bulk cho Elasticsearch
        var bulkData = new List<string>();
        foreach (var product in products)
        {
            // Dòng metadata cho index
            bulkData.Add(JsonSerializer.Serialize(new
            {
                index = new { _index = _indexName, _id = product.Id.ToString() }
            }));

            // Dữ liệu sản phẩm
            bulkData.Add(JsonSerializer.Serialize(new
            {
                name = product.Name,
                price = product.Price
            }));
        }

        var bulkContent = string.Join("\n", bulkData) + "\n";
        var content = new StringContent(bulkContent, Encoding.UTF8, "application/x-ndjson");

        // Gửi yêu cầu bulk đến Elasticsearch
        var response = await _httpClient.PostAsync($"{_elasticUrl}/_bulk", content);

        if (response.IsSuccessStatusCode)
        {
            return Ok("✅ Sync thành công");
        }

        // Lấy thông tin lỗi chi tiết nếu có
        var errorMessage = await response.Content.ReadAsStringAsync();
        return StatusCode(500, $"❌ Sync thất bại: {errorMessage}");
    }
}