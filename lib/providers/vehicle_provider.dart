import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/vehicle_model.dart';
import '../services/api_service.dart';
import '../core/api_config.dart';

class VehicleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchMyVehicles() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await _apiService.dio.get(ApiConfig.vehicleEndpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _vehicles = data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        _errorMessage = response.data['message'] ?? 'Lỗi tải danh sách xe';
      }
    } catch (e) {
      _errorMessage = 'Không thể kết nối đến máy chủ (${ApiConfig.baseUrl})';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addVehicle({
    required String brand,
    required String model,
    required int year,
    required String licensePlate,
    required String color,
    required String vehicleType,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await _apiService.dio.post(
        ApiConfig.vehicleEndpoint,
        data: {
          'brand': brand,
          'model': model,
          'year': year,
          'licensePlate': licensePlate,
          'color': color,
          'vehicleType': vehicleType,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newVehicle = VehicleModel.fromJson(response.data['data']);
        _vehicles.add(newVehicle);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Thêm xe thất bại';
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        _errorMessage = e.response?.data['message'];
      } else {
        _errorMessage = 'Lỗi máy chủ (${e.response?.statusCode})';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateVehicle({
    required int id,
    required String brand,
    required String model,
    required int year,
    required String licensePlate,
    required String color,
    required String vehicleType,
    int currentOdometer = 0,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await _apiService.dio.put(
        '${ApiConfig.vehicleEndpoint}/$id',
        data: {
          'brand': brand,
          'model': model,
          'year': year,
          'licensePlate': licensePlate,
          'color': color,
          'vehicleType': vehicleType,
          'currentOdometer': currentOdometer,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final updated = VehicleModel.fromJson(response.data['data']);
        final index = _vehicles.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vehicles[index] = updated;
        }
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Cập nhật thất bại';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        _errorMessage = e.response?.data['message'];
      } else {
        _errorMessage = 'Lỗi máy chủ (${e.response?.statusCode})';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await _apiService.dio.delete('${ApiConfig.vehicleEndpoint}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _vehicles.removeWhere((v) => v.id == id);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Xóa xe thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
