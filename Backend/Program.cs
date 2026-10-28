using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using VehicleCare.API.Data;

var builder = WebApplication.CreateBuilder(args);

// Force Kestrel to always listen on port 5054 on all network interfaces
builder.WebHost.UseUrls("http://0.0.0.0:5054");

// Add services to the container.
builder.Services.AddControllers();

// Configure DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["Secret"];

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(secretKey!)),
        ValidateIssuer = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidateAudience = true,
        ValidAudience = jwtSettings["Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

// Configure Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/api/health", () => new { status = "online", time = DateTime.UtcNow, service = "VehicleCare API" });
// Database Seeding
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<VehicleCare.API.Data.AppDbContext>();
    if (!context.Services.Any())
    {
        context.Services.AddRange(
            new VehicleCare.API.Models.Service { Name = "Thay nhớt động cơ", Description = "Thay nhớt chính hãng", Price = 150000, Category = "Bảo dưỡng", EstimatedMinutes = 30 },
            new VehicleCare.API.Models.Service { Name = "Rửa xe toàn diện", Description = "Rửa bọt tuyết, lau khô", Price = 50000, Category = "Làm sạch", EstimatedMinutes = 20 },
            new VehicleCare.API.Models.Service { Name = "Bảo dưỡng tổng quát", Description = "Kiểm tra toàn bộ hệ thống xe", Price = 300000, Category = "Bảo dưỡng", EstimatedMinutes = 60 },
            new VehicleCare.API.Models.Service { Name = "Thay bố thắng (má phanh)", Description = "Thay bố thắng trước/sau", Price = 200000, Category = "Sửa chữa", EstimatedMinutes = 45 }
        );
        context.SaveChanges();
    }

    if (!context.Parts.Any())
    {
        context.Parts.AddRange(
            new VehicleCare.API.Models.Part { Name = "Nhớt Castrol Power1 10W40 (0.8L)", Description = "Nhớt bán tổng hợp xe máy số/ga", Price = 120000, StockQuantity = 25 },
            new VehicleCare.API.Models.Part { Name = "Nhớt Motul 3100 Silver 1L", Description = "Nhớt cao cấp xe côn tay/số", Price = 145000, StockQuantity = 18 },
            new VehicleCare.API.Models.Part { Name = "Má phanh đĩa trước Nissin", Description = "Má phanh đĩa trước chính hãng", Price = 95000, StockQuantity = 12 },
            new VehicleCare.API.Models.Part { Name = "Bugi NGK CPR6EA-9", Description = "Bugi đánh lửa tiêu chuẩn", Price = 45000, StockQuantity = 30 },
            new VehicleCare.API.Models.Part { Name = "Lọc gió Honda Air Blade / Lead", Description = "Lọc gió chính hãng Honda", Price = 65000, StockQuantity = 8 },
            new VehicleCare.API.Models.Part { Name = "Lốp không săm Maxxis 90/90-14", Description = "Lốp sau xe tay ga bánh 14 inch", Price = 380000, StockQuantity = 5 },
            new VehicleCare.API.Models.Part { Name = "Dây curoa Bando Honda 125cc", Description = "Dây curoa truyền động chính hãng", Price = 220000, StockQuantity = 7 }
        );
        context.SaveChanges();
    }
    
    // Seed Admin User
    var adminUser = context.Users.FirstOrDefault(u => u.Role == "Admin" && u.Email == "admin");
    if (adminUser == null)
    {
        adminUser = new VehicleCare.API.Models.User
        {
            FullName = "Chủ Gara (Admin)",
            Email = "admin",
            PhoneNumber = "0000000000",
            Role = "Admin",
            IsActive = true,
            CreatedAt = System.DateTime.UtcNow,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin")
        };
        context.Users.Add(adminUser);
        context.SaveChanges();
    }
    else
    {
        // Fix hash if it was generated by ASP.NET Core Identity PasswordHasher (doesn't start with $2)
        if (!adminUser.PasswordHash.StartsWith("$2"))
        {
            adminUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin");
            context.SaveChanges();
        }
    }

    // Seed Staff User
    var staffUser = context.Users.FirstOrDefault(u => u.Role == "Staff" && u.Email == "staff");
    if (staffUser == null)
    {
        staffUser = new VehicleCare.API.Models.User
        {
            FullName = "Nhân viên Kỹ thuật",
            Email = "staff",
            PhoneNumber = "1111111111",
            Role = "Staff",
            IsActive = true,
            CreatedAt = System.DateTime.UtcNow,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("staff")
        };
        context.Users.Add(staffUser);
        context.SaveChanges();
    }
    else
    {
        if (!staffUser.PasswordHash.StartsWith("$2"))
        {
            staffUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword("staff");
            context.SaveChanges();
        }
    }
}

app.Run();
