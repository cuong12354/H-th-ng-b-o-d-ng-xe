namespace VehicleCare.API.DTOs
{
    public class ServiceResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int EstimatedMinutes { get; set; }
        public string Category { get; set; } = string.Empty;
        public bool IsPopular { get; set; }
    }

    public class CreateServiceRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int EstimatedMinutes { get; set; }
        public string Category { get; set; } = string.Empty;
        public bool IsPopular { get; set; }
    }
}
