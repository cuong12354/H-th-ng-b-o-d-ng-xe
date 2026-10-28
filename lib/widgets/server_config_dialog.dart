import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../services/api_service.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  bool? _isOnline;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
    _testCurrentUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testCurrentUrl([String? urlToTest]) async {
    final url = urlToTest ?? _urlController.text.trim();
    setState(() {
      _isTesting = true;
      _statusMessage = 'Đang kiểm tra kết nối tới máy chủ...';
    });

    final ok = await ApiConfig.ping(url, timeoutMs: 2000);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _isOnline = ok;
      _statusMessage = ok
          ? 'Máy chủ hoạt động bình thường! (Port 5054 OK)'
          : 'Không thể kết nối! Vui lòng đảm bảo backend đang chạy.';
    });
  }

  Future<void> _autoDetect() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Đang quét tự động các cổng máy chủ khả dụng...';
    });

    final working = await ApiConfig.autoDetectWorkingServer();

    if (!mounted) return;
    if (working != null) {
      _urlController.text = working;
      ApiService().updateBaseUrl(working);
      setState(() {
        _isTesting = false;
        _isOnline = true;
        _statusMessage = 'Đã tự động kết nối thành công: $working';
      });
    } else {
      setState(() {
        _isTesting = false;
        _isOnline = false;
        _statusMessage = 'Không tìm thấy server nào đang chạy trên cổng 5054.';
      });
    }
  }

  void _applyUrl(String url) {
    _urlController.text = url;
    ApiService().updateBaseUrl(url);
    _testCurrentUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E212B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.dns, color: Color(0xFFE60012), size: 22),
          SizedBox(width: 8),
          Text(
            'Cấu hình Kết nối Máy chủ',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ API Backend hiện tại:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF14161E),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2C303E)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFE60012)),
                  onPressed: _testCurrentUrl,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Connection Status Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isOnline == true
                    ? const Color(0xFF2ECC71).withAlpha(20)
                    : (_isOnline == false ? Colors.red.withAlpha(20) : const Color(0xFF14161E)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isOnline == true
                      ? const Color(0xFF2ECC71)
                      : (_isOnline == false ? Colors.red : const Color(0xFF2C303E)),
                ),
              ),
              child: Row(
                children: [
                  if (_isTesting)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  else
                    Icon(
                      _isOnline == true ? Icons.check_circle : (_isOnline == false ? Icons.error : Icons.info_outline),
                      size: 16,
                      color: _isOnline == true
                          ? const Color(0xFF2ECC71)
                          : (_isOnline == false ? Colors.red : Colors.white70),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage ?? 'Chưa kiểm tra',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isOnline == true
                            ? const Color(0xFF2ECC71)
                            : (_isOnline == false ? Colors.red.shade300 : Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Chọn nhanh IP môi trường:',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildPresetTile(
              title: 'Android Emulator',
              url: ApiConfig.emulatorUrl,
              desc: 'Dành cho máy ảo Android Studio (10.0.2.2:5054)',
            ),
            const SizedBox(height: 6),
            _buildPresetTile(
              title: 'Điện thoại thật (Cùng Wi-Fi)',
              url: ApiConfig.lanWifiUrl,
              desc: 'Dành cho điện thoại cắm cáp / Wi-Fi (192.168.1.159:5054)',
            ),
            const SizedBox(height: 6),
            _buildPresetTile(
              title: 'Localhost / ADB Reverse',
              url: ApiConfig.localhostUrl,
              desc: 'Dùng khi có adb reverse hoặc máy ảo (127.0.0.1:5054)',
            ),
            const SizedBox(height: 6),
            _buildPresetTile(
              title: 'Windows Desktop / Web',
              url: ApiConfig.pcUrl,
              desc: 'Dành cho ứng dụng chạy trên Windows/Web (localhost:5054)',
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.radar, size: 16, color: Color(0xFFE60012)),
                label: const Text(
                  'Tự động quét & kết nối IP máy chủ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE60012)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: _isTesting ? null : _autoDetect,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE60012),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isNotEmpty) {
              ApiService().updateBaseUrl(url);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF2ECC71),
                  content: Text('Đã cập nhật máy chủ: $url'),
                ),
              );
            }
          },
          child: const Text('Lưu & Áp dụng'),
        ),
      ],
    );
  }

  Widget _buildPresetTile({
    required String title,
    required String url,
    required String desc,
  }) {
    final isCurrent = _urlController.text.trim() == url;
    return InkWell(
      onTap: () => _applyUrl(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFE60012).withAlpha(30) : const Color(0xFF14161E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? const Color(0xFFE60012) : const Color(0xFF2C303E),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isCurrent ? const Color(0xFFE60012) : const Color(0xFF8E92A0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xFF8E92A0), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
