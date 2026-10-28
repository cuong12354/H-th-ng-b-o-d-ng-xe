import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/part_provider.dart';
import '../models/part_model.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _selectedIndex = 1;
  String _selectedTicketFilter = 'Tất cả';
  String _serviceSearchQuery = '';
  String _customerSearchQuery = '';
  String _partSearchQuery = '';
  String _selectedPartCategory = 'ALL';

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
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Tổng quan công việc';
      case 1:
        return 'Yêu cầu dịch vụ (Xe tại Gara)';
      case 2:
        return 'Hóa đơn & Thu ngân';
      case 3:
        return 'Bảng giá dịch vụ';
      case 4:
        return 'Danh sách khách hàng';
      case 5:
        return 'Kho phụ tùng & Vật tư';
      default:
        return 'Nhân viên Gara';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role.trim().toUpperCase() == 'ADMIN';

    Widget sidebar = Container(
      width: 80,
      color: const Color(0xFF2C3A47),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: (isAdmin ? Colors.orangeAccent : Colors.redAccent).withValues(alpha: 0.6), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin ? 'ADMIN' : 'STAFF',
            style: TextStyle(
              color: isAdmin ? Colors.orangeAccent : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          if (isAdmin)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('TOÀN QUYỀN', style: TextStyle(color: Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 20),
          _buildSidebarIcon(0, Icons.dashboard_outlined, 'Tổng quan'),
          _buildSidebarIcon(1, Icons.directions_car, 'Phiếu dịch vụ'),
          _buildSidebarIcon(2, Icons.assignment_outlined, 'Hóa đơn'),
          _buildSidebarIcon(3, Icons.build_outlined, 'Dịch vụ'),
          _buildSidebarIcon(4, Icons.people_outline, 'Khách hàng'),
          _buildSidebarIcon(5, Icons.inventory_2_outlined, 'Kho phụ tùng'),
          const Spacer(),
          if (isAdmin) ...[
            Tooltip(
              message: 'Quay lại Trang Quản trị (Admin)',
              child: IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.orangeAccent, size: 28),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
          ],
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            tooltip: 'Đăng xuất',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
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
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getTitle(_selectedIndex),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2C3A47),
              foregroundColor: Colors.white,
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.orangeAccent),
                    tooltip: 'Về Trang Admin',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Làm mới',
                  onPressed: _refreshAllData,
                ),
                if (_selectedIndex == 1)
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Tạo phiếu',
                    onPressed: () => _showStaffCreateTicketDialog(context),
                  ),
                if (_selectedIndex == 5)
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined),
                    tooltip: 'Thêm phụ tùng',
                    onPressed: () => _showAddPartDialog(context),
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
                if (isDesktop)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.grey),
                          tooltip: isAdmin ? 'Quay lại Trang Admin' : 'Đăng xuất',
                          onPressed: () {
                            if (isAdmin) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                              );
                            } else {
                              Provider.of<AuthProvider>(context, listen: false).logout();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getTitle(_selectedIndex),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (isAdmin)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                );
                              },
                              icon: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.orangeAccent),
                              label: const Text('Về Trang Admin', style: TextStyle(color: Color(0xFF2C3A47), fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orangeAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          tooltip: 'Làm mới',
                          onPressed: _refreshAllData,
                        ),
                        const SizedBox(width: 8),
                        if (_selectedIndex == 1)
                          ElevatedButton.icon(
                            onPressed: () => _showStaffCreateTicketDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tạo phiếu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        if (_selectedIndex == 5)
                          ElevatedButton.icon(
                            onPressed: () => _showAddPartDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm phụ tùng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (isAdmin)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: Colors.orange.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Chế độ xem Quản trị viên: Bạn đang truy cập giao diện Nhân viên với toàn quyền tiếp nhận xe, xuất hóa đơn và chỉnh sửa kho.',
                            style: TextStyle(color: Colors.brown, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                            );
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                          child: const Text('Quay lại Dashboard Admin →', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildMainContent()),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(int index, IconData icon, String tooltip) {
    final isSelected = _selectedIndex == index;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildTicketsTab();
      case 2:
        return _buildInvoicesTab();
      case 3:
        return _buildServicesTab();
      case 4:
        return _buildCustomersTab();
      case 5:
        return _buildInventoryTab();
      default:
        return _buildTicketsTab();
    }
  }

  // ================= TAB 0: TỔNG QUAN (OVERVIEW) =================
  Widget _buildOverviewTab() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        final appts = provider.appointments;
        final total = appts.length;
        final pending = appts.where((a) => a['status'] == 'PENDING' || a['status'] == 'CONFIRMED').length;
        final inProgress = appts.where((a) => a['status'] == 'MAINTENANCE').length;
        final completed = appts.where((a) => a['status'] == 'COMPLETED' || a['status'] == 'PAID').length;

        final activeJobs = appts.where((a) => a['status'] == 'CONFIRMED' || a['status'] == 'MAINTENANCE').toList();

        return RefreshIndicator(
          onRefresh: () async => _refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat cards
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Chờ xử lý', pending.toString(), Icons.access_time, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Đang sửa', inProgress.toString(), Icons.build, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Đã xong', completed.toString(), Icons.check_circle, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Tổng phiếu', total.toString(), Icons.directions_car, const Color(0xFF2C3A47))),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE8F8F5),
                        radius: 24,
                        child: Icon(Icons.add_task, color: Color(0xFF2ECC71)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tiếp nhận xe mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Tạo phiếu tiếp nhận xe và chọn dịch vụ cho khách', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showStaffCreateTicketDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('TẠO PHIẾU'),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Active Jobs list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Xe cần làm ngay trong xưởng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Text('Xem tất cả →'),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                if (activeJobs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Hiện không có xe nào đang chờ sửa trong xưởng.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...activeJobs.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2C3A47),
                        child: Text(
                          ((a['customerName'] as String?)?.trim().isNotEmpty == true)
                              ? (a['customerName'] as String).trim()[0].toUpperCase()
                              : 'K',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              a['customerName'] ?? 'Khách vãng lai',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF3FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFB9D5FF)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_car, size: 11, color: Color(0xFF1E5BB0)),
                                const SizedBox(width: 3),
                                Text(
                                  a['licensePlate'] ?? 'Chưa rõ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Color(0xFF1E5BB0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text('Dịch vụ: ${(a["services"] as List?)?.join(", ") ?? "Chưa rõ"}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: a['status'] == 'MAINTENANCE' ? Colors.blue : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => _showUpdateStatusDialog(context, a),
                        child: Text(a['status'] == 'MAINTENANCE' ? 'Đang sửa ⚙️' : 'Chờ làm ⏳'),
                      ),
                    ),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          )
        ],
      ),
    );
  }

  // ================= TAB 1: PHIẾU DỊCH VỤ (TICKETS) =================
  Widget _buildTicketsTab() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var appts = provider.appointments;
        if (_selectedTicketFilter == 'Chờ sửa') {
          appts = appts.where((a) => a['status'] == 'CONFIRMED' || a['status'] == 'PENDING').toList();
        } else if (_selectedTicketFilter == 'Đang sửa') {
          appts = appts.where((a) => a['status'] == 'MAINTENANCE').toList();
        } else if (_selectedTicketFilter == 'Hoàn thành') {
          appts = appts.where((a) => a['status'] == 'COMPLETED' || a['status'] == 'PAID').toList();
        }

        return Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('${appts.length} phiếu', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    _buildFilterChip('Tất cả'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Chờ sửa'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đang sửa'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hoàn thành'),
                  ],
                ),
              ),
            ),

            // Tickets Grid/List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: appts.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async => provider.fetchAppointments(),
                        child: ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Không có phiếu dịch vụ nào trong bộ lọc này.')),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;
                          if (constraints.maxWidth > 1200) {
                            crossAxisCount = 4;
                          } else if (constraints.maxWidth > 800) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth > 600) {
                            crossAxisCount = 2;
                          }

                          return RefreshIndicator(
                            onRefresh: () async => provider.fetchAppointments(),
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 1.6,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: appts.length,
                              itemBuilder: (context, index) {
                                final a = appts[index];
                                return _buildTicketCard(a);
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedTicketFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF2ECC71),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13),
      onSelected: (val) {
        if (val) setState(() => _selectedTicketFilter = label);
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> appointment) {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.parse(appointment['scheduledDate']).toLocal());
    final status = appointment['status'] as String;
    final customerName = (appointment['customerName'] as String?)?.trim().isNotEmpty == true
        ? (appointment['customerName'] as String).trim()
        : 'Khách vãng lai';
    final licensePlate = (appointment['licensePlate'] as String?)?.trim().isNotEmpty == true
        ? (appointment['licensePlate'] as String).trim()
        : 'Chưa rõ';

    Color statusColor;
    String statusText;
    switch (status) {
      case 'PENDING':
        statusColor = Colors.blue;
        statusText = 'Mới';
        break;
      case 'CONFIRMED':
        statusColor = Colors.orange;
        statusText = 'Chờ sửa';
        break;
      case 'MAINTENANCE':
        statusColor = Colors.amber.shade800;
        statusText = 'Đang sửa';
        break;
      case 'COMPLETED':
      case 'PAID':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return InkWell(
      onTap: () => _showUpdateStatusDialog(context, appointment),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2C3A47),
                  child: Text(
                    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'K',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2C3A47),
                              ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_car, size: 12, color: Color(0xFF1E5BB0)),
                                const SizedBox(width: 4),
                                Text(
                                  licensePlate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF1E5BB0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      children: [
                        const TextSpan(text: 'Dịch vụ: '),
                        TextSpan(
                          text: (appointment['services'] as List<dynamic>?)?.join(', ') ?? 'Chưa cập nhật',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 2: HÓA ĐƠN & THU NGÂN (INVOICES) =================
  Widget _buildInvoicesTab() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        final invoices = provider.invoices;
        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        if (invoices.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => provider.fetchInvoices(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Chưa có hóa đơn nào.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.fetchInvoices(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final inv = invoices[index];
              final isPaid = inv['paymentStatus'] == 'PAID';
              final finalAmount = (inv['finalAmount'] as num?)?.toDouble() ?? 0.0;
              final date = inv['createdAt'] != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(inv['createdAt']).toLocal())
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.receipt_long,
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          inv['invoiceCode'] ?? 'Hóa đơn',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormatter.format(finalAmount),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPaid ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Khách: ${inv["customerName"] ?? "N/A"} - Biển số: ${inv["licensePlate"] ?? "N/A"}'),
                      Text('Ngày lập: $date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.withAlpha(30) : Colors.orange.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPaid ? 'ĐÃ THANH TOÁN' : 'CHỜ THANH TOÁN',
                              style: TextStyle(
                                color: isPaid ? Colors.green : Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!isPaid)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.payment, size: 16),
                              label: const Text('Thu tiền'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2ECC71),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        );
      },
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
              content: Column(
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
                    value: selectedMethod,
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
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                  onPressed: () async {
                    final success = await Provider.of<InvoiceProvider>(context, listen: false).payInvoice(invoice['id'], selectedMethod);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Thanh toán hóa đơn thành công!' : 'Thanh toán thất bại')),
                      );
                    }
                  },
                  child: const Text('ĐÃ THU TIỀN'),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ================= TAB 3: BẢNG GIÁ DỊCH VỤ (SERVICES) =================
  Widget _buildServicesTab() {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        var svcs = provider.services;
        if (_serviceSearchQuery.isNotEmpty) {
          svcs = svcs.where((s) => s.name.toLowerCase().contains(_serviceSearchQuery.toLowerCase()) || s.category.toLowerCase().contains(_serviceSearchQuery.toLowerCase())).toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm dịch vụ (tên hoặc danh mục)...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _serviceSearchQuery = val),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => provider.fetchServices(),
                child: svcs.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Không tìm thấy dịch vụ nào.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: svcs.length,
                        itemBuilder: (context, index) {
                          final svc = svcs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                child: const Icon(Icons.build_outlined, color: Colors.blue),
                              ),
                              title: Text(svc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('${svc.category} • Dự kiến: ${svc.estimatedMinutes} phút', style: const TextStyle(color: Colors.grey)),
                                  if (svc.description.isNotEmpty) Text(svc.description, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                              trailing: Text(
                                currencyFormatter.format(svc.price),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF26522)),
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

  // ================= TAB 4: KHÁCH HÀNG (CUSTOMERS) =================
  Widget _buildCustomersTab() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        final customers = <String, Map<String, dynamic>>{};
        for (var a in provider.appointments) {
          final name = a['customerName'] as String? ?? 'Khách vãng lai';
          final plate = a['licensePlate'] as String? ?? '';
          final key = name;

          if (!customers.containsKey(key)) {
            customers[key] = {
              'name': name,
              'plates': <String>{},
              'totalAppointments': 0,
              'totalSpent': 0.0,
            };
          }

          if (plate.isNotEmpty) {
            (customers[key]!['plates'] as Set<String>).add(plate);
          }
          customers[key]!['totalAppointments'] = (customers[key]!['totalAppointments'] as int) + 1;
          customers[key]!['totalSpent'] = (customers[key]!['totalSpent'] as double) + ((a['totalEstimatedPrice'] as num?)?.toDouble() ?? 0.0);
        }

        var customerList = customers.values.toList();
        if (_customerSearchQuery.isNotEmpty) {
          customerList = customerList.where((c) {
            final name = (c['name'] as String).toLowerCase();
            final plates = (c['plates'] as Set<String>).join(' ').toLowerCase();
            return name.contains(_customerSearchQuery.toLowerCase()) || plates.contains(_customerSearchQuery.toLowerCase());
          }).toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm khách hàng theo tên hoặc biển số xe...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _customerSearchQuery = val),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => provider.fetchAppointments(),
                child: customerList.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Chưa có thông tin khách hàng nào.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customerList.length,
                        itemBuilder: (context, index) {
                          final c = customerList[index];
                          final plates = (c['plates'] as Set<String>).join(', ');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2ECC71).withAlpha(40),
                                child: const Icon(Icons.person, color: Color(0xFF2ECC71)),
                              ),
                              title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Xe: ${plates.isEmpty ? "Chưa lưu biển số" : plates}', style: const TextStyle(color: Colors.black87)),
                                  Text('Đã làm dịch vụ: ${c["totalAppointments"]} lần', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Tổng chi tiêu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(
                                    currencyFormatter.format(c['totalSpent']),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
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

  // ================= TAB 5: KHO PHỤ TÙNG (INVENTORY) =================
  Widget _buildInventoryTab() {
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
          parts = parts.where((p) => p.name.toLowerCase().contains(_partSearchQuery.toLowerCase()) || p.description.toLowerCase().contains(_partSearchQuery.toLowerCase())).toList();
        }

        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Tìm phụ tùng, phụ kiện...',
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
                        label: const Text('Thêm mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          selected: _selectedPartCategory == 'ALL',
                          label: Text('Tất cả (${provider.parts.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'ALL'),
                          selectedColor: const Color(0xFF2ECC71).withAlpha(40),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedPartCategory == 'SPARE_PART',
                          label: Text('⚙️ Phụ tùng (${provider.spareParts.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'SPARE_PART'),
                          selectedColor: Colors.blue.withAlpha(40),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedPartCategory == 'ACCESSORY',
                          label: Text('🛡️ Phụ kiện (${provider.accessories.length})'),
                          onSelected: (_) => setState(() => _selectedPartCategory = 'ACCESSORY'),
                          selectedColor: Colors.amber.withAlpha(40),
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
                          SizedBox(height: 120),
                          Center(child: Text('Kho phụ tùng hiện đang trống.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
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
                            badgeText = 'Sắp hết';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: badgeColor.withAlpha(30), shape: BoxShape.circle),
                                child: Icon(
                                  part.isAccessory ? Icons.sports_motorsports : Icons.inventory_2,
                                  color: badgeColor,
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      part.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: badgeColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                                    child: Text(badgeText, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10)),
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    part.description.isEmpty ? 'Không có mô tả' : part.description,
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Giá: ${currencyFormatter.format(part.price)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF26522), fontSize: 13),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withAlpha(20),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Tồn: ${part.stockQuantity}',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 11),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: part.isAccessory ? Colors.amber.withAlpha(30) : Colors.blue.withAlpha(30),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          part.isAccessory ? '🛡️ Phụ kiện' : '⚙️ Phụ tùng',
                                          style: TextStyle(
                                            color: part.isAccessory ? Colors.amber.shade900 : Colors.blue.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.blue, size: 26),
                                tooltip: 'Cập nhật tồn kho / giá',
                                onPressed: () => _showEditPartDialog(context, part),
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
            title: const Text('Thêm vào Kho'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Thêm thành công!' : 'Thêm thất bại')));
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
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

  // ================= DIALOGS =================
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
              title: const Text('Tạo Phiếu Dịch Vụ Mới'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin Khách hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên Khách hàng', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      const Text('Thông tin Xe', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Biển số xe', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Hãng xe', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Dòng xe', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Dịch vụ Yêu cầu', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...serviceProvider.services.map((svc) {
                        return CheckboxListTile(
                          title: Text(svc.name),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo phiếu thành công!')));
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo phiếu thất bại!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                  child: const Text('TẠO PHIẾU'),
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
      {'value': 'CONFIRMED', 'label': 'Đã tiếp nhận (Chờ sửa)'},
      {'value': 'MAINTENANCE', 'label': 'Đang bảo dưỡng / sửa chữa'},
      {'value': 'COMPLETED', 'label': 'Hoàn thành (Tự động xuất hóa đơn)'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật trạng thái: ${appointment["customerName"] ?? "Khách"} (${appointment["licensePlate"]})'),
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
}
