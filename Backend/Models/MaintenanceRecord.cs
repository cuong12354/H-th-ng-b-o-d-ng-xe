using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace VehicleCare.API.Models
{
    public class MaintenanceRecord
    {
        public int Id { get; set; }
        public int VehicleId { get; set; }
        public DateTime RecordDate { get; set; }
        public int Odometer { get; set; }
        public string ServicesPerformed { get; set; } = string.Empty; // Comma separated or JSON
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalCost { get; set; }
        public string StaffName { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;

        public Vehicle? Vehicle { get; set; }
        public ICollection<MaintenancePart> MaintenanceParts { get; set; } = new List<MaintenancePart>();
    }
}
