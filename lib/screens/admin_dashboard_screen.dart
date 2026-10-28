import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/part_provider.dart';
import '../providers/review_provider.dart';
import '../models/service_model.dart';
import '../models/part_model.dart';
import 'staff_dashboard_screen.dart';
import 'login_screen.dart';
import '../widgets/admin_store_content_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Filters & Search
  String _selectedTicketFilter = 'Tất cả';
  String _ticketSearchQuery = '';
  String _selectedPartCategory = 'ALL';
  String _partSearchQuery = '';
  String _selectedInvoiceFilter = 'ALL';
  String _invoiceSearchQuery = '';
  String _serviceSearchQuery = '';
  String _customerSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments();
    Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    Provider.of<PartProvider>(context, listen: false).fetchParts();
    Provider.of<ReviewProvider>(context, listen: false).fetchReviews();
  }

  String _getMenuTitle(int index, [bool isShort = false]) {
    switch (index) {
      case 0:
        return isShort ? 'Tổng quan' : 'Tổng quan kinh doanh & Xưởng xe';
      case 1:
        return isShort ? 'Phiếu dịch vụ' : 'Phiếu dịch vụ (Xe tại Gara)';
      case 2:
        return isShort ? 'Kho phụ tùng' : 'Kho phụ tùng & Vật tư';
      case 3:
        return isShort ? 'Hóa đơn' : 'Hóa đơn & Thu ngân';
      case 4:
        return isShort ? 'Dịch vụ' : 'Cấu hình Dịch vụ Gara';
      case 5:
        return isShort ? 'Khách hàng' : 'Danh sách Khách hàng';
      case 6:
        return isShort ? 'Đánh giá' : 'Đánh giá từ khách hàng';
      case 7:
        return isShort ? 'Cấu hình Tiệm' : 'Cấu hình Tiệm & Nội dung App Khách hàng';
      default:
        return 'Quản trị hệ thống';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    Widget sidebar = Container(
      width: 260,
      color: const Color(0xFF1B2A4A),
      child: Column(
        children: [
          // Sidebar Brand Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'BLACKMYTH AUTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user, color: Colors.redAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        user?.fullName != null ? 'Admin: ${user!.fullName}' : 'QUẢN TRỊ VIÊN TOÀN QUYỀN',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(0, Icons.dashboard_outlined, 'Tổng quan & Thống kê'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'QUYỀN THAO TÁC XƯỞNG (STAFF)',
                    style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                _buildMenuItem(1, Icons.directions_car_outlined, 'Phiếu dịch vụ (Xe tại Gara)', badgeText: 'Xưởng'),
                _buildMenuItem(2, Icons.inventory_2_outlined, 'Kho phụ tùng & Vật tư', badgeText: 'Kho'),
                _buildMenuItem(3, Icons.receipt_long_outlined, 'Hóa đơn & Thu ngân', badgeText: 'Thu ngân'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'QUẢN TRỊ KINH DOANH',
                    style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                _buildMenuItem(4, Icons.build_outlined, 'Cấu hình Dịch vụ Gara'),
                _buildMenuItem(5, Icons.people_outline, 'Danh sách Khách hàng'),
                _buildMenuItem(6, Icons.star_outline, 'Đánh giá từ khách hàng'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'CẤU HÌNH TIỆM & APP KHÁCH',
                    style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                _buildMenuItem(7, Icons.storefront_outlined, 'Cấu hình Tiệm & Chiến dịch', badgeText: 'App Khách'),

                const Divider(color: Colors.white12, height: 20),

                // Fast switch to Staff Interface
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3A47).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.swap_horiz, color: Color(0xFF2ECC71)),
                    title: const Text(
                      'Giao diện Nhân viên',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: const Text(
                      'Chuyển sang Staff View',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white54),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StaffDashboardScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: isDesktop
          ? null
          : AppBar(
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMenuTitle(_selectedIndex, true),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1B2A4A),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Làm mới',
                  onPressed: _refreshAllData,
                ),
                if (_selectedIndex == 1)
                  IconButton(
                    icon: const Icon(Icons.add_task),
                    tooltip: 'Tiếp nhận xe',
                    onPressed: () => _showStaffCreateTicketDialog(context),
                  ),
                if (_selectedIndex == 2)
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined),
                    tooltip: 'Thêm phụ tùng',
                    onPressed: () => _showAddPartDialog(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Giao diện Staff',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StaffDashboardScreen()),
                    );
                  },
                ),
              ],
            ),
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (isDesktop) sidebar,
          Expanded(
            child: Column(
              children: [
                // Desktop Top Navigation & Action Bar
                if (isDesktop)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getMenuTitle(_selectedIndex),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                            ),
                            const Text(
                              'Đặc quyền Quản trị viên: Toàn quyền truy cập nghiệp vụ xưởng & quản lý gara',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Context-sensitive Actions
                        if (_selectedIndex == 1)
                          ElevatedButton.icon(
                            onPressed: () => _showStaffCreateTicketDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tiếp nhận xe mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        if (_selectedIndex == 2)
                          ElevatedButton.icon(
                            onPressed: () => _showAddPartDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm phụ tùng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        if (_selectedIndex == 4)
                          ElevatedButton.icon(
                            onPressed: () => _showServiceDialog(null),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm Dịch Vụ Mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF26522),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),

                        const SizedBox(width: 12),

                        // Switch to Staff Dashboard Button
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const StaffDashboardScreen()),
                            );
                          },
                          icon: const Icon(Icons.swap_horiz, size: 18, color: Color(0xFF1B2A4A)),
                          label: const Text('Xem giao diện Staff', style: TextStyle(color: Color(0xFF1B2A4A))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1B2A4A)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),

                        const SizedBox(width: 12),

                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          tooltip: 'Làm mới dữ liệu',
                          onPressed: _refreshAllData,
                        ),
                      ],
                    ),
                  ),

                // Main Content Tab
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {String? badgeText}) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? const Border(left: BorderSide(color: Color(0xFFF26522), width: 3)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFF26522) : Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF26522).withValues(alpha: 0.3) : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFF26522) : Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildTicketsTab();
      case 2:
        return _buildInventoryTab();
      case 3:
        return _buildInvoicesTab();
      case 4:
        return _buildServicesTab();
      case 5:
        return _buildCustomersTab();
      case 6:
        return _buildReviewsTab();
      case 7:
        return const AdminStoreContentView();
      default:
        return _buildOverview();
    }
  }

  // ================= TAB 0: TỔNG QUAN DOANH THU & XƯỞNG XE =================
  Widget _buildOverview() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final partProvider = Provider.of<PartProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final now = DateTime.now();

    final appts = appointmentProvider.appointments;
    final totalTickets = appts.length;
    final pending = appts.where((a) => a['status'] == 'PENDING' || a['status'] == 'CONFIRMED').length;
    final inProgress = appts.where((a) => a['status'] == 'MAINTENANCE').length;
    final completed = appts.where((a) => a['status'] == 'COMPLETED' || a['status'] == 'PAID').length;

    final parts = partProvider.parts;
    final totalParts = parts.length;
    final lowStockParts = parts.where((p) => p.stockQuantity < 10).length;

    double monthlyRevenue = appts
        .where((a) {
          if (a['status'] != 'PAID') return false;
          final date = DateTime.parse(a['scheduledDate']).toLocal();
          return date.month == now.month && date.year == now.year;
        })
        .fold(0.0, (sum, a) => sum + (a['totalEstimatedPrice'] as num).toDouble());

    double yearlyRevenue = appts
        .where((a) {
          if (a['status'] != 'PAID') return false;
          final date = DateTime.parse(a['scheduledDate']).toLocal();
          return date.year == now.year;
        })
        .fold(0.0, (sum, a) => sum + (a['totalEstimatedPrice'] as num).toDouble());

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final activeJobs = appts.where((a) => a['status'] == 'CONFIRMED' || a['status'] == 'MAINTENANCE').toList();

    return RefreshIndicator(
      onRefresh: () async => _refreshAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Financial & Business Revenue
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Doanh thu tháng này',
                    currencyFormatter.format(monthlyRevenue),
                    Icons.monetization_on,
                    Colors.green,
                    subtitle: 'Tháng ${now.month}/${now.year}',
                  ),
                ),
                SizedBox(width: isDesktop ? 14 : 8),
                Expanded(
                  child: _buildMetricCard(
                    'Doanh thu năm nay',
                    currencyFormatter.format(yearlyRevenue),
                    Icons.trending_up,
                    Colors.blue,
                    subtitle: 'Năm ${now.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Workshop Operations Cards (2x2 on mobile, or 4 in 1 row on desktop)
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Xe chờ tiếp nhận',
                      pending.toString(),
                      Icons.access_time,
                      Colors.orange,
                      subtitle: 'Cần làm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Đang sửa chữa',
                      inProgress.toString(),
                      Icons.build_circle,
                      Colors.purple,
                      subtitle: 'Tại xưởng',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Đã xong / Thu tiền',
                      completed.toString(),
                      Icons.check_circle,
                      const Color(0xFF2ECC71),
                      subtitle: '$completed / $totalTickets phiếu',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Kho phụ tùng',
                      totalParts.toString(),
                      Icons.inventory_2,
                      const Color(0xFF1B2A4A),
                      subtitle: lowStockParts > 0 ? '$lowStockParts mã sắp hết' : 'Tồn kho ổn định',
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Xe chờ tiếp nhận',
                      pending.toString(),
                      Icons.access_time,
                      Colors.orange,
                      subtitle: 'Cần phân bổ thợ',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Đang sửa chữa',
                      inProgress.toString(),
                      Icons.build_circle,
                      Colors.purple,
                      subtitle: 'Tại xưởng gara',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Đã xong / Thu tiền',
                      completed.toString(),
                      Icons.check_circle,
                      const Color(0xFF2ECC71),
                      subtitle: '$completed / $totalTickets phiếu',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Kho phụ tùng',
                      totalParts.toString(),
                      Icons.inventory_2,
                      const Color(0xFF1B2A4A),
                      subtitle: lowStockParts > 0 ? '$lowStockParts sắp hết' : 'Tồn kho ổn định',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Fast Operational Action Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2A4A), Color(0xFF2C3A47)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.speed, color: Colors.orangeAccent, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thao tác nghiệp vụ nhanh',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Admin có toàn quyền tiếp nhận xe vãng lai, cập nhật tiến độ & nhập kho phụ tùng.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_task, size: 16),
                              label: const Text('Tiếp nhận xe'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2ECC71),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _showStaffCreateTicketDialog(context),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_box, size: 16),
                              label: const Text('Nhập phụ tùng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF26522),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _showAddPartDialog(context),
                            ),
                          ],
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.speed, color: Colors.orangeAccent, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nghiệp vụ Xưởng nhanh',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'Tiếp nhận xe mới hoặc nhập thêm kho',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add_task, size: 15),
                                label: const Text('Tiếp nhận xe', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _showStaffCreateTicketDialog(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add_box, size: 15),
                                label: const Text('Nhập phụ tùng', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF26522),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _showAddPartDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Active Jobs in Garage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.garage, color: Color(0xFF1B2A4A), size: 20),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Xe cần xử lý tại xưởng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Xem tất cả →', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),

            if (activeJobs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('Hiện tại không có xe nào đang chờ sửa tại gara.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...activeJobs.map((a) {
                final isMaintenance = a['status'] == 'MAINTENANCE';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: isMaintenance ? Colors.purple.shade50 : Colors.blue.shade50,
                      child: Icon(
                        isMaintenance ? Icons.build : Icons.directions_car,
                        color: isMaintenance ? Colors.purple : Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            a['customerName'] ?? 'Khách vãng lai',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFB9D5FF)),
                          ),
                          child: Text(
                            a['licensePlate'] ?? 'Chưa rõ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E5BB0)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Dịch vụ: ${(a["services"] as List?)?.join(", ") ?? "Chưa rõ"}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMaintenance ? Colors.purple : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _showUpdateStatusDialog(context, a),
                      child: Text(isMaintenance ? 'Đang sửa ⚙️' : 'Chờ làm ⏳', style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: PHIẾU DỊCH VỤ (XE TẠI GARA) =================
  Widget _buildTicketsTab() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var appts = provider.appointments;

        // Filter by Status
        if (_selectedTicketFilter == 'Chờ sửa') {
          appts = appts.where((a) => a['status'] == 'CONFIRMED' || a['status'] == 'PENDING').toList();
        } else if (_selectedTicketFilter == 'Đang sửa') {
          appts = appts.where((a) => a['status'] == 'MAINTENANCE').toList();
        } else if (_selectedTicketFilter == 'Hoàn thành') {
          appts = appts.where((a) => a['status'] == 'COMPLETED' || a['status'] == 'PAID').toList();
        }

        // Search Query
        if (_ticketSearchQuery.isNotEmpty) {
          appts = appts.where((a) {
            final name = (a['customerName'] as String? ?? '').toLowerCase();
            final plate = (a['licensePlate'] as String? ?? '').toLowerCase();
            final phone = (a['customerPhone'] as String? ?? '').toLowerCase();
            final q = _ticketSearchQuery.toLowerCase();
            return name.contains(q) || plate.contains(q) || phone.contains(q);
          }).toList();
        }

        return Column(
          children: [
            // Filter & Search Header
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Column(
                children: [
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm theo tên khách, biển số xe, SĐT...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) => setState(() => _ticketSearchQuery = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showStaffCreateTicketDialog(context),
                          icon: const Icon(Icons.add_task, size: 18),
                          label: const Text('Tiếp nhận xe mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        )
                      ],
                    )
                  else ...[
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm theo tên, biển số, SĐT...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => setState(() => _ticketSearchQuery = val),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showStaffCreateTicketDialog(context),
                        icon: const Icon(Icons.add_task, size: 16),
                        label: const Text('Tiếp nhận xe mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text('${appts.length} phiếu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 12),
                        _buildTicketFilterChip('Tất cả'),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip('Chờ sửa'),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip('Đang sửa'),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip('Hoàn thành'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tickets Grid / List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: appts.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async => provider.fetchAppointments(),
                        child: ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('Không có phiếu dịch vụ nào phù hợp với bộ lọc.')),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth <= 700) {
                            return RefreshIndicator(
                              onRefresh: () async => provider.fetchAppointments(),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: appts.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildTicketCard(appts[index]),
                                  );
                                },
                              ),
                            );
                          }
                          int crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                          return RefreshIndicator(
                            onRefresh: () async => provider.fetchAppointments(),
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 1.6,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: appts.length,
                              itemBuilder: (context, index) {
                                return _buildTicketCard(appts[index]);
                              },
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildTicketFilterChip(String label) {
    final isSelected = _selectedTicketFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF2ECC71),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
      visualDensity: VisualDensity.compact,
      onSelected: (val) {
        if (val) setState(() => _selectedTicketFilter = label);
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> appointment) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(appointment['scheduledDate']).toLocal());
    final status = appointment['status'] as String;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final total = (appointment['totalEstimatedPrice'] as num?)?.toDouble() ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Customer & Plate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appointment['customerName'] ?? 'Khách vãng lai',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFB9D5FF)),
                ),
                child: Text(
                  appointment['licensePlate'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5BB0), fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 11, color: Colors.grey),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const Spacer(),
              _buildStatusBadge(status),
            ],
          ),
          const Divider(height: 14),

          // Services chips
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: ((appointment['services'] as List?) ?? []).map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(s.toString(), style: const TextStyle(fontSize: 11, color: Colors.black87)),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Total & Update button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng tiền dự kiến:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    currencyFormatter.format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 13),
                label: const Text('Tiến độ', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2A4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showUpdateStatusDialog(context, appointment),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: KHO PHỤ TÙNG & VẬT TƯ =================
  Widget _buildInventoryTab() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Consumer<PartProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var parts = provider.parts;
        if (_selectedPartCategory == 'SPARE_PART') {
          parts = parts.where((p) => p.isSparePart).toList();
        } else if (_selectedPartCategory == 'ACCESSORY') {
          parts = parts.where((p) => p.isAccessory).toList();
        }

        if (_partSearchQuery.isNotEmpty) {
          parts = parts
              .where((p) =>
                  p.name.toLowerCase().contains(_partSearchQuery.toLowerCase()) ||
                  p.description.toLowerCase().contains(_partSearchQuery.toLowerCase()))
              .toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Column(
                children: [
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Tìm phụ tùng, linh kiện, phụ kiện theo tên/mô tả...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) => setState(() => _partSearchQuery = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddPartDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm phụ tùng mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        )
                      ],
                    )
                  else ...[
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm phụ tùng, linh kiện, phụ kiện...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => setState(() => _partSearchQuery = val),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPartDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Thêm phụ tùng mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          selected: _selectedPartCategory == 'ALL',
                          label: Text('Tất cả (${provider.parts.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'ALL'),
                          selectedColor: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedPartCategory == 'SPARE_PART',
                          label: Text('⚙️ Phụ tùng (${provider.spareParts.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'SPARE_PART'),
                          selectedColor: Colors.blue.withValues(alpha: 0.3),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedPartCategory == 'ACCESSORY',
                          label: Text('🛡️ Phụ kiện (${provider.accessories.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'ACCESSORY'),
                          selectedColor: Colors.amber.withValues(alpha: 0.3),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => provider.fetchParts(),
                child: parts.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text('Kho phụ tùng hiện đang trống hoặc không khớp bộ lọc.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: parts.length,
                        itemBuilder: (context, index) {
                          final part = parts[index];
                          final isOutOfStock = part.stockQuantity <= 0;
                          final isLowStock = part.stockQuantity > 0 && part.stockQuantity < 10;

                          Color badgeColor = Colors.green;
                          String badgeText = 'Còn hàng';
                          if (isOutOfStock) {
                            badgeColor = Colors.red;
                            badgeText = 'Hết hàng';
                          } else if (isLowStock) {
                            badgeColor = Colors.orange;
                            badgeText = 'Sắp hết (${part.stockQuantity})';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  part.isAccessory ? Icons.sports_motorsports : Icons.inventory_2,
                                  color: badgeColor,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(part.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Text(part.description.isNotEmpty ? part.description : 'Chưa có mô tả kỹ thuật', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 12,
                                    children: [
                                      Text(
                                        'Giá: ${currencyFormatter.format(part.price)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                                      ),
                                      Text('Tồn: ${part.stockQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: part.isAccessory ? Colors.amber.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          part.isAccessory ? '🛡️ Phụ kiện' : '⚙️ Phụ tùng',
                                          style: TextStyle(
                                            color: part.isAccessory ? Colors.amber.shade900 : Colors.blue.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                                    tooltip: 'Cập nhật tồn kho / giá',
                                    onPressed: () => _showEditPartDialog(context, part),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    tooltip: 'Xóa phụ tùng',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Xác nhận xóa'),
                                          content: Text('Bạn có chắc chắn muốn xóa phụ tùng "${part.name}" khỏi hệ thống?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Xóa'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await provider.deletePart(part.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  // ================= TAB 3: HÓA ĐƠN & THU NGÂN =================
  Widget _buildInvoicesTab() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var invoices = provider.invoices;
        if (_selectedInvoiceFilter == 'PAID') {
          invoices = invoices.where((i) => i['paymentStatus'] == 'PAID').toList();
        } else if (_selectedInvoiceFilter == 'UNPAID') {
          invoices = invoices.where((i) => i['paymentStatus'] != 'PAID').toList();
        }

        if (_invoiceSearchQuery.isNotEmpty) {
          invoices = invoices.where((i) {
            final code = (i['invoiceCode'] as String? ?? '').toLowerCase();
            final customer = (i['customerName'] as String? ?? '').toLowerCase();
            final plate = (i['licensePlate'] as String? ?? '').toLowerCase();
            final q = _invoiceSearchQuery.toLowerCase();
            return code.contains(q) || customer.contains(q) || plate.contains(q);
          }).toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm hóa đơn theo mã HĐ, tên khách, biển số...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) => setState(() => _invoiceSearchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text('${invoices.length} HĐ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _selectedInvoiceFilter == 'ALL',
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _selectedInvoiceFilter = 'ALL'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Chờ thu tiền'),
                          selected: _selectedInvoiceFilter == 'UNPAID',
                          selectedColor: Colors.orange.withValues(alpha: 0.3),
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _selectedInvoiceFilter = 'UNPAID'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Đã thanh toán'),
                          selected: _selectedInvoiceFilter == 'PAID',
                          selectedColor: Colors.green.withValues(alpha: 0.3),
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _selectedInvoiceFilter = 'PAID'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => provider.fetchInvoices(),
                child: invoices.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text('Chưa có hóa đơn nào.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final inv = invoices[index];
                          final isPaid = inv['paymentStatus'] == 'PAID';
                          final finalAmount = (inv['finalAmount'] as num?)?.toDouble() ?? 0.0;
                          final date = inv['createdAt'] != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(inv['createdAt']).toLocal())
                              : '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                child: Icon(
                                  isPaid ? Icons.check_circle : Icons.receipt_long,
                                  color: isPaid ? Colors.green : Colors.orange,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(inv['invoiceCode'] ?? 'Hóa đơn', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(
                                    currencyFormatter.format(finalAmount),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isPaid ? Colors.green : Colors.red),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Khách: ${inv["customerName"] ?? "N/A"} - Biển số: ${inv["licensePlate"] ?? "N/A"}', style: const TextStyle(fontSize: 13)),
                                  Text('Ngày lập: $date', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isPaid ? 'ĐÃ THANH TOÁN' : 'CHỜ THANH TOÁN',
                                          style: TextStyle(
                                            color: isPaid ? Colors.green : Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (!isPaid)
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.payment, size: 14),
                                          label: const Text('Thu tiền', style: TextStyle(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2ECC71),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          onPressed: () => _showPayInvoiceDialog(context, inv),
                                        )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  // ================= TAB 4: CẤU HÌNH DỊCH VỤ =================
  Widget _buildServicesTab() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var svcs = provider.services;
        if (_serviceSearchQuery.isNotEmpty) {
          svcs = svcs
              .where((s) =>
                  s.name.toLowerCase().contains(_serviceSearchQuery.toLowerCase()) ||
                  s.category.toLowerCase().contains(_serviceSearchQuery.toLowerCase()))
              .toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm dịch vụ theo tên hoặc danh mục...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) => setState(() => _serviceSearchQuery = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showServiceDialog(null),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm Dịch Vụ Mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF26522),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm dịch vụ theo tên hoặc danh mục...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onChanged: (val) => setState(() => _serviceSearchQuery = val),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showServiceDialog(null),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Thêm Dịch Vụ Mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF26522),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tên dịch vụ', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Thời gian dự kiến', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Giá tiền (VNĐ)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: svcs.map((s) {
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (s.isPopular) const SizedBox(width: 8),
                              if (s.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.orange, size: 14),
                                      SizedBox(width: 2),
                                      Text('Phổ biến', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          )),
                          DataCell(Text(s.category)),
                          DataCell(Text('${s.estimatedMinutes} phút')),
                          DataCell(Text(
                            currencyFormatter.format(s.price),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          )),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Sửa dịch vụ',
                                onPressed: () => _showServiceDialog(s),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Xóa dịch vụ',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: Text('Bạn có chắc muốn xóa dịch vụ "${s.name}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    provider.deleteService(s.id);
                                  }
                                },
                              ),
                            ],
                          ))
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  // ================= TAB 5: KHÁCH HÀNG =================
  Widget _buildCustomersTab() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // Extract unique customers from appointments
    final customers = <String, Map<String, dynamic>>{};
    for (var a in appointmentProvider.appointments) {
      final name = a['customerName'] as String? ?? 'Khách vãng lai';
      final plate = a['licensePlate'] as String? ?? '';
      customers.putIfAbsent(name, () => {'name': name, 'plates': <String>{}, 'appointments': 0, 'totalSpent': 0.0});
      if (plate.isNotEmpty) {
        (customers[name]!['plates'] as Set<String>).add(plate);
      }
      customers[name]!['appointments'] = (customers[name]!['appointments'] as int) + 1;
      if (a['status'] == 'PAID') {
        customers[name]!['totalSpent'] = (customers[name]!['totalSpent'] as double) + ((a['totalEstimatedPrice'] as num).toDouble());
      }
    }

    var customerList = customers.values.toList();
    if (_customerSearchQuery.isNotEmpty) {
      customerList = customerList.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final plates = (c['plates'] as Set<String>).join(' ').toLowerCase();
        final q = _customerSearchQuery.toLowerCase();
        return name.contains(q) || plates.contains(q);
      }).toList();
    }

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm khách hàng theo tên hoặc biển số xe...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (val) => setState(() => _customerSearchQuery = val),
          ),
        ),
        Expanded(
          child: customerList.isEmpty
              ? const Center(child: Text('Chưa có thông tin khách hàng nào.'))
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tên Khách Hàng', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Biển số xe', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Số lượt làm', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Tổng chi tiêu', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: customerList.map((c) {
                          final plates = (c['plates'] as Set<String>).join(', ');
                          return DataRow(cells: [
                            DataCell(Text(c['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(plates.isNotEmpty ? plates : 'Chưa lưu')),
                            DataCell(Text(c['appointments'].toString())),
                            DataCell(Text(
                              currencyFormatter.format(c['totalSpent']),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        )
      ],
    );
  }

  // ================= TAB 6: ĐÁNH GIÁ TỪ KHÁCH HÀNG =================
  Widget _buildReviewsTab() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.reviews.isEmpty) return const Center(child: Text('Chưa có đánh giá nào từ khách hàng.'));

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ListView.builder(
            itemCount: provider.reviews.length,
            itemBuilder: (context, index) {
              final r = provider.reviews[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    r['rating'].toString(),
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Row(
                  children: List.generate(
                    5,
                    (starIdx) => Icon(
                      starIdx < (r['rating'] as int) ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ),
                subtitle: Text(r['comment'] ?? 'Không có bình luận'),
                trailing: Text('Mã Hẹn: #${r['appointmentId']}'),
              );
            },
          ),
        );
      },
    );
  }

  // ================= DIALOGS (STAFF + ADMIN ACCESS) =================

  void _showStaffCreateTicketDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final List<int> selectedServiceIds = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
            return AlertDialog(
              title: const Text('Tiếp Nhận Xe - Tạo Phiếu Dịch Vụ'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin Khách hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên Khách hàng *', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại *', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      const Text('Thông tin Xe vào Xưởng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Biển số xe *', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Hãng xe (VD: Toyota)', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Dòng xe (VD: Vios)', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Dịch vụ Yêu cầu Thực hiện', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...serviceProvider.services.map((svc) {
                        return CheckboxListTile(
                          title: Text(svc.name, style: const TextStyle(fontSize: 14)),
                          subtitle: Text('${svc.category} • ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(svc.price)}', style: const TextStyle(fontSize: 12)),
                          value: selectedServiceIds.contains(svc.id),
                          onChanged: (val) {
                            setDlgState(() {
                              if (val == true) {
                                selectedServiceIds.add(svc.id);
                              } else {
                                selectedServiceIds.remove(svc.id);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (phoneCtrl.text.isEmpty || plateCtrl.text.isEmpty || selectedServiceIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập SĐT, Biển số và chọn ít nhất 1 dịch vụ')));
                      return;
                    }
                    final provider = Provider.of<AppointmentProvider>(context, listen: false);
                    final success = await provider.staffCreateAppointment(
                      customerName: nameCtrl.text,
                      customerPhone: phoneCtrl.text,
                      licensePlate: plateCtrl.text,
                      vehicleBrand: brandCtrl.text,
                      vehicleModel: modelCtrl.text,
                      serviceIds: selectedServiceIds,
                    );
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiếp nhận xe và tạo phiếu thành công!')));
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo phiếu thất bại!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                  child: const Text('TẠO PHIẾU TIẾP NHẬN'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Map<String, dynamic> appointment) {
    final statusOptions = [
      {'value': 'CONFIRMED', 'label': 'Đã tiếp nhận (Chờ sửa xe)'},
      {'value': 'MAINTENANCE', 'label': 'Đang bảo dưỡng / sửa chữa trong xưởng'},
      {'value': 'COMPLETED', 'label': 'Hoàn thành (Tự động xuất hóa đơn)'},
      {'value': 'CANCELLED', 'label': 'Hủy phiếu dịch vụ'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật tiến độ: ${appointment["customerName"] ?? "Khách"} (${appointment["licensePlate"]})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((s) {
            return ListTile(
              title: Text(s['label']!),
              onTap: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<AppointmentProvider>(context, listen: false);
                final success = await provider.updateAppointmentStatus(appointment['id'], s['value']!);

                if (success && s['value'] == 'COMPLETED') {
                  await provider.createInvoice(appointment['id']);
                  if (context.mounted) {
                    Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
                  }
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Cập nhật trạng thái thành công!' : 'Thất bại')));
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddPartDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '10');
    String category = 'SPARE_PART';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInner) {
          return AlertDialog(
            title: const Text('Thêm Phụ Tùng / Vật Tư Vào Kho'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Phân loại danh mục *'),
                      items: const [
                        DropdownMenuItem(value: 'SPARE_PART', child: Text('⚙️ Phụ tùng (Thay thế / Kỹ thuật)')),
                        DropdownMenuItem(value: 'ACCESSORY', child: Text('🛡️ Phụ kiện (Đồ chơi / Tiện ích)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setInner(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên phụ tùng / vật tư *')),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả / Thông số kỹ thuật')),
                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Đơn giá bán (VNĐ) *'), keyboardType: TextInputType.number),
                    TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Số lượng nhập ban đầu *'), keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và đơn giá')));
                    return;
                  }
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  final success = await Provider.of<PartProvider>(context, listen: false).addPart(nameCtrl.text, descCtrl.text, price, qty, category);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Thêm phụ tùng thành công!' : 'Thêm thất bại')));
                  }
                },
                child: const Text('Thêm vào kho'),
              )
            ],
          );
        },
      ),
    );
  }

  void _showEditPartDialog(BuildContext context, PartModel part) {
    final nameCtrl = TextEditingController(text: part.name);
    final descCtrl = TextEditingController(text: part.description);
    final priceCtrl = TextEditingController(text: part.price.toStringAsFixed(0));
    final qtyCtrl = TextEditingController(text: part.stockQuantity.toString());
    String category = part.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInner) {
          return AlertDialog(
            title: Text('Cập nhật: ${part.name}'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Phân loại danh mục *'),
                      items: const [
                        DropdownMenuItem(value: 'SPARE_PART', child: Text('⚙️ Phụ tùng (Thay thế / Kỹ thuật)')),
                        DropdownMenuItem(value: 'ACCESSORY', child: Text('🛡️ Phụ kiện (Đồ chơi / Tiện ích)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setInner(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên phụ tùng / phụ kiện')),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Đơn giá bán (VNĐ)'), keyboardType: TextInputType.number),
                    TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Số lượng tồn kho thực tế'), keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                onPressed: () async {
                  final price = double.tryParse(priceCtrl.text) ?? part.price;
                  final qty = int.tryParse(qtyCtrl.text) ?? part.stockQuantity;
                  final success = await Provider.of<PartProvider>(context, listen: false).updatePart(part.id, nameCtrl.text, descCtrl.text, price, qty, category);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Cập nhật thành công!' : 'Cập nhật thất bại')));
                  }
                },
                child: const Text('Lưu thay đổi'),
              )
            ],
          );
        },
      ),
    );
  }

  void _showPayInvoiceDialog(BuildContext context, Map<String, dynamic> invoice) {
    String selectedMethod = 'CASH';
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final amount = (invoice['finalAmount'] as num?)?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: const Text('Xác nhận Thu tiền Hóa đơn'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã HĐ: ${invoice["invoiceCode"]}'),
                    Text('Khách hàng: ${invoice["customerName"]}'),
                    const SizedBox(height: 12),
                    Text(
                      'Số tiền thu: ${currencyFormatter.format(amount)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      items: const [
                        DropdownMenuItem(value: 'CASH', child: Text('Tiền mặt (CASH)')),
                        DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Chuyển khoản Ngân hàng')),
                        DropdownMenuItem(value: 'VNPAY', child: Text('Ví điện tử / VNPAY')),
                      ],
                      onChanged: (val) {
                        setDlgState(() => selectedMethod = val!);
                      },
                      decoration: const InputDecoration(labelText: 'Hình thức thanh toán', border: OutlineInputBorder()),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final success = await Provider.of<InvoiceProvider>(context, listen: false).payInvoice(invoice['id'], selectedMethod);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Thanh toán hóa đơn thành công!' : 'Thanh toán thất bại')),
                      );
                    }
                  },
                  child: const Text('XÁC NHẬN THU TIỀN'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showServiceDialog(dynamic service) {
    final isEditing = service != null;
    final nameCtrl = TextEditingController(text: isEditing ? service.name : '');
    final priceCtrl = TextEditingController(text: isEditing ? service.price.toStringAsFixed(0) : '');
    final categoryCtrl = TextEditingController(text: isEditing ? service.category : 'Bảo dưỡng');
    final imgCtrl = TextEditingController(text: isEditing ? service.imageUrl : '');
    bool isPopular = isEditing ? service.isPopular : false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInner) {
          return AlertDialog(
            title: Text(isEditing ? 'Sửa dịch vụ' : 'Thêm dịch vụ mới'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên dịch vụ *')),
                    TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Danh mục *')),
                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá tiền (VNĐ) *'), keyboardType: TextInputType.number),
                    TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Link ảnh (URL)')),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Đánh dấu là Dịch vụ phổ biến'),
                      subtitle: const Text('Sẽ hiển thị ưu tiên ra màn hình chính của Khách hàng'),
                      value: isPopular,
                      activeThumbColor: const Color(0xFFF26522),
                      onChanged: (val) {
                        setInner(() {
                          isPopular = val;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<ServiceProvider>(context, listen: false);
                  final newService = ServiceModel(
                    id: isEditing ? service.id : 0,
                    name: nameCtrl.text,
                    description: '',
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    estimatedMinutes: 30,
                    category: categoryCtrl.text,
                    imageUrl: imgCtrl.text,
                    isPopular: isPopular,
                  );

                  if (isEditing) {
                    await provider.updateService(newService);
                  } else {
                    await provider.addService(newService);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case 'CONFIRMED':
        color = Colors.blue;
        text = 'Xác nhận';
        break;
      case 'MAINTENANCE':
        color = Colors.purple;
        text = 'Đang sửa';
        break;
      case 'COMPLETED':
        color = Colors.green;
        text = 'Hoàn tất';
        break;
      case 'CANCELLED':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          )
        ],
      ),
    );
  }
}
