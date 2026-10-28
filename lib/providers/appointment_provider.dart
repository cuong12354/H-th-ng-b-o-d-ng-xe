import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _appointments = [];
  bool _isLoading = false;

  List<dynamic> get appointments => _appointments;
  bool get isLoading => _isLoading;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/Appointment');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _appointments = response.data['data'];
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required int vehicleId,
    required DateTime scheduledDate,
    required List<int> serviceIds,
    required double totalEstimatedPrice,
  }) async {
    try {
      final response = await _apiService.dio.post('/Appointment', data: {
        'vehicleId': vehicleId,
        'scheduledDate': scheduledDate.toUtc().toIso8601String(),
        'notes': '',
        'serviceIds': serviceIds,
        'totalEstimatedPrice': totalEstimatedPrice,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchAppointments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.put('/Appointment/$id/status', data: {
        'status': status
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchAppointments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createInvoice(int appointmentId) async {
    try {
      final response = await _apiService.dio.post('/Invoice/from-appointment/$appointmentId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> staffCreateAppointment({
    required String customerName,
    required String customerPhone,
    required String licensePlate,
    required String vehicleBrand,
    required String vehicleModel,
    required List<int> serviceIds,
  }) async {
    try {
      final response = await _apiService.dio.post('/Appointment/staff-create', data: {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'licensePlate': licensePlate,
        'vehicleBrand': vehicleBrand,
        'vehicleModel': vehicleModel,
        'serviceIds': serviceIds,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchAppointments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
