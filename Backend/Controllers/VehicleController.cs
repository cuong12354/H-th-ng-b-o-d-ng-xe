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
    [Authorize]
    public class VehicleController : ControllerBase
    {
        private readonly AppDbContext _context;

        public VehicleController(AppDbContext context)
        {
            _context = context;
        }

        private int GetCurrentUserId()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (int.TryParse(userIdStr, out int userId))
            {
                return userId;
            }
            throw new UnauthorizedAccessException("Không tìm thấy thông tin người dùng");
        }

        [HttpGet]
        public async Task<IActionResult> GetMyVehicles()
        {
            try
            {
                int userId = GetCurrentUserId();
                var vehicles = await _context.Vehicles
                    .Where(v => v.UserId == userId)
                    .Select(v => new VehicleResponse
                    {
                        Id = v.Id,
                        UserId = v.UserId,
                        Brand = v.Brand,
                        Model = v.Model,
                        Year = v.Year,
                        LicensePlate = v.LicensePlate,
                        Color = v.Color,
                        VehicleType = v.VehicleType,
                        CurrentOdometer = v.CurrentOdometer
                    })
                    .ToListAsync();

                return Ok(ApiResponse<List<VehicleResponse>>.SuccessResponse(vehicles, "Lấy danh sách xe thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPost]
        public async Task<IActionResult> AddVehicle([FromBody] CreateVehicleRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            try
            {
                int userId = GetCurrentUserId();

                // Check for duplicate license plate
                var existingVehicle = await _context.Vehicles.FirstOrDefaultAsync(v => v.LicensePlate == request.LicensePlate);
                if (existingVehicle != null)
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse("Biển số xe này đã được đăng ký trên hệ thống"));
                }

                var vehicle = new Vehicle
                {
                    UserId = userId,
                    Brand = request.Brand,
                    Model = request.Model,
                    Year = request.Year,
                    LicensePlate = request.LicensePlate,
                    Color = request.Color,
                    VehicleType = request.VehicleType,
                    CurrentOdometer = request.CurrentOdometer,
                    RegistrationDate = DateTime.UtcNow
                };

                _context.Vehicles.Add(vehicle);
                await _context.SaveChangesAsync();

                var response = new VehicleResponse
                {
                    Id = vehicle.Id,
                    UserId = vehicle.UserId,
                    Brand = vehicle.Brand,
                    Model = vehicle.Model,
                    Year = vehicle.Year,
                    LicensePlate = vehicle.LicensePlate,
                    Color = vehicle.Color,
                    VehicleType = vehicle.VehicleType,
                    CurrentOdometer = vehicle.CurrentOdometer
                };

                return Ok(ApiResponse<VehicleResponse>.SuccessResponse(response, "Thêm xe mới thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateVehicle(int id, [FromBody] UpdateVehicleRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            try
            {
                int userId = GetCurrentUserId();
                var vehicle = await _context.Vehicles.FirstOrDefaultAsync(v => v.Id == id && v.UserId == userId);
                if (vehicle == null)
                {
                    return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy xe hoặc bạn không có quyền cập nhật"));
                }

                // Check duplicate license plate on other vehicles
                var existingPlate = await _context.Vehicles.FirstOrDefaultAsync(v => v.LicensePlate == request.LicensePlate && v.Id != id);
                if (existingPlate != null)
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse("Biển số xe này đã được sử dụng bởi xe khác"));
                }

                vehicle.Brand = request.Brand;
                vehicle.Model = request.Model;
                vehicle.Year = request.Year;
                vehicle.LicensePlate = request.LicensePlate;
                vehicle.Color = request.Color;
                vehicle.VehicleType = request.VehicleType;
                if (request.CurrentOdometer > 0)
                {
                    vehicle.CurrentOdometer = request.CurrentOdometer;
                }

                await _context.SaveChangesAsync();

                var response = new VehicleResponse
                {
                    Id = vehicle.Id,
                    UserId = vehicle.UserId,
                    Brand = vehicle.Brand,
                    Model = vehicle.Model,
                    Year = vehicle.Year,
                    LicensePlate = vehicle.LicensePlate,
                    Color = vehicle.Color,
                    VehicleType = vehicle.VehicleType,
                    CurrentOdometer = vehicle.CurrentOdometer
                };

                return Ok(ApiResponse<VehicleResponse>.SuccessResponse(response, "Cập nhật thông tin xe thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteVehicle(int id)
        {
            try
            {
                int userId = GetCurrentUserId();
                var vehicle = await _context.Vehicles.FirstOrDefaultAsync(v => v.Id == id && v.UserId == userId);
                
                if (vehicle == null)
                {
                    return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy xe hoặc bạn không có quyền xóa"));
                }

                _context.Vehicles.Remove(vehicle);
                await _context.SaveChangesAsync();

                return Ok(ApiResponse<object>.SuccessResponse(null, "Xóa xe thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }
    }
}
