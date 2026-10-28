using System;

namespace VehicleCare.API.Models
{
    public class Review
    {
        public int Id { get; set; }
        public int AppointmentId { get; set; }
        public int Rating { get; set; } // 1-5
        public string Comment { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Appointment? Appointment { get; set; }
    }
}
