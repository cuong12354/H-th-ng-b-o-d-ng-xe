using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VehicleCare.API.Models
{
    public class Appointment
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int VehicleId { get; set; }
        public DateTime ScheduledDate { get; set; }
        public string Notes { get; set; } = string.Empty;
        public string Status { get; set; } = "PENDING"; // PENDING, CONFIRMED, REJECTED, CHECKING, MAINTENANCE, COMPLETED, CANCELLED, PAID
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalEstimatedPrice { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public User? User { get; set; }
        public Vehicle? Vehicle { get; set; }
        public ICollection<AppointmentDetail> AppointmentDetails { get; set; } = new List<AppointmentDetail>();
        public Invoice? Invoice { get; set; }
        public Review? Review { get; set; }
    }
}
