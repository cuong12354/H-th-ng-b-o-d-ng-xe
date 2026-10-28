using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using VehicleCare.API.Data;
using VehicleCare.API.DTOs;
using VehicleCare.API.Models;

namespace VehicleCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AppointmentController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AppointmentController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateAppointment([FromBody] CreateAppointmentRequest request)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var appointment = new Appointment
            {
                UserId = userId,
                VehicleId = request.VehicleId,
                ScheduledDate = request.ScheduledDate,
                Notes = request.Notes,
                TotalEstimatedPrice = request.TotalEstimatedPrice,
                Status = "CONFIRMED",
                CreatedAt = System.DateTime.UtcNow,
                AppointmentDetails = request.ServiceIds.Select(id => new AppointmentDetail
                {
                    ServiceId = id,
                    Price = _context.Services.Find(id)?.Price ?? 0
                }).ToList()
            };

            _context.Appointments.Add(appointment);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Đặt lịch thành công"));
        }

        [HttpPost("staff-create")]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> StaffCreateAppointment([FromBody] StaffCreateAppointmentRequest request)
        {
            // 1. Find or create user by Phone
            var user = await _context.Users.FirstOrDefaultAsync(u => u.PhoneNumber == request.CustomerPhone);
            if (user == null)
            {
                user = new User
                {
                    FullName = string.IsNullOrEmpty(request.CustomerName) ? "Khách vãng lai" : request.CustomerName,
                    PhoneNumber = request.CustomerPhone,
                    Email = $"{request.CustomerPhone}@guest.local",
                    PasswordHash = "NO_PASSWORD",
                    Role = "User"
                };
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }

            // 2. Find or create vehicle by LicensePlate
            var vehicle = await _context.Vehicles.FirstOrDefaultAsync(v => v.LicensePlate == request.LicensePlate);
            if (vehicle == null)
            {
                vehicle = new Vehicle
                {
                    UserId = user.Id,
                    LicensePlate = request.LicensePlate,
                    Brand = string.IsNullOrEmpty(request.VehicleBrand) ? "Khác" : request.VehicleBrand,
                    Model = string.IsNullOrEmpty(request.VehicleModel) ? "Khác" : request.VehicleModel,
                    Year = DateTime.Now.Year,
                    Color = "Chưa rõ",
                    VehicleType = "Car"
                };
                _context.Vehicles.Add(vehicle);
                await _context.SaveChangesAsync();
            }

            // 3. Calculate total price and create Appointment Details
            decimal totalPrice = 0;
            var details = new List<AppointmentDetail>();
            foreach(var id in request.ServiceIds)
            {
                var svc = await _context.Services.FindAsync(id);
                if (svc != null)
                {
                    totalPrice += svc.Price;
                    details.Add(new AppointmentDetail { ServiceId = id, Price = svc.Price });
                }
            }

            // 4. Create Appointment
            var appointment = new Appointment
            {
                UserId = user.Id,
                VehicleId = vehicle.Id,
                ScheduledDate = DateTime.UtcNow,
                Notes = "Tạo trực tiếp tại Gara",
                TotalEstimatedPrice = totalPrice,
                Status = "CONFIRMED", // Staff tao la vao lam luon
                CreatedAt = DateTime.UtcNow,
                AppointmentDetails = details
            };

            _context.Appointments.Add(appointment);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Tạo phiếu thành công"));
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetAppointments()
        {
            var role = User.FindFirstValue(ClaimTypes.Role);
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userIdStr == null) return Unauthorized();
            
            var userId = int.Parse(userIdStr);

            var query = _context.Appointments
                .Include(a => a.Vehicle)
                .Include(a => a.User)
                .Include(a => a.AppointmentDetails)
                    .ThenInclude(ad => ad.Service)
                .AsQueryable();

            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(a => a.UserId == userId);
            }

            var appointments = await query
                .OrderByDescending(a => a.CreatedAt)
                .Select(a => new AppointmentResponse
                {
                    Id = a.Id,
                    VehicleId = a.VehicleId,
                    LicensePlate = a.Vehicle!.LicensePlate,
                    CustomerName = a.User!.FullName,
                    ScheduledDate = a.ScheduledDate,
                    Status = a.Status,
                    TotalEstimatedPrice = a.TotalEstimatedPrice,
                    CreatedAt = a.CreatedAt,
                    Services = a.AppointmentDetails.Select(ad => ad.Service != null ? ad.Service.Name : "Dịch vụ").ToList()
                }).ToListAsync();

            return Ok(ApiResponse<List<AppointmentResponse>>.SuccessResponse(appointments, "Thành công"));
        }

        [HttpPut("{id}/status")]
        [Authorize]
        public async Task<IActionResult> UpdateAppointmentStatus(int id, [FromBody] UpdateAppointmentStatusRequest request)
        {
            var appointment = await _context.Appointments.FindAsync(id);
            if (appointment == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy lịch hẹn"));
            }

            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var role = User.FindFirstValue(ClaimTypes.Role);

            if (role != "Admin" && role != "Staff")
            {
                // Customers can only cancel their own appointments
                if (appointment.UserId != userId || request.Status != "CANCELLED")
                {
                    return Forbid();
                }
            }

            // PENDING, CONFIRMED, REJECTED, CHECKING, MAINTENANCE, COMPLETED, CANCELLED, PAID
            appointment.Status = request.Status;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Cập nhật trạng thái thành công"));
        }
    }
}
