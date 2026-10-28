using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VehicleCare.API.Migrations
{
    /// <inheritdoc />
    public partial class AddIsPopularToService : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsPopular",
                table: "Services",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsPopular",
                table: "Services");
        }
    }
}
