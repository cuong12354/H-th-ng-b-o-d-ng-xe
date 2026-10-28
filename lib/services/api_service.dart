import 'package:dio/dio.dart';
import '../core/api_config.dart';
import 'local_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Luôn đảm bảo baseUrl mới nhất
        options.baseUrl = ApiConfig.baseUrl;

        // Lấy token từ Local Storage
        final token = LocalStorageService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Tự động chuyển đổi IP dự phòng nếu không kết nối được
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          final workingUrl = await ApiConfig.autoDetectWorkingServer();
          if (workingUrl != null && workingUrl != e.requestOptions.baseUrl) {
            _dio.options.baseUrl = workingUrl;
            try {
              final newOptions = e.requestOptions;
              newOptions.baseUrl = workingUrl;
              final response = await _dio.fetch(newOptions);
              return handler.resolve(response);
            } catch (_) {
              // Thử lại thất bại thì tiếp tục báo lỗi
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  void updateBaseUrl(String newUrl) {
    ApiConfig.setBaseUrl(newUrl);
    _dio.options.baseUrl = ApiConfig.baseUrl;
  }

  Dio get dio => _dio;
}
