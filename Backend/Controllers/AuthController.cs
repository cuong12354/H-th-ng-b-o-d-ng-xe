using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using VehicleCare.API.Data;
using VehicleCare.API.DTOs;
using VehicleCare.API.Models;
using BC = BCrypt.Net.BCrypt;

namespace VehicleCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            // Check if email or phone exists
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email || u.PhoneNumber == request.PhoneNumber);
            if (existingUser != null)
            {
                if (existingUser.Email == request.Email)
                    return BadRequest(ApiResponse<object>.ErrorResponse("Email đã được sử dụng"));
                if (existingUser.PhoneNumber == request.PhoneNumber)
                    return BadRequest(ApiResponse<object>.ErrorResponse("Số điện thoại đã được sử dụng"));
            }

            var user = new User
            {
                FullName = request.FullName,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                PasswordHash = BC.HashPassword(request.Password),
                Role = "CUSTOMER"
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<object>.SuccessResponse(null, "Đăng ký thành công"));
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.EmailOrPhone || u.PhoneNumber == request.EmailOrPhone);

            if (user == null || !BC.Verify(request.Password, user.PasswordHash))
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Email/Số điện thoại hoặc mật khẩu không đúng"));
            }

            if (!user.IsActive)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Tài khoản của bạn đã bị khóa"));
            }

            var token = GenerateJwtToken(user);

            var responseData = new AuthResponse
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                Role = user.Role,
                Token = token
            };

            return Ok(ApiResponse<AuthResponse>.SuccessResponse(responseData, "Đăng nhập thành công"));
        }

        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["Secret"];
            var key = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(secretKey!));

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim("FullName", user.FullName),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expiryMinutes = Convert.ToInt32(jwtSettings["ExpiryMinutes"]);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(expiryMinutes),
                Issuer = jwtSettings["Issuer"],
                Audience = jwtSettings["Audience"],
                SigningCredentials = creds
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetProfile()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);
            if (!int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Không tìm thấy thông tin đăng nhập"));
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Người dùng không tồn tại"));
            }

            return Ok(ApiResponse<object>.SuccessResponse(new
            {
                user.Id,
                user.FullName,
                user.Email,
                user.PhoneNumber,
                user.Address,
                user.Role
            }, "Lấy thông tin thành công"));
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(ApiResponse<object>.ErrorResponse("Dữ liệu không hợp lệ", errors));
            }

            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);
            if (!int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Không tìm thấy thông tin đăng nhập"));
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Người dùng không tồn tại"));
            }

            // Check if email or phone is used by another user
            var emailConflict = await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != userId);
            if (emailConflict)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Email này đã được sử dụng bởi tài khoản khác"));
            }

            var phoneConflict = await _context.Users.AnyAsync(u => u.PhoneNumber == request.PhoneNumber && u.Id != userId);
            if (phoneConflict)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Số điện thoại này đã được sử dụng bởi tài khoản khác"));
            }

            user.FullName = request.FullName;
            user.Email = request.Email;
            user.PhoneNumber = request.PhoneNumber;
            if (request.Address != null)
            {
                user.Address = request.Address;
            }

            await _context.SaveChangesAsync();

            var newToken = GenerateJwtToken(user);

            var responseData = new AuthResponse
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                Role = user.Role,
                Token = newToken
            };

            return Ok(ApiResponse<AuthResponse>.SuccessResponse(responseData, "Cập nhật thông tin thành công"));
        }
    }
}
