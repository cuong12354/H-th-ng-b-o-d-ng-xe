using System.ComponentModel.DataAnnotations.Schema;

namespace VehicleCare.API.Models
{
    public class AppointmentDetail
    {
        public int Id { get; set; }
        public int AppointmentId { get; set; }
        public int ServiceId { get; set; }
        [Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }

        public Appointment? Appointment { get; set; }
        public Service? Service { get; set; }
    }
}
