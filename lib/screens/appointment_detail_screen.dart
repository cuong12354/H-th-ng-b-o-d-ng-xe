import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'invoice_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(appointment['scheduledDate']).toLocal());
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final status = appointment['status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Chi tiết Lịch hẹn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chung
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biển số xe: ${appointment['licensePlate']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Thời gian: $date', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Dự kiến thanh toán: ${currencyFormatter.format(appointment['totalEstimatedPrice'])}', style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // In-store Invoice section if Completed or Paid
            if (status == 'COMPLETED' || status == 'PAID') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: status == 'PAID' ? const Color(0xFF2ECC71).withAlpha(120) : Colors.orange.withAlpha(120),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (status == 'PAID' ? const Color(0xFF2ECC71) : Colors.orange).withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            status == 'PAID' ? Icons.check_circle : Icons.receipt_long,
                            color: status == 'PAID' ? const Color(0xFF2ECC71) : Colors.orange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status == 'PAID'
                                    ? 'HÓA ĐƠN ĐÃ THANH TOÁN TẠI CỬA HÀNG'
                                    : 'HÓA ĐƠN DỊCH VỤ SẴN SÀNG',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: status == 'PAID' ? const Color(0xFF2ECC71) : Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status == 'PAID'
                                    ? 'Đã thanh toán tại quầy thu ngân gara. Hóa đơn điện tử được lưu trong ứng dụng.'
                                    : 'Dịch vụ đã hoàn tất, quý khách vui lòng thanh toán tại quầy hoặc online.',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Thành tiền:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text(
                          currencyFormatter.format(appointment['totalEstimatedPrice']),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: status == 'PAID' ? const Color(0xFF2ECC71) : const Color(0xFFE60012),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('Xem Hóa đơn điện tử chi tiết'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE60012),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceScreen(initialAppointmentId: appointment['id']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            const Text('Tiến trình bảo dưỡng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: _buildTimeline(status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final statuses = [
      {'key': 'PENDING', 'label': 'Chờ duyệt', 'icon': Icons.pending_actions},
      {'key': 'CONFIRMED', 'label': 'Đã xác nhận', 'icon': Icons.check_circle_outline},
      {'key': 'MAINTENANCE', 'label': 'Đang bảo dưỡng', 'icon': Icons.build},
      {'key': 'COMPLETED', 'label': 'Hoàn tất', 'icon': Icons.done_all},
      {'key': 'PAID', 'label': 'Đã thanh toán', 'icon': Icons.payment},
    ];

    int currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus);
    if (currentStatus == 'CANCELLED') currentIndex = -1; // Hủy thì không theo flow này

    if (currentStatus == 'CANCELLED') {
      return const Center(
        child: Text('LỊCH HẸN ĐÃ BỊ HỦY', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final s = statuses[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFF26522) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s['icon'] as IconData, color: Colors.white, size: 20),
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 3,
                    height: 40,
                    color: isCompleted ? const Color(0xFFF26522) : Colors.grey.shade300,
                  )
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  s['label'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
