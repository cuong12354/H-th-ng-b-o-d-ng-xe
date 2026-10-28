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
    public class InvoiceController : ControllerBase
    {
        private readonly AppDbContext _context;

        public InvoiceController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("from-appointment/{appointmentId}")]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> CreateInvoiceFromAppointment(int appointmentId)
        {
            var appointment = await _context.Appointments
                .Include(a => a.AppointmentDetails)
                    .ThenInclude(ad => ad.Service)
                .FirstOrDefaultAsync(a => a.Id == appointmentId);

            if (appointment == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy lịch hẹn"));
            if (appointment.Status != "COMPLETED") return BadRequest(ApiResponse<object>.ErrorResponse("Lịch hẹn chưa hoàn thành"));

            var existingInvoice = await _context.Invoices.FirstOrDefaultAsync(i => i.AppointmentId == appointmentId);
            if (existingInvoice != null) return BadRequest(ApiResponse<object>.ErrorResponse("Hóa đơn đã tồn tại cho lịch hẹn này"));

            var invoice = new Invoice
            {
                AppointmentId = appointmentId,
                InvoiceCode = $"INV-{DateTime.UtcNow:yyyyMMdd}-{appointmentId}",
                TotalAmount = appointment.TotalEstimatedPrice,
                Discount = 0,
                FinalAmount = appointment.TotalEstimatedPrice,
                PaymentMethod = "CASH", // CASH, BANK_TRANSFER, VNPAY
                PaymentStatus = "UNPAID",
                CreatedAt = DateTime.UtcNow
            };

            if (appointment.AppointmentDetails != null && appointment.AppointmentDetails.Any())
            {
                foreach (var detail in appointment.AppointmentDetails)
                {
                    invoice.InvoiceDetails.Add(new InvoiceDetail
                    {
                        ItemName = detail.Service?.Name ?? "Dịch vụ bảo dưỡng",
                        Quantity = 1,
                        UnitPrice = detail.Price,
                        TotalPrice = detail.Price
                    });
                }
            }

            _context.Invoices.Add(invoice);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(invoice.Id, "Tạo hóa đơn thành công"));
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetInvoices()
        {
            var role = User.FindFirstValue(ClaimTypes.Role);
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var query = _context.Invoices
                .Include(i => i.InvoiceDetails)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.User)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.Vehicle)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.AppointmentDetails)
                        .ThenInclude(ad => ad.Service)
                .AsQueryable();

            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase))
            {
                var currentUser = await _context.Users.FindAsync(userId);
                var phone = currentUser?.PhoneNumber;

                if (!string.IsNullOrEmpty(phone))
                {
                    query = query.Where(i => i.Appointment!.UserId == userId || 
                                            (i.Appointment.User != null && i.Appointment.User.PhoneNumber == phone));
                }
                else
                {
                    query = query.Where(i => i.Appointment!.UserId == userId);
                }
            }

            var invoices = await query
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            var responseList = invoices.Select(i => MapToInvoiceResponse(i)).ToList();

            return Ok(ApiResponse<List<InvoiceResponse>>.SuccessResponse(responseList, "Thành công"));
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<IActionResult> GetInvoiceById(int id)
        {
            var role = User.FindFirstValue(ClaimTypes.Role);
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var invoice = await _context.Invoices
                .Include(i => i.InvoiceDetails)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.User)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.Vehicle)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.AppointmentDetails)
                        .ThenInclude(ad => ad.Service)
                .FirstOrDefaultAsync(i => i.Id == id);

            if (invoice == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy hóa đơn"));

            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase))
            {
                var currentUser = await _context.Users.FindAsync(userId);
                var phone = currentUser?.PhoneNumber;
                var isOwner = invoice.Appointment?.UserId == userId || 
                    (!string.IsNullOrEmpty(phone) && invoice.Appointment?.User?.PhoneNumber == phone);
                if (!isOwner) return Forbid();
            }

            return Ok(ApiResponse<InvoiceResponse>.SuccessResponse(MapToInvoiceResponse(invoice), "Thành công"));
        }

        [HttpGet("by-appointment/{appointmentId}")]
        [Authorize]
        public async Task<IActionResult> GetInvoiceByAppointmentId(int appointmentId)
        {
            var role = User.FindFirstValue(ClaimTypes.Role);
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var invoice = await _context.Invoices
                .Include(i => i.InvoiceDetails)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.User)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.Vehicle)
                .Include(i => i.Appointment)
                    .ThenInclude(a => a!.AppointmentDetails)
                        .ThenInclude(ad => ad.Service)
                .FirstOrDefaultAsync(i => i.AppointmentId == appointmentId);

            if (invoice == null) return NotFound(ApiResponse<object>.ErrorResponse("Chưa có hóa đơn cho lịch hẹn này"));

            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase))
            {
                var currentUser = await _context.Users.FindAsync(userId);
                var phone = currentUser?.PhoneNumber;
                var isOwner = invoice.Appointment?.UserId == userId || 
                    (!string.IsNullOrEmpty(phone) && invoice.Appointment?.User?.PhoneNumber == phone);
                if (!isOwner) return Forbid();
            }

            return Ok(ApiResponse<InvoiceResponse>.SuccessResponse(MapToInvoiceResponse(invoice), "Thành công"));
        }

        [HttpPut("{id}/pay")]
        [Authorize]
        public async Task<IActionResult> PayInvoice(int id, [FromBody] string paymentMethod)
        {
            var invoice = await _context.Invoices
                .Include(i => i.Appointment)
                .FirstOrDefaultAsync(i => i.Id == id);
                
            if (invoice == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy hóa đơn"));

            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var role = User.FindFirstValue(ClaimTypes.Role);
            
            if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase) && 
                invoice.Appointment!.UserId != userId)
            {
                return Forbid();
            }

            invoice.PaymentStatus = "PAID";
            invoice.PaymentMethod = string.IsNullOrEmpty(paymentMethod) ? "CASH" : paymentMethod;
            
            // Also update appointment status
            if (invoice.Appointment != null)
            {
                invoice.Appointment.Status = "PAID";
            }

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Thanh toán thành công"));
        }

        private static InvoiceResponse MapToInvoiceResponse(Invoice i)
        {
            var items = i.InvoiceDetails != null && i.InvoiceDetails.Any()
                ? i.InvoiceDetails.Select(d => new InvoiceItemResponse
                {
                    ItemName = d.ItemName,
                    Quantity = d.Quantity > 0 ? d.Quantity : 1,
                    UnitPrice = d.UnitPrice,
                    TotalPrice = d.TotalPrice > 0 ? d.TotalPrice : d.UnitPrice
                }).ToList()
                : (i.Appointment?.AppointmentDetails != null
                    ? i.Appointment.AppointmentDetails.Select(ad => new InvoiceItemResponse
                    {
                        ItemName = ad.Service?.Name ?? "Dịch vụ bảo dưỡng",
                        Quantity = 1,
                        UnitPrice = ad.Price,
                        TotalPrice = ad.Price
                    }).ToList()
                    : new List<InvoiceItemResponse>());

            var vehicleStr = i.Appointment?.Vehicle != null 
                ? $"{i.Appointment.Vehicle.Brand} {i.Appointment.Vehicle.Model}".Trim() 
                : "";

            return new InvoiceResponse
            {
                Id = i.Id,
                AppointmentId = i.AppointmentId,
                InvoiceCode = i.InvoiceCode,
                CustomerName = i.Appointment?.User?.FullName ?? "Khách hàng",
                CustomerPhone = i.Appointment?.User?.PhoneNumber ?? "",
                LicensePlate = i.Appointment?.Vehicle?.LicensePlate ?? "N/A",
                VehicleModel = vehicleStr,
                TotalAmount = i.TotalAmount,
                Discount = i.Discount,
                FinalAmount = i.FinalAmount,
                PaymentMethod = i.PaymentMethod,
                PaymentStatus = i.PaymentStatus,
                IsPaidAtStore = true,
                CreatedAt = i.CreatedAt,
                Items = items
            };
        }
    }
}
