using Microsoft.EntityFrameworkCore;
using ReviewBackend.Models;

namespace ReviewBackend.Data
{
    public class ReviewDbContext : DbContext
    {
        public DbSet<Review>? Reviews { get; set; }

        public ReviewDbContext(DbContextOptions<ReviewDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Review>().OwnsMany(r => r.Reviews);
        }
    }
}