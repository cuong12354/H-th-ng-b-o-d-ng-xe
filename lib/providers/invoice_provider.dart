import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _invoices = [];
  bool _isLoading = false;

  List<dynamic> get invoices => _invoices;
  bool get isLoading => _isLoading;

  List<dynamic> get paidInvoices =>
      _invoices.where((i) => i['paymentStatus'] == 'PAID').toList();

  List<dynamic> get unpaidInvoices =>
      _invoices.where((i) => i['paymentStatus'] != 'PAID').toList();

  Future<void> fetchInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/Invoice');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _invoices = response.data['data'] ?? [];
      }
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getInvoiceByAppointmentId(int appointmentId) async {
    // Check locally first
    try {
      final match = _invoices.firstWhere(
        (i) => i['appointmentId'] == appointmentId,
        orElse: () => null,
      );
      if (match != null) return match as Map<String, dynamic>;

      final response = await _apiService.dio.get('/Invoice/by-appointment/$appointmentId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      // Not found or error
    }
    return null;
  }

  Future<Map<String, dynamic>?> getInvoiceById(int id) async {
    try {
      final response = await _apiService.dio.get('/Invoice/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      // Error handling
    }
    return null;
  }

  Future<bool> payInvoice(int id, String paymentMethod) async {
    try {
      final response = await _apiService.dio.put('/Invoice/$id/pay', data: '"$paymentMethod"');
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchInvoices();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

