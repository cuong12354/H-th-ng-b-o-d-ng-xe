using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VehicleCare.API.Models
{
    public class Part
    {
        public int Id { get; set; }
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        [Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        [MaxLength(50)]
        public string Category { get; set; } = "SPARE_PART";

        public ICollection<MaintenancePart> MaintenanceParts { get; set; } = new List<MaintenancePart>();
    }
}
