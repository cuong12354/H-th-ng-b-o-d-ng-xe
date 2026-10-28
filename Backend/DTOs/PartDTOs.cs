using System.ComponentModel.DataAnnotations;

namespace VehicleCare.API.DTOs
{
    public class CreatePartRequest
    {
        [Required(ErrorMessage = "Tên phụ tùng không được để trống")]
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        public string? Category { get; set; } = "SPARE_PART";
    }

    public class UpdatePartRequest
    {
        [Required(ErrorMessage = "Tên phụ tùng không được để trống")]
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        public string? Category { get; set; } = "SPARE_PART";
    }
}
