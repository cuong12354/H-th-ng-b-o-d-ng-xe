import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/local_storage_service.dart';

class ApiConfig {
  static String? _cachedBaseUrl;

  // Các địa chỉ phổ biến
  static const String emulatorUrl = 'http://10.0.2.2:5054/api';
  static const String localhostUrl = 'http://127.0.0.1:5054/api';
  static const String lanWifiUrl = 'http://192.168.1.159:5054/api';
  static const String pcUrl = 'http://localhost:5054/api';

  // Danh sách các IP có thể kết nối
  static List<String> get candidateUrls {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return [pcUrl, localhostUrl, lanWifiUrl];
    }
    // Android / Thiết bị di động
    return [
      emulatorUrl,
      lanWifiUrl,
      localhostUrl,
    ];
  }

  static String get defaultBaseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return pcUrl;
    }
    return emulatorUrl;
  }

  static String get baseUrl {
    if (_cachedBaseUrl != null && _cachedBaseUrl!.isNotEmpty) {
      return _cachedBaseUrl!;
    }
    final saved = LocalStorageService().getServerUrl();
    if (saved != null && saved.isNotEmpty) {
      _cachedBaseUrl = saved;
      return saved;
    }
    return defaultBaseUrl;
  }

  static void setBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api')) {
      trimmed = '$trimmed/api';
    }
    _cachedBaseUrl = trimmed;
    LocalStorageService().saveServerUrl(trimmed);
  }

  static void resetToDefault() {
    _cachedBaseUrl = defaultBaseUrl;
    LocalStorageService().removeServerUrl();
  }

  // Kiểm tra sức khỏe kết nối đến URL
  static Future<bool> ping(String url, {int timeoutMs = 1500}) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: Duration(milliseconds: timeoutMs),
        receiveTimeout: Duration(milliseconds: timeoutMs),
      ));
      final cleanUrl = url.replaceAll('/api', '');
      final res = await dio.get('$cleanUrl/api/health');
      if (res.statusCode == 200) return true;
    } catch (_) {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: Duration(milliseconds: timeoutMs),
          receiveTimeout: Duration(milliseconds: timeoutMs),
        ));
        final res = await dio.get('$url/Service');
        if (res.statusCode == 200) return true;
      } catch (_) {}
    }
    return false;
  }

  // Tự động quét và chọn server đang phản hồi nhanh nhất
  static Future<String?> autoDetectWorkingServer() async {
    final candidates = <String>{
      if (_cachedBaseUrl != null) _cachedBaseUrl!,
      ...candidateUrls,
    }.toList();

    for (final url in candidates) {
      final isOnline = await ping(url, timeoutMs: 1200);
      if (isOnline) {
        setBaseUrl(url);
        return url;
      }
    }
    return null;
  }

  static const String loginEndpoint = '/Auth/login';
  static const String registerEndpoint = '/Auth/register';
  static const String vehicleEndpoint = '/Vehicle';
  static const String profileEndpoint = '/Auth/profile';
  static const String meEndpoint = '/Auth/me';
}
