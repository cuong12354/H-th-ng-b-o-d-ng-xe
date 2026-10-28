using System.ComponentModel.DataAnnotations;

namespace VehicleCare.API.DTOs
{
    public class CreateReviewRequest
    {
        [Required]
        public int AppointmentId { get; set; }
        [Range(1, 5)]
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
    }

    public class ReviewResponse
    {
        public int Id { get; set; }
        public int AppointmentId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
        public System.DateTime CreatedAt { get; set; }
    }
}
