namespace ReviewBackend.Models
{
    public class Review
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string UserId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public List<ReviewItem> Reviews { get; set; } = new List<ReviewItem>();
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class ReviewItem
    {
        public string Text { get; set; } = string.Empty;
        public string Sentiment { get; set; } = string.Empty;
        public string Explanation { get; set; } = string.Empty;
        public string Time { get; set; } = string.Empty;
    }
}