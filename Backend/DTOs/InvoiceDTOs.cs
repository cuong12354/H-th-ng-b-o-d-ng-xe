using System;
using System.Collections.Generic;

namespace VehicleCare.API.DTOs
{
    public class InvoiceItemResponse
    {
        public string ItemName { get; set; } = string.Empty;
        public int Quantity { get; set; } = 1;
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class InvoiceResponse
    {
        public int Id { get; set; }
        public int AppointmentId { get; set; }
        public string InvoiceCode { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerPhone { get; set; } = string.Empty;
        public string LicensePlate { get; set; } = string.Empty;
        public string VehicleModel { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public decimal Discount { get; set; }
        public decimal FinalAmount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public string PaymentStatus { get; set; } = string.Empty;
        public bool IsPaidAtStore { get; set; } = true;
        public DateTime CreatedAt { get; set; }
        public List<InvoiceItemResponse> Items { get; set; } = new List<InvoiceItemResponse>();
    }
}
