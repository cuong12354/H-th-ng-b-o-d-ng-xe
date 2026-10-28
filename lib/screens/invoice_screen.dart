import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/invoice_provider.dart';

class InvoiceScreen extends StatefulWidget {
  final bool isAdmin;
  final int? initialAppointmentId;

  const InvoiceScreen({
    super.key,
    this.isAdmin = false,
    this.initialAppointmentId,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String _selectedFilter = 'ALL'; // ALL, PAID, UNPAID
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      await provider.fetchInvoices();

      // If user came specifically to view a specific appointment's invoice
      if (widget.initialAppointmentId != null && mounted) {
        final inv = await provider.getInvoiceByAppointmentId(
          widget.initialAppointmentId!,
        );
        if (inv != null && mounted) {
          _showInvoiceDetailModal(inv);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPaymentMethod(String? method) {
    if (method == null || method.isEmpty) return 'Tiền mặt tại quầy';
    final m = method.toUpperCase();
    if (m == 'CASH') return 'Tiền mặt tại quầy (CASH)';
    if (m == 'BANK_TRANSFER') return 'Chuyển khoản quầy (BANK TRANSFER)';
    if (m == 'VNPAY') return 'Ví điện tử VNPay';
    if (m == 'CARD' || m == 'POS') return 'Quẹt thẻ POS tại quầy';
    return method;
  }

  void _showPaymentDialog(Map<String, dynamic> invoice) {
    String selectedMethod = 'CASH';
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    final finalAmount = (invoice['finalAmount'] as num?)?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E212B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Thanh toán Hóa đơn',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã HĐ: ${invoice['invoiceCode'] ?? "HĐ"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Khách hàng: ${invoice['customerName'] ?? "Khách hàng"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (invoice['licensePlate'] != null)
                    Text(
                      'Biển số: ${invoice['licensePlate']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Tổng tiền: ${currencyFormatter.format(finalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    dropdownColor: const Color(0xFF222632),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: 'CASH',
                        child: Text(
                          'Tiền mặt tại quầy (CASH)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'BANK_TRANSFER',
                        child: Text(
                          'Chuyển khoản Ngân hàng',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'VNPAY',
                        child: Text(
                          'Cổng thanh toán VNPay',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedMethod = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Phương thức thanh toán',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF14161E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2C303E)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final success = await Provider.of<InvoiceProvider>(
                      context,
                      listen: false,
                    ).payInvoice(invoice['id'], selectedMethod);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success
                              ? const Color(0xFF2ECC71)
                              : Colors.red,
                          content: Text(
                            success
                                ? 'Thanh toán thành công! Hóa đơn đã được lưu trên tài khoản.'
                                : 'Thanh toán thất bại, vui lòng thử lại.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Xác nhận Thanh toán'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetailModal(Map<String, dynamic> invoice) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    final isPaid = invoice['paymentStatus'] == 'PAID';
    final totalAmount = (invoice['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final discount = (invoice['discount'] as num?)?.toDouble() ?? 0.0;
    final finalAmount = (invoice['finalAmount'] as num?)?.toDouble() ?? 0.0;
    final dateStr = invoice['createdAt'] != null
        ? DateFormat('dd/MM/yyyy HH:mm')
              .format(DateTime.parse(invoice['createdAt']).toLocal())
        : 'Hôm nay';
    final items = (invoice['items'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E212B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE60012).withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFFE60012),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'HÓA ĐƠN DỊCH VỤ ĐIỆN TỬ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2C303E), height: 1),

              // Invoice Printable Card
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Official Receipt Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Garage Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.directions_car,
                                      size: 40,
                                      color: Color(0xFFE60012),
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'BLACKMYTH AUTO SERVICE',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Hệ thống Chăm sóc & Bảo dưỡng Ô tô - Xe máy',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      'Hotline: 1900 8989 • MST: 0108998877',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 24,
                            thickness: 1,
                            color: Colors.black12,
                          ),

                          // Invoice Code & Stamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MÃ HĐ: ${invoice['invoiceCode'] ?? "INV-OFFLINE"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF14161E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ngày tạo: $dateStr',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),

                              // Official Paid Stamp
                              if (isPaid)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFE60012),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: const [
                                      Text(
                                        'ĐÃ THANH TOÁN',
                                        style: TextStyle(
                                          color: Color(0xFFE60012),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        'TẠI CỬA HÀNG',
                                        style: TextStyle(
                                          color: Color(0xFFE60012),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.orange.shade800,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'CHỜ THANH TOÁN',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Customer & Vehicle Info Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black.withAlpha(15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Khách hàng: ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        invoice['customerName'] ??
                                            'Khách vãng lai',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (invoice['customerPhone'] != null &&
                                    invoice['customerPhone']
                                        .toString()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Số điện thoại: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        invoice['customerPhone'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_car_outlined,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Phương tiện: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${invoice["vehicleModel"] ?? ""} (${invoice["licensePlate"] ?? "Chưa rõ"})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Items Header
                          const Text(
                            'DANH MỤC DỊCH VỤ / PHỤ TÙNG:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Table of items
                          if (items.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F3F5),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            'Dịch vụ / Hạng mục',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'SL',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            'Thành tiền',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...items.map((item) {
                                    final price =
                                        (item['totalPrice'] as num?)
                                            ?.toDouble() ??
                                        ((item['unitPrice'] as num?)
                                                ?.toDouble() ??
                                            0.0);
                                    final qty = item['quantity'] ?? 1;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              item['itemName'] ??
                                                  'Dịch vụ bảo dưỡng',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '$qty',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              currencyFormatter.format(price),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF2ECC71),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gói bảo dưỡng định kỳ tổng thể cho xe ${invoice["licensePlate"]}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(finalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Calculation Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Tạm tính:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(totalAmount),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                if (discount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Giảm giá / Ưu đãi:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFE60012),
                                        ),
                                      ),
                                      Text(
                                        '-${currencyFormatter.format(discount)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFE60012),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(
                                  height: 16,
                                  color: Colors.black12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TỔNG THANH TOÁN:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(finalAmount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: Color(0xFFE60012),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment Method info
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Hình thức thanh toán: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _formatPaymentMethod(
                                    invoice['paymentMethod'],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Legal Note
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF2ECC71),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Hóa đơn điện tử hợp lệ được đồng bộ tự động từ quầy thu ngân. Có giá trị bảo hành trên toàn hệ thống Blackmyth Auto.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF27AE60),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF3A3F50)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Lưu vào máy'),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF2ECC71),
                                  content: Text(
                                    'Đã lưu bản sao Hóa đơn điện tử vào bộ nhớ máy!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE60012),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Chia sẻ'),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã chia sẻ hóa đơn ${invoice["invoiceCode"]} thành công!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );

    Widget bodyContent = Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE60012)),
          );
        }

        final allInvoices = provider.invoices;
        final paidCount = provider.paidInvoices.length;
        final unpaidCount = provider.unpaidInvoices.length;

        // Filter list
        var filteredList = allInvoices.where((inv) {
          final isPaid = inv['paymentStatus'] == 'PAID';
          if (_selectedFilter == 'PAID' && !isPaid) return false;
          if (_selectedFilter == 'UNPAID' && isPaid) return false;

          if (_searchQuery.isNotEmpty) {
            final code = (inv['invoiceCode'] ?? '').toString().toLowerCase();
            final plate = (inv['licensePlate'] ?? '').toString().toLowerCase();
            final cust = (inv['customerName'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            if (!code.contains(query) &&
                !plate.contains(query) &&
                !cust.contains(query)) {
              return false;
            }
          }
          return true;
        }).toList();

        return RefreshIndicator(
          color: const Color(0xFFE60012),
          backgroundColor: const Color(0xFF1E212B),
          onRefresh: () async => provider.fetchInvoices(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(0.4, -0.3),
                    radius: 1.3,
                    colors: [Color(0xFF2D3242), Color(0xFF14161E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C303E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.receipt_long,
                              color: Color(0xFFE60012),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'HÓA ĐƠN & BIÊN LAI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.storefront,
                                color: Color(0xFF2ECC71),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Đồng bộ tại quầy',
                                style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tất cả dịch vụ khách thanh toán tại quầy thu ngân của gara sẽ tự động đồng bộ và lưu trữ hóa đơn điện tử tại đây.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatBox(
                          title: 'Tổng hóa đơn',
                          value: '${allInvoices.length}',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          title: 'Đã thanh toán',
                          value: '$paidCount',
                          color: const Color(0xFF2ECC71),
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          title: 'Chờ thanh toán',
                          value: '$unpaidCount',
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã HĐ, biển số xe, tên khách...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E92A0),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8E92A0),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E212B),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2C303E)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2C303E)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'Tất cả (${allInvoices.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'PAID',
                      'Đã thanh toán tại quầy ($paidCount)',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('UNPAID', 'Chờ thanh toán ($unpaidCount)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Invoices List
              if (filteredList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.receipt_outlined,
                          color: Color(0xFF8E92A0),
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có hóa đơn nào',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Khi bạn thực hiện dịch vụ tại trung tâm và thanh toán tại quầy, hóa đơn điện tử sẽ hiển thị tại đây.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8E92A0),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredList.map((inv) {
                  final isPaid = inv['paymentStatus'] == 'PAID';
                  final finalAmount =
                      (inv['finalAmount'] as num?)?.toDouble() ?? 0.0;
                  final date = inv['createdAt'] != null
                      ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.parse(inv['createdAt']).toLocal())
                      : '';
                  final items = (inv['items'] as List?) ?? [];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E212B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPaid
                            ? const Color(0xFF2ECC71).withAlpha(50)
                            : const Color(0xFF2C303E),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showInvoiceDetailModal(inv),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? const Color(0xFF2ECC71)
                                                    .withAlpha(30)
                                              : Colors.orange.withAlpha(30),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPaid
                                              ? Icons.check_circle
                                              : Icons.schedule,
                                          color: isPaid
                                              ? const Color(0xFF2ECC71)
                                              : Colors.orangeAccent,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        inv['invoiceCode'] ?? 'Hóa đơn',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? const Color(0xFF2ECC71)
                                                .withAlpha(30)
                                          : Colors.orange.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isPaid
                                            ? const Color(0xFF2ECC71)
                                            : Colors.orangeAccent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isPaid) ...[
                                          const Icon(
                                            Icons.verified,
                                            size: 12,
                                            color: Color(0xFF2ECC71),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          isPaid
                                              ? 'ĐÃ THANH TOÁN TẠI CỬA HÀNG'
                                              : 'CHỜ THANH TOÁN',
                                          style: TextStyle(
                                            color: isPaid
                                                ? const Color(0xFF2ECC71)
                                                : Colors.orangeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFF2C303E),
                                height: 20,
                              ),

                              // Info rows
                              if (widget.isAdmin) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 15,
                                      color: Color(0xFF8E92A0),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Khách: ${inv["customerName"] ?? "N/A"}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_car_outlined,
                                        size: 15,
                                        color: Color(0xFFE60012),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Xe: ${inv["licensePlate"] ?? "N/A"}${inv["vehicleModel"] != null && inv["vehicleModel"].toString().isNotEmpty ? " - ${inv["vehicleModel"]}" : ""}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: Color(0xFF8E92A0),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Method
                              Row(
                                children: [
                                  const Icon(
                                    Icons.payments_outlined,
                                    size: 15,
                                    color: Color(0xFF8E92A0),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hình thức: ${_formatPaymentMethod(inv["paymentMethod"])}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // Services snippet if available
                              if (items.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: items.take(2).map((it) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF14161E),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF2C303E),
                                        ),
                                      ),
                                      child: Text(
                                        it['itemName'] ?? 'Dịch vụ',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Price & Actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Số tiền thanh toán:',
                                        style: TextStyle(
                                          color: Color(0xFF8E92A0),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(finalAmount),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: isPaid
                                              ? const Color(0xFF2ECC71)
                                              : const Color(0xFFE60012),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFF3A3F50),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'Xem hóa đơn',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () =>
                                            _showInvoiceDetailModal(inv),
                                      ),
                                      if (!isPaid && !widget.isAdmin) ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE60012,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _showPaymentDialog(inv),
                                          child: const Text(
                                            'Thanh toán',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                      if (!isPaid && widget.isAdmin) ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2ECC71,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _showPaymentDialog(inv),
                                          child: const Text(
                                            'Thu tiền',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );

    if (!widget.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0E12),
        appBar: AppBar(
          title: const Text(
            'Hóa đơn điện tử',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: const BackButton(color: Colors.white),
          backgroundColor: const Color(0xFF14161E),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => Provider.of<InvoiceProvider>(
                context,
                listen: false,
              ).fetchInvoices(),
            ),
          ],
        ),
        body: SafeArea(child: bodyContent),
      );
    }

    return Container(color: const Color(0xFF0D0E12), child: bodyContent);
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C303E)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8E92A0), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE60012) : const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE60012)
                : const Color(0xFF2C303E),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8E92A0),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
