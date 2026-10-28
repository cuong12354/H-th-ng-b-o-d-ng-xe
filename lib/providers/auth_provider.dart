import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../core/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  bool get isAuthenticated {
    final token = _localStorage.getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  Future<void> checkAuth() async {
    final token = _localStorage.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      _currentUser = UserModel(
        id: int.tryParse(decoded['sub']?.toString() ?? '0') ?? 0,
        fullName: decoded['FullName'] ?? '',
        email: decoded['email'] ?? '',
        phoneNumber: '',
        role: decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? decoded['role'] ?? '',
        token: token,
      );
      notifyListeners();
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final response = await _apiService.dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['data']);
        await _localStorage.saveToken(_currentUser!.token);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Đăng nhập thất bại';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final response = await _apiService.dio.post(
        ApiConfig.registerEndpoint,
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Đăng ký thất bại';
        if (response.data['errors'] != null && (response.data['errors'] as List).isNotEmpty) {
          _errorMessage = response.data['errors'][0];
        }
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await _apiService.dio.put(
        ApiConfig.profileEndpoint,
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'address': address ?? '',
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['data']);
        await _localStorage.saveToken(_currentUser!.token);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Cập nhật thất bại';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.dio.get(ApiConfig.meEndpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = _localStorage.getToken() ?? '';
        _currentUser = UserModel(
          id: data['id'] ?? 0,
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          address: data['address'],
          role: data['role'] ?? '',
          token: token,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _localStorage.removeToken();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        _errorMessage = e.response?.data['message'];
        if (e.response?.data['errors'] != null && (e.response?.data['errors'] as List).isNotEmpty) {
          _errorMessage += '\n' + (e.response?.data['errors'] as List).join('\n');
        }
      } else {
        _errorMessage = 'Lỗi máy chủ (${e.response?.statusCode})';
      }
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      _errorMessage = 'Hết thời gian kết nối tới máy chủ (${ApiConfig.baseUrl}). Vui lòng kiểm tra lại backend.';
    } else {
      _errorMessage = 'Không thể kết nối đến máy chủ (${ApiConfig.baseUrl}). Hãy chắc chắn Backend ASP.NET Core đang chạy trên cổng 5054.';
    }
  }
}
