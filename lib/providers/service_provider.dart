import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../core/api_config.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ServiceModel> get services => _services;
  List<ServiceModel> get popularServices => _services.where((s) => s.isPopular).toList();
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/Service'); // Adjust endpoint if needed
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.data['message'] ?? 'Lỗi tải danh sách dịch vụ';
      }
    } catch (e) {
      _errorMessage = 'Không thể kết nối đến máy chủ (${ApiConfig.baseUrl})';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addService(ServiceModel service) async {
    try {
      final response = await _apiService.dio.post('/Service', data: {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'estimatedMinutes': service.estimatedMinutes,
        'category': service.category,
        'imageUrl': service.imageUrl,
        'isPopular': service.isPopular,
      });
      if (response.statusCode == 200) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    try {
      final response = await _apiService.dio.put('/Service/${service.id}', data: {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'estimatedMinutes': service.estimatedMinutes,
        'category': service.category,
        'imageUrl': service.imageUrl,
        'isPopular': service.isPopular,
      });
      if (response.statusCode == 200) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      final response = await _apiService.dio.delete('/Service/$id');
      if (response.statusCode == 200) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
