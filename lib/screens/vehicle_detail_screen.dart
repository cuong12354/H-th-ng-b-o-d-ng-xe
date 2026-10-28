import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_model.dart';
import '../providers/appointment_provider.dart';
import 'appointment_detail_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text('Chi tiết xe: ${widget.vehicle.licensePlate}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.blue.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.vehicle.brand} ${widget.vehicle.model}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Biển số: ${widget.vehicle.licensePlate}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  Text('Loại xe: ${widget.vehicle.vehicleType}', style: const TextStyle(color: Colors.white)),
                  Text('Năm sản xuất: ${widget.vehicle.year}', style: const TextStyle(color: Colors.white)),
                  Text('Màu sắc: ${widget.vehicle.color}', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Lịch sử bảo dưỡng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Maintenance History
            Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                
                final history = provider.appointments.where((a) => a['vehicleId'] == widget.vehicle.id).toList();
                
                if (history.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Chưa có lịch sử bảo dưỡng nào cho xe này.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final a = history[index];
                    final date = DateFormat('dd/MM/yyyy').format(DateTime.parse(a['scheduledDate']).toLocal());
                    final status = a['status'];
                    final isDone = status == 'COMPLETED' || status == 'PAID';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDone ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            isDone ? Icons.check_circle : Icons.build, 
                            color: isDone ? Colors.green : Colors.orange
                          ),
                        ),
                        title: Text('Ngày: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          isDone ? 'Đã hoàn thành' : 'Đang xử lý / Chờ duyệt',
                          style: TextStyle(color: isDone ? Colors.green : Colors.orange),
                        ),
                        trailing: Text(
                          currencyFormatter.format(a['totalEstimatedPrice']), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AppointmentDetailScreen(appointment: a)
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
