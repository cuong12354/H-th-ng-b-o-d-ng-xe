using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VehicleCare.API.Models
{
    public class Service
    {
        public int Id { get; set; }
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        [Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }
        public int EstimatedMinutes { get; set; }
        public string Category { get; set; } = string.Empty; // Maintenance, Repair, Cleaning
        public bool IsActive { get; set; } = true;
        public bool IsPopular { get; set; } = false; // Admin can toggle this

        public ICollection<AppointmentDetail> AppointmentDetails { get; set; } = new List<AppointmentDetail>();
    }
}
