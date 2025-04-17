using System;

namespace OrderManagementService.Models
{
    public class OrderStatusHistory
    {
        public string Status { get; set; }

        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }
}
