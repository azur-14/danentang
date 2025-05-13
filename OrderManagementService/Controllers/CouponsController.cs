using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using OrderManagementService.Data;
using OrderManagementService.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace OrderManagementService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CouponsController : ControllerBase
    {
        private readonly IMongoCollection<Coupon> _coupons;

        public CouponsController(MongoDbContext context)
        {
            _coupons = context.Coupons;
        }

        // GET: api/coupons
        [HttpGet]
        public async Task<ActionResult<List<Coupon>>> GetAll() =>
            await _coupons.Find(_ => true).SortByDescending(c => c.CreatedAt).ToListAsync();

        // GET: api/coupons/{id}
        [HttpGet("{id:length(24)}")]
        public async Task<ActionResult<Coupon>> Get(string id)
        {
            var coupon = await _coupons.Find(c => c.Id == id).FirstOrDefaultAsync();
            return coupon == null ? NotFound() : coupon;
        }

        [HttpPost]
        public async Task<ActionResult<Coupon>> Create([FromBody] Coupon coupon)
        {
            coupon.Id = ObjectId.GenerateNewId().ToString();
            coupon.CreatedAt = DateTime.UtcNow;
            coupon.UsageCount = 0;
            coupon.OrderIds = new List<string>();

            await _coupons.InsertOneAsync(coupon);
            return CreatedAtAction(nameof(Get), new { id = coupon.Id }, coupon);
        }


        // PUT: api/coupons/{id}
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] Coupon updated)
        {
            updated.Id = id;
            var result = await _coupons.ReplaceOneAsync(c => c.Id == id, updated);
            return result.MatchedCount == 0 ? NotFound() : NoContent();
        }

        // DELETE: api/coupons/{id}
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _coupons.DeleteOneAsync(c => c.Id == id);
            return result.DeletedCount == 0 ? NotFound() : NoContent();
        }

        // POST: api/coupons/apply/{code}?orderId=xxx
        [HttpPost("apply/{code}")]
        public async Task<IActionResult> ApplyCoupon(string code, [FromQuery] string orderId)
        {
            var coupon = await _coupons.Find(c => c.Code == code).FirstOrDefaultAsync();
            if (coupon == null) return NotFound("Coupon not found.");

            if (coupon.UsageCount >= coupon.UsageLimit)
                return BadRequest("Coupon usage limit reached.");

            coupon.UsageCount++;
            coupon.OrderIds.Add(orderId);

            var result = await _coupons.ReplaceOneAsync(c => c.Id == coupon.Id, coupon);
            return result.ModifiedCount > 0 ? Ok(coupon) : StatusCode(500, "Failed to apply coupon.");
        }
    }
}