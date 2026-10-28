using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VehicleCare.API.Data;
using VehicleCare.API.DTOs;
using VehicleCare.API.Models;

namespace VehicleCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServiceController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ServiceController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllServices()
        {
            try
            {
                var services = await _context.Services
                    .Where(s => s.IsActive)
                    .Select(s => new ServiceResponse
                    {
                        Id = s.Id,
                        Name = s.Name,
                        Description = s.Description,
                        Price = s.Price,
                        EstimatedMinutes = s.EstimatedMinutes,
                        Category = s.Category,
                        ImageUrl = s.ImageUrl,
                        IsPopular = s.IsPopular
                    })
                    .ToListAsync();

                return Ok(ApiResponse<List<ServiceResponse>>.SuccessResponse(services, "Thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateService([FromBody] CreateServiceRequest request)
        {
            var service = new Service
            {
                Name = request.Name,
                Description = request.Description,
                Price = request.Price,
                EstimatedMinutes = request.EstimatedMinutes,
                Category = request.Category,
                ImageUrl = request.ImageUrl,
                IsPopular = request.IsPopular,
                IsActive = true
            };
            _context.Services.Add(service);
            await _context.SaveChangesAsync();
            return Ok(ApiResponse<Service>.SuccessResponse(service, "Thêm dịch vụ thành công"));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateService(int id, [FromBody] CreateServiceRequest request)
        {
            var service = await _context.Services.FindAsync(id);
            if (service == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy dịch vụ"));

            service.Name = request.Name;
            service.Description = request.Description;
            service.Price = request.Price;
            service.EstimatedMinutes = request.EstimatedMinutes;
            service.Category = request.Category;
            service.ImageUrl = request.ImageUrl;
            service.IsPopular = request.IsPopular;

            await _context.SaveChangesAsync();
            return Ok(ApiResponse<Service>.SuccessResponse(service, "Cập nhật thành công"));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteService(int id)
        {
            var service = await _context.Services.FindAsync(id);
            if (service == null) return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy dịch vụ"));
            
            service.IsActive = false; // Soft delete
            await _context.SaveChangesAsync();
            return Ok(ApiResponse<object>.SuccessResponse(null, "Xoá thành công"));
        }
    }
}
