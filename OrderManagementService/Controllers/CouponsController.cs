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

        // GET api/coupons
        [HttpGet]
        public async Task<ActionResult<List<Coupon>>> GetAll() =>
            await _coupons.Find(_ => true).ToListAsync();

        // GET api/coupons/{id}
        [HttpGet("{id:length(24)}")]
        public async Task<ActionResult<Coupon>> Get(string id)
        {
            var coupon = await _coupons.Find(c => c.Id == id).FirstOrDefaultAsync();
            if (coupon == null) return NotFound();
            return coupon;
        }

        // POST api/coupons
        [HttpPost]
        public async Task<ActionResult<Coupon>> Create([FromBody] Coupon coupon)
        {
            ModelState.Remove(nameof(coupon.Id));

            coupon.Id = ObjectId.GenerateNewId().ToString();
            coupon.CreatedAt = DateTime.UtcNow;
            await _coupons.InsertOneAsync(coupon);
            return CreatedAtAction(nameof(Get), new { id = coupon.Id }, coupon);
        }

        // PUT api/coupons/{id}
        [HttpPut("{id:length(24)}")]
        public async Task<IActionResult> Update(string id, [FromBody] Coupon updated)
        {
            updated.Id = id;
            var result = await _coupons.ReplaceOneAsync(c => c.Id == id, updated);
            if (result.MatchedCount == 0) return NotFound();
            return NoContent();
        }

        // DELETE api/coupons/{id}
        [HttpDelete("{id:length(24)}")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _coupons.DeleteOneAsync(c => c.Id == id);
            if (result.DeletedCount == 0) return NotFound();
            return NoContent();
        }
    }
}
