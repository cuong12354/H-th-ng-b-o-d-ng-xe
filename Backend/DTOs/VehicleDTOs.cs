using System.ComponentModel.DataAnnotations;

namespace VehicleCare.API.DTOs
{
    public class CreateVehicleRequest
    {
        [Required(ErrorMessage = "Vui lòng nhập hãng xe")]
        public string Brand { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập dòng xe")]
        public string Model { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập năm sản xuất")]
        public int Year { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập biển số xe")]
        public string LicensePlate { get; set; } = string.Empty;

        public string Color { get; set; } = string.Empty;
        
        public string VehicleType { get; set; } = string.Empty;

        public int CurrentOdometer { get; set; }
    }

    public class UpdateVehicleRequest
    {
        [Required(ErrorMessage = "Vui lòng nhập hãng xe")]
        public string Brand { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập dòng xe")]
        public string Model { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập năm sản xuất")]
        public int Year { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập biển số xe")]
        public string LicensePlate { get; set; } = string.Empty;

        public string Color { get; set; } = string.Empty;
        
        public string VehicleType { get; set; } = string.Empty;

        public int CurrentOdometer { get; set; }
    }

    public class VehicleResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public int Year { get; set; }
        public string LicensePlate { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public string VehicleType { get; set; } = string.Empty;
        public int CurrentOdometer { get; set; }
    }
}
