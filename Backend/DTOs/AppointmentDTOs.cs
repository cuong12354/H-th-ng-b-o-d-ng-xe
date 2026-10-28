using System.Collections.Generic;

namespace VehicleCare.API.DTOs
{
    public class CreateAppointmentRequest
    {
        public int VehicleId { get; set; }
        public System.DateTime ScheduledDate { get; set; }
        public string Notes { get; set; } = string.Empty;
        public List<int> ServiceIds { get; set; } = new List<int>();
        public decimal TotalEstimatedPrice { get; set; }
    }

    public class StaffCreateAppointmentRequest
    {
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerPhone { get; set; } = string.Empty;
        public string LicensePlate { get; set; } = string.Empty;
        public string VehicleBrand { get; set; } = string.Empty;
        public string VehicleModel { get; set; } = string.Empty;
        public List<int> ServiceIds { get; set; } = new List<int>();
    }

    public class AppointmentResponse
    {
        public int Id { get; set; }
        public int VehicleId { get; set; }
        public string LicensePlate { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public System.DateTime ScheduledDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public decimal TotalEstimatedPrice { get; set; }
        public System.DateTime CreatedAt { get; set; }
        public List<string> Services { get; set; } = new List<string>();
    }
}
