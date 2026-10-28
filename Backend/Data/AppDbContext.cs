using Microsoft.EntityFrameworkCore;
using VehicleCare.API.Models;

namespace VehicleCare.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Vehicle> Vehicles { get; set; }
        public DbSet<Service> Services { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<AppointmentDetail> AppointmentDetails { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<InvoiceDetail> InvoiceDetails { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<MaintenanceRecord> MaintenanceRecords { get; set; }
        public DbSet<Part> Parts { get; set; }
        public DbSet<MaintenancePart> MaintenanceParts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure relationships

            // User - Vehicle (1-N)
            modelBuilder.Entity<Vehicle>()
                .HasOne(v => v.User)
                .WithMany(u => u.Vehicles)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // User - Appointment (1-N)
            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.User)
                .WithMany(u => u.Appointments)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Vehicle - Appointment (1-N)
            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Vehicle)
                .WithMany(v => v.Appointments)
                .HasForeignKey(a => a.VehicleId)
                .OnDelete(DeleteBehavior.Restrict);

            // Appointment - AppointmentDetail (1-N)
            modelBuilder.Entity<AppointmentDetail>()
                .HasOne(ad => ad.Appointment)
                .WithMany(a => a.AppointmentDetails)
                .HasForeignKey(ad => ad.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);

            // Service - AppointmentDetail (1-N)
            modelBuilder.Entity<AppointmentDetail>()
                .HasOne(ad => ad.Service)
                .WithMany(s => s.AppointmentDetails)
                .HasForeignKey(ad => ad.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);

            // Appointment - Invoice (1-1)
            modelBuilder.Entity<Invoice>()
                .HasOne(i => i.Appointment)
                .WithOne(a => a.Invoice)
                .HasForeignKey<Invoice>(i => i.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            // Invoice - InvoiceDetail (1-N)
            modelBuilder.Entity<InvoiceDetail>()
                .HasOne(id => id.Invoice)
                .WithMany(i => i.InvoiceDetails)
                .HasForeignKey(id => id.InvoiceId)
                .OnDelete(DeleteBehavior.Cascade);

            // Appointment - Review (1-1)
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Appointment)
                .WithOne(a => a.Review)
                .HasForeignKey<Review>(r => r.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);

            // User - Notification (1-N)
            modelBuilder.Entity<Notification>()
                .HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Vehicle - MaintenanceRecord (1-N)
            modelBuilder.Entity<MaintenanceRecord>()
                .HasOne(mr => mr.Vehicle)
                .WithMany(v => v.MaintenanceRecords)
                .HasForeignKey(mr => mr.VehicleId)
                .OnDelete(DeleteBehavior.Cascade);

            // MaintenanceRecord - MaintenancePart (1-N)
            modelBuilder.Entity<MaintenancePart>()
                .HasOne(mp => mp.MaintenanceRecord)
                .WithMany(mr => mr.MaintenanceParts)
                .HasForeignKey(mp => mp.MaintenanceRecordId)
                .OnDelete(DeleteBehavior.Cascade);

            // Part - MaintenancePart (1-N)
            modelBuilder.Entity<MaintenancePart>()
                .HasOne(mp => mp.Part)
                .WithMany(p => p.MaintenanceParts)
                .HasForeignKey(mp => mp.PartId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
