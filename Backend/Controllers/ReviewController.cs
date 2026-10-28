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
    public class ReviewController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReviewController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateReview([FromBody] CreateReviewRequest request)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            
            var appointment = await _context.Appointments.FindAsync(request.AppointmentId);
            if (appointment == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy lịch hẹn"));
            if (appointment.UserId != userId) return Forbid();
            
            if (appointment.Status != "COMPLETED" && appointment.Status != "PAID")
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Chỉ có thể đánh giá khi dịch vụ đã hoàn tất"));
            }

            var existing = await _context.Reviews.FirstOrDefaultAsync(r => r.AppointmentId == request.AppointmentId);
            if (existing != null) return BadRequest(ApiResponse<object>.ErrorResponse("Bạn đã đánh giá lịch hẹn này rồi"));

            var review = new Review
            {
                AppointmentId = request.AppointmentId,
                Rating = request.Rating,
                Comment = request.Comment,
                CreatedAt = System.DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(review.Id, "Cảm ơn bạn đã đánh giá dịch vụ!"));
        }

        [HttpGet]
        public async Task<IActionResult> GetReviews()
        {
            var reviews = await _context.Reviews
                .Include(r => r.Appointment)
                    .ThenInclude(a => a!.User)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new ReviewResponse
                {
                    Id = r.Id,
                    AppointmentId = r.AppointmentId,
                    CustomerName = r.Appointment!.User!.FullName,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                }).ToListAsync();

            return Ok(ApiResponse<List<ReviewResponse>>.SuccessResponse(reviews, "Thành công"));
        }
    }
}
