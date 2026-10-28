using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VehicleCare.API.Data;
using VehicleCare.API.DTOs;
using VehicleCare.API.Models;

namespace VehicleCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PartController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PartController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetParts([FromQuery] string? search, [FromQuery] string? category)
        {
            var query = _context.Parts.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(p => p.Name.Contains(search) || p.Description.Contains(search));
            }

            if (!string.IsNullOrEmpty(category))
            {
                var catUpper = category.Trim().ToUpper();
                query = query.Where(p => p.Category == catUpper);
            }

            var parts = await query.OrderBy(p => p.Category).ThenBy(p => p.Name).ToListAsync();
            return Ok(ApiResponse<List<Part>>.SuccessResponse(parts, "Lấy danh sách phụ tùng thành công"));
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPartById(int id)
        {
            var part = await _context.Parts.FindAsync(id);
            if (part == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phụ tùng"));
            }

            return Ok(ApiResponse<Part>.SuccessResponse(part, "Thành công"));
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> CreatePart([FromBody] CreatePartRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            var part = new Part
            {
                Name = request.Name,
                Description = request.Description,
                Price = request.Price,
                StockQuantity = request.StockQuantity,
                Category = string.IsNullOrWhiteSpace(request.Category) ? "SPARE_PART" : request.Category.Trim().ToUpper()
            };

            _context.Parts.Add(part);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<Part>.SuccessResponse(part, "Thêm phụ tùng/phụ kiện thành công"));
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> UpdatePart(int id, [FromBody] UpdatePartRequest request)
        {
            var part = await _context.Parts.FindAsync(id);
            if (part == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phụ tùng"));
            }

            part.Name = request.Name;
            part.Description = request.Description;
            part.Price = request.Price;
            part.StockQuantity = request.StockQuantity;
            if (!string.IsNullOrWhiteSpace(request.Category))
            {
                part.Category = request.Category.Trim().ToUpper();
            }

            await _context.SaveChangesAsync();
            return Ok(ApiResponse<Part>.SuccessResponse(part, "Cập nhật phụ tùng/phụ kiện thành công"));
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> DeletePart(int id)
        {
            var part = await _context.Parts.FindAsync(id);
            if (part == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phụ tùng"));
            }

            _context.Parts.Remove(part);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Xóa phụ tùng thành công"));
        }
    }
}
