using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace VehicleCare.API.Models
{
    public class Vehicle
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        [Required, MaxLength(20)]
        public string LicensePlate { get; set; } = string.Empty;
        [Required, MaxLength(50)]
        public string Brand { get; set; } = string.Empty;
        [Required, MaxLength(50)]
        public string Model { get; set; } = string.Empty;
        public int Year { get; set; }
        public string Color { get; set; } = string.Empty;
        public string VehicleType { get; set; } = string.Empty; // e.g., Scooter, Manual, Clutch
        public int CurrentOdometer { get; set; }
        public DateTime RegistrationDate { get; set; }
        
        public User? User { get; set; }
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<MaintenanceRecord> MaintenanceRecords { get; set; } = new List<MaintenanceRecord>();
    }
}
