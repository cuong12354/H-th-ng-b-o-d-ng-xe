import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/service_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/part_provider.dart';
import '../models/vehicle_model.dart';
import '../models/part_model.dart';
import '../providers/invoice_provider.dart';
import 'booking_screen.dart';
import 'add_vehicle_screen.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'invoice_screen.dart';
import '../widgets/server_config_dialog.dart';
import '../providers/store_content_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedRewardFilter = 'Tất cả';

  // Dynamic Vehicle image resolver
  String _getVehicleImageUrl(String brand, String model, String vehicleType) {
    final b = brand.toLowerCase().trim();
    final m = model.toLowerCase().trim();
    final t = vehicleType.toLowerCase().trim();

    // Xe máy / Moto / Scooter
    if (t.contains('moto') ||
        t.contains('xe máy') ||
        t.contains('bike') ||
        t.contains('scooter') ||
        b.contains('yamaha') ||
        m.contains('sh') ||
        m.contains('wave') ||
        m.contains('vision') ||
        m.contains('exciter')) {
      if (m.contains('sh') ||
          m.contains('vision') ||
          m.contains('lead') ||
          m.contains('vespa') ||
          t.contains('scooter')) {
        return 'https://pngimg.com/d/scooter_PNG11295.png';
      }
      return 'https://pngimg.com/d/motorcycle_PNG3158.png';
    }

    // Toyota
    if (b.contains('toyota')) {
      if (m.contains('fortuner') ||
          m.contains('cross') ||
          m.contains('land') ||
          m.contains('prado') ||
          m.contains('rush')) {
        return 'https://pngimg.com/d/toyota_PNG1959.png'; // Fortuner / SUV
      }
      if (m.contains('camry') || m.contains('altis')) {
        return 'https://pngimg.com/d/toyota_PNG1972.png'; // Camry
      }
      return 'https://pngimg.com/d/toyota_PNG1963.png'; // Vios / Sedan
    }

    // Honda
    if (b.contains('honda')) {
      if (m.contains('crv') ||
          m.contains('cr-v') ||
          m.contains('hrv') ||
          m.contains('hr-v')) {
        return 'https://pngimg.com/d/honda_PNG10342.png'; // CR-V
      }
      return 'https://pngimg.com/d/honda_PNG10344.png'; // Civic / City
    }

    // Hyundai
    if (b.contains('hyundai')) {
      if (m.contains('santa') ||
          m.contains('tucson') ||
          m.contains('creta') ||
          m.contains('palisade')) {
        return 'https://pngimg.com/d/hyundai_PNG11220.png'; // SantaFe / SUV
      }
      return 'https://pngimg.com/d/hyundai_PNG11228.png'; // Accent / Elantra
    }

    // Mazda
    if (b.contains('mazda')) {
      if (m.contains('cx') ||
          m.contains('cx5') ||
          m.contains('cx-5') ||
          m.contains('cx8')) {
        return 'https://pngimg.com/d/mazda_PNG87.png'; // CX-5
      }
      return 'https://pngimg.com/d/mazda_PNG103774.png'; // Mazda 3
    }

    // Ford
    if (b.contains('ford')) {
      return 'https://pngimg.com/d/ford_PNG12269.png'; // Ranger / Everest
    }

    // Mercedes-Benz
    if (b.contains('mercedes') || b.contains('merc')) {
      return 'https://pngimg.com/d/mercedes_PNG80145.png';
    }

    // BMW
    if (b.contains('bmw')) {
      return 'https://pngimg.com/d/bmw_PNG99547.png';
    }

    // Mitsubishi
    if (b.contains('mitsu') || b.contains('mitsubishi')) {
      if (m.contains('xpander') ||
          m.contains('outlander') ||
          m.contains('pajero')) {
        return 'https://pngimg.com/d/mitsubishi_PNG166.png'; // Outlander / Xpander SUV
      }
      return 'https://pngimg.com/d/mitsubishi_PNG116.png'; // Attrage Sedan
    }

    // Kia
    if (b.contains('kia')) {
      if (m.contains('seltos') ||
          m.contains('sorento') ||
          m.contains('carnival')) {
        return 'https://pngimg.com/d/hyundai_PNG11220.png';
      }
      return 'https://pngimg.com/d/hyundai_PNG11228.png';
    }

    // VinFast
    if (b.contains('vinfast')) {
      if (m.contains('vf') || m.contains('lux sa')) {
        return 'https://pngimg.com/d/hyundai_PNG11220.png';
      }
      return 'https://pngimg.com/d/mazda_PNG103774.png';
    }

    // Default fallback based on vehicleType
    if (t.contains('suv') || t.contains('cuv')) {
      return 'https://pngimg.com/d/hyundai_PNG11220.png';
    }
    return 'https://pngimg.com/d/mitsubishi_PNG116.png';
  }

  void _navigateToBooking(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(
      context,
      listen: false,
    );
    if (vehicleProvider.vehicles.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BookingScreen(vehicle: vehicleProvider.vehicles.first),
        ),
      );
    } else {
      final defaultVehicle = VehicleModel(
        id: 1,
        userId: 1,
        brand: 'Mitsubishi',
        model: 'Attrage',
        year: 2020,
        licensePlate: '98A-35711',
        color: 'Trắng',
        vehicleType: 'Car',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(vehicle: defaultVehicle),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    Provider.of<VehicleProvider>(context, listen: false).fetchMyVehicles();
    Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    Provider.of<AppointmentProvider>(
      context,
      listen: false,
    ).fetchAppointments();
    Provider.of<PartProvider>(context, listen: false).fetchParts();
    Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E12), // Deep automotive black
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF14161E),
          border: Border(top: BorderSide(color: Color(0xFF222632), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: const Color(0xFF14161E),
          selectedItemColor: const Color(0xFFE60012), // Mitsubishi Red
          unselectedItemColor: const Color(0xFF8E92A0),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: Color(0xFFE60012)),
              label: 'TRANG CHỦ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car, color: Color(0xFFE60012)),
              label: 'XE CỦA TÔI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings, color: Color(0xFFE60012)),
              label: 'DỊCH VỤ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              activeIcon: Icon(Icons.card_giftcard, color: Color(0xFFE60012)),
              label: 'ĐỔI QUÀ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic_outlined),
              activeIcon: Icon(Icons.headset_mic, color: Color(0xFFE60012)),
              label: 'THÔNG TIN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildMyVehicleTab();
      case 2:
        return _buildServicesTab();
      case 3:
        return _buildRewardsTab();
      case 4:
        return _buildSupportTab();
      default:
        return _buildHomeTab();
    }
  }

  // =========================================================================
  // TAB 0: TRANG CHỦ (Home Screen - Ảnh 1)
  // =========================================================================
  Widget _buildHomeTab() {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.vehicles.isNotEmpty
        ? vehicleProvider.vehicles.first
        : null;

    final carName = vehicle != null
        ? '${vehicle.brand} ${vehicle.model}'
        : 'Attrage';
    final licensePlate = vehicle?.licensePlate ?? '98A-35711';

    return RefreshIndicator(
      color: const Color(0xFFE60012),
      backgroundColor: const Color(0xFF1E212B),
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Top Header Bar
          Row(
            children: [
              // Mitsubishi Logo
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'BLACKMYTH AUTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bell icon with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE60012),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              // Profile circle
              GestureDetector(
                onTap: () => _showUserProfileModal(context),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE60012),
                      width: 1.5,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=68',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Spotlight Vehicle Card
          _buildVehicleSpotlightCard(
            vehicle: vehicle,
            carName: carName,
            plate: licensePlate,
          ),
          const SizedBox(height: 16),

          // Next Maintenance Progress
          _buildMaintenanceProgress(),
          const SizedBox(height: 20),

          // 2x2 Red Action Grid + 1 Full Width
          Row(
            children: [
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.car_repair,
                  title: 'Đặt lịch hẹn dịch vụ',
                  onTap: () => _navigateToBooking(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.location_on_outlined,
                  title: 'Tìm Nhà phân phối',
                  onTap: () => _showGarageLocationDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.directions_car_outlined,
                  title: 'Sản phẩm',
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.headset_mic_outlined,
                  title: 'Hỗ trợ và tư vấn',
                  onTap: () => _showSupportHotlineDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.receipt_long,
                  title: 'Hóa đơn dịch vụ',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InvoiceScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRedActionButton(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Khảo sát hài lòng',
                  onTap: () => _showSurveyDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // News Section ("Tin tức")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.campaign, color: Color(0xFFE60012), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Tin tức',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'TỪ BLACKMYTH',
                    style: TextStyle(
                      color: Color(0xFFE60012),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '  |  Từ Nhà Phân Phối',
                    style: TextStyle(color: Color(0xFF8E92A0), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal News Carousel
          Consumer<StoreContentProvider>(
            builder: (context, storeContent, _) {
              final newsList = storeContent.newsList;
              if (newsList.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Chưa có tin tức nào.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 175,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newsList.length,
                  itemBuilder: (context, idx) {
                    final item = newsList[idx];
                    return _buildNewsCard(
                      imageUrl: item.imageUrl,
                      title: item.title,
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Notification snippet
          Row(
            children: const [
              Icon(
                Icons.notifications_active,
                color: Color(0xFFE60012),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'Thông báo mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D24),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF282C37)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFE60012),
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Đã có lịch nhắc bảo dưỡng mốc 110.000 km cho xe của bạn.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem',
                    style: TextStyle(
                      color: Color(0xFFE60012),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Spotlight Car Card
  Widget _buildVehicleSpotlightCard({
    VehicleModel? vehicle,
    required String carName,
    required String plate,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C303E)),
        gradient: const RadialGradient(
          center: Alignment(0.3, -0.2),
          radius: 1.2,
          colors: [Color(0xFF2D3242), Color(0xFF14161E)],
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        carName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showEditVehicleModal(context, vehicle),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C303E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plate,
                    style: const TextStyle(
                      color: Color(0xFFB0B5C3),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE60012),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'XE CHÍNH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Car render image & ODO
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ODO (km)',
                    style: TextStyle(color: Color(0xFF9096A8), fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle != null && vehicle.currentOdometer > 0
                        ? NumberFormat(
                            "#,###",
                            "vi_VN",
                          ).format(vehicle.currentOdometer)
                        : '109.700',
                    style: const TextStyle(
                      color: Color(0xFFE60012),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(
                        Icons.calendar_today,
                        color: Color(0xFF7A8092),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '13/11/2020',
                        style: TextStyle(
                          color: Color(0xFF7A8092),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: Image.network(
                    _getVehicleImageUrl(
                      vehicle?.brand ?? 'Mitsubishi',
                      vehicle?.model ?? 'Attrage',
                      vehicle?.vehicleType ?? 'Car',
                    ),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.directions_car,
                          size: 80,
                          color: Colors.white24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Next Maintenance Progress Bar
  Widget _buildMaintenanceProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'KỲ BẢO DƯỠNG TIẾP THEO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '05/11/2026 - 34 ngày tới',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF333846),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.65,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE60012), Color(0xFFFF7A00)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Red Action Button
  Widget _buildRedActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: isFullWidth ? 56 : 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFFD71920), Color(0xFF9E0B11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD71920).withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: isFullWidth
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // News Card
  Widget _buildNewsCard({required String imageUrl, required String title}) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF282C37)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              imageUrl,
              height: 105,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 105,
                color: const Color(0xFF2C303E),
                child: const Icon(Icons.image, color: Colors.white24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: XE CỦA TÔI (My Vehicle - Ảnh 2)
  // =========================================================================
  Widget _buildMyVehicleTab() {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.vehicles.isNotEmpty
        ? vehicleProvider.vehicles.first
        : null;

    final carName = vehicle != null
        ? '${vehicle.brand} ${vehicle.model}'
        : 'Attrage';
    final plate = vehicle?.licensePlate ?? '98A-35711';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // App bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Xe của tôi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: const Color(0xFF1E212B),
              onSelected: (val) {
                if (val == 'add') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                  );
                } else if (val == 'edit') {
                  _showEditVehicleModal(context, vehicle);
                } else if (val == 'refresh') {
                  _refreshData();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text(
                    'Chỉnh sửa xe này',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: Text(
                    'Thêm phương tiện mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Text(
                    'Làm mới dữ liệu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Vehicle Card with "XE CHÍNH" badge
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E212B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C303E)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge date and ODO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD71920),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          vehicle != null && vehicle.currentOdometer > 0
                              ? '13/11/2020 • ${NumberFormat("#,###", "vi_VN").format(vehicle.currentOdometer)} km'
                              : '13/11/2020 • 109.700 km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    width: 140,
                    child: Image.network(
                      _getVehicleImageUrl(
                        vehicle?.brand ?? 'Mitsubishi',
                        vehicle?.model ?? 'Attrage',
                        vehicle?.vehicleType ?? 'Car',
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 50,
                              color: Colors.white24,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Biển số: $plate',
                        style: const TextStyle(
                          color: Color(0xFF8E92A0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _showEditVehicleModal(context, vehicle),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C303E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Sửa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD71920),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'XE CHÍNH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildMaintenanceProgress(),
        const SizedBox(height: 16),

        // 3 Horizontal Info Chips (Đăng kiểm, phí đường bộ, bảo hiểm)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSmallInfoChip('Hạn đăng kiểm', '15/12/2026'),
              const SizedBox(width: 8),
              _buildSmallInfoChip('Phí bảo trì đường bộ', 'Còn hiệu lực'),
              const SizedBox(width: 8),
              _buildSmallInfoChip('Bảo hiểm TNDS', 'Đến 10/2026'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2x2 Dark Grid Cards
        Row(
          children: [
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.edit_note,
                title: 'Chi phí & Nhắc nhở',
                onTap: () => _showCostReminderDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.history,
                title: 'Lịch sử dịch vụ',
                onTap: () => _showServiceHistoryDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.receipt_long,
                title: 'Hóa đơn & Biên lai\n(Đã thanh toán)',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvoiceScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.verified_user_outlined,
                title: 'Bảo hành chính hãng',
                onTap: () => _showWarrantyDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.lightbulb_outline,
                title: 'Hướng dẫn sử dụng',
                onTap: () => _showUserGuideDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Red recall check button
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Xe của bạn không có lệnh triệu hồi nào cần xử lý.',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD71920), Color(0xFF9E0B11)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.cached, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Kiểm tra triệu hồi kỹ thuật',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSmallInfoChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C303E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF8E92A0), fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, color: Color(0xFFE60012), size: 12),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 125),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C303E)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 2: DỊCH VỤ (Services - Ảnh 3)
  // =========================================================================
  Widget _buildServicesTab() {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.vehicles.isNotEmpty
        ? vehicleProvider.vehicles.first
        : null;

    final carName = vehicle != null
        ? '${vehicle.brand} ${vehicle.model}'
        : 'Attrage';
    final plate = vehicle?.licensePlate ?? '98A-35711';
    return RefreshIndicator(
      color: const Color(0xFFE60012),
      backgroundColor: const Color(0xFF1E212B),
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'Dịch vụ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildVehicleSpotlightCard(
            vehicle: vehicle,
            carName: carName,
            plate: plate,
          ),
          const SizedBox(height: 16),
          _buildMaintenanceProgress(),
          const SizedBox(height: 20),

          // 2x3 Grid
          Row(
            children: [
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.percent,
                  title: 'Chiến dịch dịch vụ',
                  onTap: () => _showCampaignDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Gói bảo dưỡng trả trước',
                  onTap: () => _showPrepaidPackagesDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.verified_outlined,
                  title: 'Dịch vụ chính hãng',
                  onTap: () => _showAllServicesListDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.album_outlined,
                  title: 'Thông tin phụ tùng',
                  onTap: () =>
                      _showPartsListDialog(initialCategory: 'SPARE_PART'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.sports_motorsports_outlined,
                  title: 'Thông tin phụ kiện',
                  onTap: () =>
                      _showPartsListDialog(initialCategory: 'ACCESSORY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDarkFeatureCard(
                  icon: Icons.calendar_month,
                  title: 'Lịch bảo dưỡng',
                  onTap: () => _showMaintenanceScheduleDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bottom red button: "Quản lý lịch hẹn"
          InkWell(
            onTap: () => _navigateToBooking(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD71920), Color(0xFF9E0B11)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.event_note, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Quản lý & Đặt lịch hẹn mới',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: ĐỔI QUÀ (Rewards / Loyalty - Ảnh 4)
  // =========================================================================
  Widget _buildRewardsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.fullName ?? 'Trịnh Văn Đại';
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.vehicles.isNotEmpty
        ? vehicleProvider.vehicles.first
        : null;
    final carDisplay = vehicle != null
        ? '${vehicle.brand} ${vehicle.model} • ${vehicle.licensePlate}'
        : 'Attrage • 98A-35711';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Top member info
        InkWell(
          onTap: () => _showUserProfileModal(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF2C303E),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '315 Điểm đổi quà • Nhấn để xem hồ sơ',
                      style: TextStyle(color: Color(0xFFB0B5C3), fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => _showUserProfileModal(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Luxury VIP Member Card
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF232731), Color(0xFF101217)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF333846)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'BLACKMYTH AUTO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Điểm xếp hạng: 2.100',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BẠCH KIM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    carDisplay,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Có giá trị tới: 02/2027',
                    style: TextStyle(color: Color(0xFF8E92A0), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Xem thông tin thành viên >',
              style: TextStyle(
                color: Color(0xFFE60012),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // "Ưu đãi độc quyền"
        Row(
          children: const [
            Icon(Icons.card_giftcard, color: Color(0xFFE60012), size: 18),
            SizedBox(width: 6),
            Text(
              'Ưu đãi độc quyền',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildExclusiveCard(
                'Giới thiệu mua xe\nNhận 2.000.000 VNĐ',
                'https://images.unsplash.com/photo-1542362567-b07e54358753?w=500',
              ),
              _buildExclusiveCard(
                'Lên đời xe mới\nNhận 3.000.000 VNĐ',
                'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // "Đổi quà"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.redeem, color: Color(0xFFE60012), size: 18),
                SizedBox(width: 6),
                Text(
                  'Đổi quà',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_double_arrow_right,
              color: Colors.white70,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRewardChip('Tất cả'),
              const SizedBox(width: 8),
              _buildRewardChip('Voucher dịch vụ'),
              const SizedBox(width: 8),
              _buildRewardChip('Phiếu quà tặng Gotit'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Voucher Cards
        Consumer<StoreContentProvider>(
          builder: (context, storeContent, _) {
            var vouchers = storeContent.vouchers;
            if (_selectedRewardFilter != 'Tất cả') {
              vouchers = vouchers
                  .where((v) => v.category == _selectedRewardFilter)
                  .toList();
            }
            if (vouchers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Chưa có voucher nào trong danh mục này.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              );
            }
            return Column(
              children: vouchers
                  .map(
                    (v) => _buildVoucherCard(
                      title: v.title,
                      points: '${v.pointsRequired} điểm',
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExclusiveCard(String title, String imageUrl) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD71920).withAlpha(100)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              imageUrl,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(String label) {
    final isSelected = _selectedRewardFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFE60012),
      backgroundColor: const Color(0xFF1E212B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedRewardFilter = label);
      },
    );
  }

  Widget _buildVoucherCard({required String title, required String points}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2C303E)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE60012).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Color(0xFFE60012),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cần: $points',
                  style: const TextStyle(
                    color: Color(0xFFE60012),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã đổi $title thành công!')),
              );
            },
            child: const Text('Đổi quà'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: THÔNG TIN (Support & Legal - Ảnh 5)
  // =========================================================================
  Widget _buildSupportTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const Text(
          'Chăm sóc khách hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // User Profile Summary Card
        Builder(
          builder: (ctx) {
            final auth = Provider.of<AuthProvider>(ctx);
            final user = auth.currentUser;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E212B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C303E)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE60012),
                    child: Text(
                      (user?.fullName.isNotEmpty ?? false)
                          ? user!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : 'Tài khoản người dùng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email.isNotEmpty == true
                              ? user!.email
                              : 'Chưa có email',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user?.phoneNumber.isNotEmpty == true
                              ? user!.phoneNumber
                              : 'Chưa có số ĐT',
                          style: const TextStyle(
                            color: Color(0xFF8E92A0),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(context),
                    icon: const Icon(Icons.edit, size: 13),
                    label: const Text('Sửa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE60012),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 2x2 Dark Grid
        Row(
          children: [
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.car_crash_outlined,
                title: 'Hotline cứu hộ\nNhà Phân Phối',
                onTap: () => _showSupportHotlineDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.headset_mic_outlined,
                title: 'Hỗ trợ kỹ thuật\nNhà Phân Phối',
                onTap: () => _showSupportHotlineDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.headphones_outlined,
                title: 'Tổng đài hỗ trợ\nBlackmyth Auto',
                onTap: () => _showSupportHotlineDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDarkFeatureCard(
                icon: Icons.smartphone_outlined,
                title: 'Báo lỗi sự cố\n(Góp ý kỹ thuật)',
                onTap: () => _showAppFeedbackDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Social Buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                Icons.facebook,
                'Fanpage',
                Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSocialButton(
                Icons.chat_bubble,
                'Messenger',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                Icons.play_circle_fill,
                'Youtube',
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSocialButton(Icons.language, 'Website', Colors.teal),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Compliance & Legal Footer
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD71920),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'ĐÃ ĐĂNG KÝ BỘ CÔNG THƯƠNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Copyright ©2026 Blackmyth Auto Ver 1.3.1\nPhiên bản hiện tại là phiên bản mới nhất',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Công ty Cổ phần Blackmyth Auto Garage Việt Nam',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Địa chỉ: Số 68 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức, TP. Hồ Chí Minh',
                style: TextStyle(color: Color(0xFF8E92A0), fontSize: 11),
              ),
              SizedBox(height: 4),
              Text(
                'Hotline 24/7: 1900 6868  •  Email: cskh@blackmythauto.vn',
                style: TextStyle(color: Color(0xFF8E92A0), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Logout button
        ElevatedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.white70),
          label: const Text(
            'Đăng xuất tài khoản',
            style: TextStyle(color: Colors.white70),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF222632),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C303E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // POPUP DIALOGS & ACTIONS
  // =========================================================================
  void _showGarageLocationDialog() {
    final storeInfo = Provider.of<StoreContentProvider>(
      context,
      listen: false,
    ).storeInfo;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: Row(
          children: const [
            Icon(Icons.location_on, color: Color(0xFFE60012), size: 22),
            SizedBox(width: 8),
            Text(
              'Nhà phân phối / Gara ủy quyền',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeInfo.garageName,
              style: const TextStyle(
                color: Color(0xFFE60012),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 Địa chỉ: ${storeInfo.address}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              '📞 Hotline: ${storeInfo.hotline}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              '🚨 Cứu hộ 24/7: ${storeInfo.rescueHotline}',
              style: const TextStyle(
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '⏰ Giờ mở cửa: ${storeInfo.openingHours}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToBooking(context);
            },
            child: const Text('Đặt lịch ngay'),
          ),
        ],
      ),
    );
  }

  void _showSupportHotlineDialog() {
    final storeInfo = Provider.of<StoreContentProvider>(
      context,
      listen: false,
    ).storeInfo;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: Row(
          children: const [
            Icon(Icons.support_agent, color: Color(0xFFE60012), size: 22),
            SizedBox(width: 8),
            Text(
              'Hỗ trợ & Cứu hộ 24/7',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent, color: Color(0xFFE60012), size: 48),
            const SizedBox(height: 12),
            const Text(
              'Tổng đài Chăm sóc khách hàng:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              storeInfo.hotline,
              style: const TextStyle(
                color: Color(0xFFE60012),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đường dây nóng Cứu hộ khẩn cấp 24/7:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              storeInfo.rescueHotline,
              style: const TextStyle(
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showSurveyDialog() {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E212B),
            title: const Text(
              'Khảo sát hài lòng khách hàng',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bạn đánh giá chất lượng dịch vụ của Gara thế nào?',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (idx) {
                    return IconButton(
                      icon: Icon(
                        idx < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setDlgState(() => rating = idx + 1),
                    );
                  }),
                ),
                TextField(
                  controller: commentCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ý kiến đóng góp của bạn...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cảm ơn bạn đã gửi đánh giá!'),
                    ),
                  );
                },
                child: const Text('Gửi đánh giá'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCostReminderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Chi phí & Nhắc nhở',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '• Thay nhớt máy: Còn 300 km nữa cần thay',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              '• Lọc gió động cơ: Cần kiểm tra tại mốc 110.000 km',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              '• Đăng kiểm tiếp theo: Ngày 15/12/2026',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showServiceHistoryDialog() {
    final apptProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    final list = apptProvider.appointments;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Lịch sử dịch vụ',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có lịch sử dịch vụ nào.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final st = item['status']?.toString().toUpperCase() ?? '';
                    final canViewInvoice = st == 'COMPLETED' || st == 'PAID';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14161E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2C303E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item['licensePlate'] ?? 'Phiếu dịch vụ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${(item["services"] as List?)?.join(", ") ?? "Dịch vụ"} • ${item["status"]}',
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: Text(
                              NumberFormat.currency(
                                locale: "vi_VN",
                                symbol: "đ",
                              ).format(item["totalEstimatedPrice"] ?? 0),
                              style: const TextStyle(
                                color: Color(0xFFE60012),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (canViewInvoice)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF2ECC71),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                ),
                                icon: const Icon(Icons.receipt_long, size: 15),
                                label: const Text(
                                  'Xem hóa đơn điện tử',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InvoiceScreen(
                                        initialAppointmentId: item['id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(
              Icons.receipt_long,
              size: 16,
              color: Color(0xFFE60012),
            ),
            label: const Text(
              'Tất cả hóa đơn',
              style: TextStyle(
                color: Color(0xFFE60012),
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoiceScreen()),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showWarrantyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Chính sách bảo hành',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🛡️ Thời hạn bảo hành tiêu chuẩn:',
              style: TextStyle(
                color: Color(0xFFE60012),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '3 năm hoặc 100.000 km (tùy điều kiện nào đến trước).',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              '🛡️ Phụ tùng chính hãng:',
              style: TextStyle(
                color: Color(0xFFE60012),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Bảo hành 1 năm hoặc 20.000 km đối với phụ tùng thay thế tại đại lý ủy quyền.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Hướng dẫn sử dụng xe',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '1. Kiểm tra áp suất lốp định kỳ 2 tuần/lần.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            Text(
              '2. Thay dầu động cơ mỗi 5.000 km.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            Text(
              '3. Bảo dưỡng định kỳ hệ thống phanh mỗi 10.000 km.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            Text(
              '4. Sử dụng phụ tùng và dung dịch chính hãng để tối ưu tuổi thọ động cơ.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showCampaignDialog() {
    final storeContent = Provider.of<StoreContentProvider>(
      context,
      listen: false,
    );
    final campaigns = storeContent.campaigns;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: Row(
          children: const [
            Icon(Icons.percent, color: Color(0xFFE60012), size: 22),
            SizedBox(width: 8),
            Text(
              'Chiến dịch dịch vụ & Ưu đãi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: campaigns.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Hiện chưa có chiến dịch khuyến mãi nào.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: campaigns.length,
                  separatorBuilder: (ctx, i) =>
                      const Divider(color: Colors.white12, height: 20),
                  itemBuilder: (context, idx) {
                    final c = campaigns[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.title,
                                style: const TextStyle(
                                  color: Color(0xFFE60012),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (c.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE60012),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${c.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (c.highlight.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            c.highlight,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (c.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            c.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (c.validUntil.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '⏰ Hạn áp dụng: ${c.validUntil}',
                            style: const TextStyle(
                              color: Color(0xFF8E92A0),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToBooking(context);
            },
            child: const Text('Đặt lịch áp dụng ngay'),
          ),
        ],
      ),
    );
  }

  void _showPrepaidPackagesDialog() {
    final storeContent = Provider.of<StoreContentProvider>(
      context,
      listen: false,
    );
    final packages = storeContent.packages;
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: Row(
          children: const [
            Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFFE60012),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Gói bảo dưỡng trả trước',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: packages.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Chưa có gói bảo dưỡng trả trước nào.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: packages.length,
                  separatorBuilder: (ctx, i) =>
                      const Divider(color: Colors.white12, height: 20),
                  itemBuilder: (context, idx) {
                    final pkg = packages[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pkg.name,
                                style: const TextStyle(
                                  color: Color(0xFFE60012),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              currency.format(pkg.price),
                              style: const TextStyle(
                                color: Color(0xFF2ECC71),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (pkg.savings.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pkg.savings,
                              style: const TextStyle(
                                color: Color(0xFF2ECC71),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        ...pkg.benefits.map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '✔ ',
                                  style: TextStyle(
                                    color: Color(0xFF2ECC71),
                                    fontSize: 11,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToBooking(context);
            },
            child: const Text('Đăng ký gói ngay'),
          ),
        ],
      ),
    );
  }

  void _showAllServicesListDialog() {
    final svcs = Provider.of<ServiceProvider>(context, listen: false).services;
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Bảng giá Dịch vụ Chính hãng',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          child: svcs.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có dịch vụ nào.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: svcs.length,
                  itemBuilder: (context, idx) {
                    final s = svcs[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${s.category} • ${s.estimatedMinutes} phút',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      trailing: Text(
                        currency.format(s.price),
                        style: const TextStyle(
                          color: Color(0xFFE60012),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToBooking(context);
            },
            child: const Text('Đặt lịch ngay'),
          ),
        ],
      ),
    );
  }

  void _showPartsListDialog({String initialCategory = 'SPARE_PART'}) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.currentUser?.role.toUpperCase() == 'ADMIN';
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // Ensure parts are fetched
    Provider.of<PartProvider>(context, listen: false).fetchParts();

    String currentCategory = initialCategory; // 'SPARE_PART' or 'ACCESSORY'
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Consumer<PartProvider>(
            builder: (context, partProvider, _) {
              final spareParts = partProvider.spareParts;
              final accessories = partProvider.accessories;

              var displayedList = currentCategory == 'SPARE_PART'
                  ? spareParts
                  : accessories;
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                displayedList = displayedList
                    .where(
                      (p) =>
                          p.name.toLowerCase().contains(q) ||
                          p.description.toLowerCase().contains(q),
                    )
                    .toList();
              }

              return Dialog(
                backgroundColor: const Color(0xFF1E212B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 650),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE60012).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              currentCategory == 'SPARE_PART'
                                  ? Icons.build_circle_outlined
                                  : Icons.sports_motorsports_outlined,
                              color: const Color(0xFFE60012),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentCategory == 'SPARE_PART'
                                      ? 'Phụ tùng Chính hãng'
                                      : 'Phụ kiện & Đồ chơi Xe',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isAdmin
                                      ? '★ Chế độ Quản trị viên (Admin)'
                                      : 'Bảng giá niêm yết chính thức',
                                  style: TextStyle(
                                    color: isAdmin
                                        ? const Color(0xFF2ECC71)
                                        : Colors.white60,
                                    fontSize: 11,
                                    fontWeight: isAdmin
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAdmin)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2ECC71),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text(
                                'Thêm mới',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => _showAddEditPartDialog(
                                context,
                                defaultCategory: currentCategory,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Tabs: Phụ tùng vs Phụ kiện
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14161E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C303E)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(
                                  () => currentCategory = 'SPARE_PART',
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentCategory == 'SPARE_PART'
                                        ? const Color(0xFFE60012)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.build,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Phụ tùng (${spareParts.length})',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              currentCategory == 'SPARE_PART'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(
                                  () => currentCategory = 'ACCESSORY',
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentCategory == 'ACCESSORY'
                                        ? const Color(0xFFE60012)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.shield,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Phụ kiện (${accessories.length})',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              currentCategory == 'ACCESSORY'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Search input
                      TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        onChanged: (val) =>
                            setDlgState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText:
                              'Tìm kiếm ${currentCategory == 'SPARE_PART' ? 'phụ tùng' : 'phụ kiện'}...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8E92A0),
                            fontSize: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF8E92A0),
                            size: 18,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2C303E),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2C303E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // List
                      Expanded(
                        child: displayedList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      currentCategory == 'SPARE_PART'
                                          ? Icons.build_outlined
                                          : Icons.sports_motorsports_outlined,
                                      color: const Color(0xFF8E92A0),
                                      size: 36,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Không có ${currentCategory == 'SPARE_PART' ? 'phụ tùng' : 'phụ kiện'} nào phù hợp.',
                                      style: const TextStyle(
                                        color: Color(0xFF8E92A0),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: displayedList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                      color: Color(0xFF2C303E),
                                      height: 1,
                                    ),
                                itemBuilder: (context, idx) {
                                  final p = displayedList[idx];
                                  final inStock = p.stockQuantity > 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF14161E),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            p.isAccessory
                                                ? Icons.sports_motorsports
                                                : Icons.settings,
                                            color: p.isAccessory
                                                ? Colors.amber
                                                : const Color(0xFF3498DB),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (p.description.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  p.description,
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: inStock
                                                          ? const Color(
                                                              0xFF2ECC71,
                                                            ).withAlpha(30)
                                                          : Colors.red
                                                                .withAlpha(30),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      inStock
                                                          ? 'Tồn kho: ${p.stockQuantity}'
                                                          : 'Hết hàng',
                                                      style: TextStyle(
                                                        color: inStock
                                                            ? const Color(
                                                                0xFF2ECC71,
                                                              )
                                                            : Colors.red,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              currency.format(p.price),
                                              style: const TextStyle(
                                                color: Color(0xFFE60012),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (isAdmin) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () =>
                                                        _showAddEditPartDialog(
                                                          context,
                                                          part: p,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withAlpha(30),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  InkWell(
                                                    onTap: () =>
                                                        _confirmDeletePart(
                                                          context,
                                                          p,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withAlpha(30),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 10),

                      // Footer Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Đóng',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          if (!isAdmin) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE60012),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _navigateToBooking(context);
                              },
                              child: const Text('Đặt lịch ngay'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditPartDialog(
    BuildContext context, {
    PartModel? part,
    String defaultCategory = 'SPARE_PART',
  }) {
    final isEditing = part != null;
    final nameCtrl = TextEditingController(text: part?.name ?? '');
    final descCtrl = TextEditingController(text: part?.description ?? '');
    final priceCtrl = TextEditingController(
      text: part != null ? part.price.toStringAsFixed(0) : '',
    );
    final qtyCtrl = TextEditingController(
      text: part != null ? part.stockQuantity.toString() : '10',
    );
    String selectedCategory = part?.category ?? defaultCategory;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E212B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isEditing ? 'Chỉnh sửa: ${part.name}' : 'Thêm mới vào kho',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân loại danh mục:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF14161E),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF14161E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'SPARE_PART',
                        child: Text(
                          '⚙️ Phụ tùng (Thay thế / Kỹ thuật)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ACCESSORY',
                        child: Text(
                          '🛡️ Phụ kiện (Đồ chơi / Tiện ích)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null)
                        setInnerState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tên phụ tùng / phụ kiện',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF14161E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mô tả chi tiết',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF14161E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Đơn giá (VNĐ)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF14161E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Số lượng tồn',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF14161E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgCtx),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  final prov = Provider.of<PartProvider>(
                    context,
                    listen: false,
                  );

                  bool ok;
                  if (isEditing) {
                    ok = await prov.updatePart(
                      part.id,
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      price,
                      qty,
                      selectedCategory,
                    );
                  } else {
                    ok = await prov.addPart(
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      price,
                      qty,
                      selectedCategory,
                    );
                  }

                  if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: ok
                            ? const Color(0xFF2ECC71)
                            : Colors.red,
                        content: Text(
                          ok
                              ? (isEditing
                                    ? 'Cập nhật thành công!'
                                    : 'Thêm mới thành công!')
                              : 'Thao tác thất bại! Vui lòng thử lại.',
                        ),
                      ),
                    );
                  }
                },
                child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm vào kho'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeletePart(BuildContext context, PartModel part) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${part.name}" khỏi danh mục không?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
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
              final ok = await Provider.of<PartProvider>(
                context,
                listen: false,
              ).deletePart(part.id);
              if (dlgCtx.mounted) Navigator.pop(dlgCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? const Color(0xFF2ECC71) : Colors.red,
                    content: Text(
                      ok ? 'Đã xóa ${part.name} thành công!' : 'Xóa thất bại!',
                    ),
                  ),
                );
              }
            },
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceScheduleDialog() {
    final storeContent = Provider.of<StoreContentProvider>(
      context,
      listen: false,
    );
    final milestones = storeContent.milestones;
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: Row(
          children: const [
            Icon(Icons.calendar_month, color: Color(0xFFE60012), size: 22),
            SizedBox(width: 8),
            Text(
              'Lịch trình bảo dưỡng khuyến nghị',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: milestones.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Chưa có lịch trình bảo dưỡng nào.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: milestones.length,
                  separatorBuilder: (ctx, i) =>
                      const Divider(color: Colors.white12, height: 16),
                  itemBuilder: (context, idx) {
                    final m = milestones[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE60012)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE60012),
                                ),
                              ),
                              child: Text(
                                '${NumberFormat('#,###').format(m.km)} KM',
                                style: const TextStyle(
                                  color: Color(0xFFE60012),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                m.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (m.estimatedCost > 0)
                              Text(
                                currency.format(m.estimatedCost),
                                style: const TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...m.tasks.map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(color: Color(0xFFE60012)),
                                ),
                                Expanded(
                                  child: Text(
                                    task,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToBooking(context);
            },
            child: const Text('Đặt lịch hẹn bảo dưỡng'),
          ),
        ],
      ),
    );
  }

  void _showAppFeedbackDialog() {
    final errCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        title: const Text(
          'Báo cáo sự cố ứng dụng',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: errCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Mô tả sự cố bạn gặp phải...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60012),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đã gửi phản hồi sự cố! Đội ngũ kỹ thuật sẽ xử lý sớm.',
                  ),
                ),
              );
            },
            child: const Text('Gửi báo cáo'),
          ),
        ],
      ),
    );
  }

  void _showUserProfileModal(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E212B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE60012),
                        child: Text(
                          (user?.fullName.isNotEmpty ?? false)
                              ? user!.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Khách hàng Blackmyth Auto',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vai trò: ${user?.role ?? "Khách hàng"}',
                              style: const TextStyle(
                                color: Color(0xFFE60012),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2C303E), height: 28),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Email / Gmail',
                      style: TextStyle(color: Color(0xFF8E92A0), fontSize: 12),
                    ),
                    subtitle: Text(
                      user?.email.isNotEmpty == true
                          ? user!.email
                          : 'Chưa thiết lập',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.phone_outlined,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Số điện thoại',
                      style: TextStyle(color: Color(0xFF8E92A0), fontSize: 12),
                    ),
                    subtitle: Text(
                      user?.phoneNumber.isNotEmpty == true
                          ? user!.phoneNumber
                          : 'Chưa thiết lập',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Địa chỉ',
                      style: TextStyle(color: Color(0xFF8E92A0), fontSize: 12),
                    ),
                    subtitle: Text(
                      user?.address?.isNotEmpty == true
                          ? user!.address!
                          : 'Chưa thiết lập địa chỉ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFF2C303E), height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE60012).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFFE60012),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Hóa đơn & Lịch sử thanh toán',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Xem hóa đơn thanh toán tại cửa hàng và online',
                      style: TextStyle(color: Color(0xFF8E92A0), fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white54,
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InvoiceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
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
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text(
                            'Chỉnh sửa thông tin cá nhân',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEditProfileDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red.withAlpha(20),
                            side: const BorderSide(
                              color: Color(0xFFE60012),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout,
                            size: 18,
                            color: Color(0xFFE60012),
                          ),
                          label: const Text(
                            'Đăng xuất tài khoản',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8E92A0),
                      ),
                      icon: const Icon(Icons.dns_outlined, size: 14),
                      label: const Text(
                        'Cấu hình kết nối máy chủ API',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ServerConfigDialog.show(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    final addressCtrl = TextEditingController(text: user?.address ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E212B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.person, color: Color(0xFFE60012)),
                  SizedBox(width: 8),
                  Text(
                    'Chỉnh sửa hồ sơ cá nhân',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.badge,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập họ tên'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Gmail / Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Vui lòng nhập email';
                          if (!v.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập số điện thoại'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ (VD: Thủ Đức, TP.HCM)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.home,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          final success = await auth.updateProfile(
                            fullName: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                          );
                          setDialogState(() => isSaving = false);
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ Cập nhật thông tin cá nhân thành công!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _refreshData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ ${auth.errorMessage}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVehicleModal(BuildContext context, VehicleModel? vehicle) {
    final vehicleProvider = Provider.of<VehicleProvider>(
      context,
      listen: false,
    );

    final brandCtrl = TextEditingController(
      text: vehicle?.brand ?? 'Mitsubishi',
    );
    final modelCtrl = TextEditingController(text: vehicle?.model ?? 'Attrage');
    final yearCtrl = TextEditingController(
      text: vehicle != null ? vehicle.year.toString() : '2020',
    );
    final plateCtrl = TextEditingController(
      text: vehicle?.licensePlate ?? '98A-35711',
    );
    final colorCtrl = TextEditingController(text: vehicle?.color ?? 'Trắng');
    final typeCtrl = TextEditingController(text: vehicle?.vehicleType ?? 'Car');
    final odoCtrl = TextEditingController(
      text: vehicle != null && vehicle.currentOdometer > 0
          ? vehicle.currentOdometer.toString()
          : '109700',
    );

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E212B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.directions_car, color: Color(0xFFE60012)),
                  const SizedBox(width: 8),
                  Text(
                    vehicle != null ? 'Chỉnh sửa thông tin xe' : 'Thêm xe mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live vehicle image preview
                      Container(
                        height: 90,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14161E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C303E)),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                _getVehicleImageUrl(
                                  brandCtrl.text,
                                  modelCtrl.text,
                                  typeCtrl.text,
                                ),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.directions_car,
                                      size: 40,
                                      color: Colors.white24,
                                    ),
                              ),
                            ),
                            Text(
                              '${brandCtrl.text.isNotEmpty ? brandCtrl.text : "Hãng"} ${modelCtrl.text.isNotEmpty ? modelCtrl.text : "Dòng xe"}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: brandCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Hãng xe (VD: Mitsubishi, Toyota...)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.branding_watermark,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập hãng xe'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: modelCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Dòng xe (VD: Attrage, Xpander...)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.car_crash,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập dòng xe'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: plateCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Biển số',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                prefixIcon: const Icon(
                                  Icons.pin,
                                  color: Colors.white60,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF14161E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Cần biển số'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: yearCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Năm SX',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF14161E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Năm không hợp lệ'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: colorCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Màu xe (VD: Trắng)',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF14161E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: typeCtrl,
                              onChanged: (_) => setDialogState(() {}),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Loại xe (Car/Moto)',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF14161E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: odoCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Số ODO hiện tại (km)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.speed,
                            color: Colors.white60,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14161E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Vui lòng nhập số km hợp lệ'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);

                          bool success = false;
                          final year =
                              int.tryParse(yearCtrl.text.trim()) ?? 2020;
                          final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;

                          if (vehicle != null) {
                            success = await vehicleProvider.updateVehicle(
                              id: vehicle.id,
                              brand: brandCtrl.text.trim(),
                              model: modelCtrl.text.trim(),
                              year: year,
                              licensePlate: plateCtrl.text.trim(),
                              color: colorCtrl.text.trim(),
                              vehicleType: typeCtrl.text.trim(),
                              currentOdometer: odo,
                            );
                          } else {
                            success = await vehicleProvider.addVehicle(
                              brand: brandCtrl.text.trim(),
                              model: modelCtrl.text.trim(),
                              year: year,
                              licensePlate: plateCtrl.text.trim(),
                              color: colorCtrl.text.trim(),
                              vehicleType: typeCtrl.text.trim(),
                            );
                          }

                          setDialogState(() => isSaving = false);
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ Cập nhật thông tin xe thành công!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _refreshData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '❌ ${vehicleProvider.errorMessage}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu thông tin xe'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
