import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final notifications = [
      {
        'title': 'Nhắc lịch bảo dưỡng',
        'body': 'Xe AirBlade biển số 59P1-123.45 của bạn đã đến hạn thay nhớt (đã chạy 2000km). Vui lòng đặt lịch ngay!',
        'time': 'Vừa xong',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'isRead': false,
      },
      {
        'title': 'Xác nhận lịch hẹn',
        'body': 'Lịch hẹn bảo dưỡng xe vào lúc 09:00 ngày mai của bạn đã được xác nhận thành công.',
        'time': '2 giờ trước',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'isRead': true,
      },
      {
        'title': 'Khuyến mãi đặc biệt',
        'body': 'Giảm ngay 20% cho tất cả dịch vụ vệ sinh buồng đốt trong tháng này.',
        'time': '1 ngày trước',
        'icon': Icons.local_offer,
        'color': Colors.blue,
        'isRead': true,
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final bool isRead = n['isRead'] as bool;
          
          return Container(
            color: isRead ? Colors.transparent : Colors.blue.withAlpha(15),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: (n['color'] as Color).withAlpha(30),
                child: Icon(n['icon'] as IconData, color: n['color'] as Color),
              ),
              title: Text(
                n['title'] as String, 
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16
                )
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(n['body'] as String),
                  const SizedBox(height: 4),
                  Text(n['time'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
