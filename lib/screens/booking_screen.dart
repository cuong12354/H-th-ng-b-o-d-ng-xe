import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle_model.dart';
import '../providers/service_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/service_model.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final ServiceModel? preSelectedService;
  
  const BookingScreen({super.key, required this.vehicle, this.preSelectedService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<ServiceModel> _selectedServices = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedService != null) {
      _selectedServices.add(widget.preSelectedService!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  void _toggleService(ServiceModel service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 dịch vụ')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    double totalAmount = _selectedServices.fold(0, (sum, item) => sum + item.price);
    
    final success = await Provider.of<AppointmentProvider>(context, listen: false).createAppointment(
      vehicleId: widget.vehicle.id,
      scheduledDate: combinedDateTime,
      serviceIds: _selectedServices.map((s) => s.id).toList(),
      totalEstimatedPrice: totalAmount,
    );

    if (success) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đặt lịch thành công!'),
          content: Text('Bạn đã đặt lịch bảo dưỡng cho xe ${widget.vehicle.licensePlate}.\n\nVui lòng mang xe đến cửa hàng đúng hẹn nhé!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to Home
              },
              child: const Text('ĐỒNG Ý'),
            )
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thất bại, vui lòng thử lại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    double totalAmount = _selectedServices.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Đặt Lịch Bảo Dưỡng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: serviceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade900,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Phương tiện đang chọn', style: TextStyle(color: Colors.blue.shade100)),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.vehicle.brand} ${widget.vehicle.model} - ${widget.vehicle.licensePlate}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('1. Chọn Dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...serviceProvider.services.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFF26522) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) => _toggleService(service),
                            title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(service.description),
                            secondary: Text(
                              currencyFormatter.format(service.price),
                              style: const TextStyle(color: Color(0xFFF26522), fontWeight: FontWeight.bold),
                            ),
                            activeColor: const Color(0xFFF26522),
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 24),
                      const Text('2. Chọn Thời gian mang xe tới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_selectedDate == null ? 'Chọn Ngày' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedTime == null ? 'Chọn Giờ' : _selectedTime!.format(context)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Tổng thanh toán:', style: TextStyle(color: Colors.grey)),
                          Text(
                            currencyFormatter.format(totalAmount),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF26522)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26522),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('ĐẶT LỊCH NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
