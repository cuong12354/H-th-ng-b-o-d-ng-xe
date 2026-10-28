import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/store_content_provider.dart';
import '../models/store_content_models.dart';

class AdminStoreContentView extends StatefulWidget {
  const AdminStoreContentView({super.key});

  @override
  State<AdminStoreContentView> createState() => _AdminStoreContentViewState();
}

class _AdminStoreContentViewState extends State<AdminStoreContentView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Controllers for Store Info
  late TextEditingController _nameCtrl;
  late TextEditingController _addrCtrl;
  late TextEditingController _hotlineCtrl;
  late TextEditingController _rescueCtrl;
  late TextEditingController _hoursCtrl;
  late TextEditingController _fbCtrl;
  late TextEditingController _messCtrl;
  late TextEditingController _ytCtrl;
  late TextEditingController _webCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final store = Provider.of<StoreContentProvider>(context, listen: false).storeInfo;
    _nameCtrl = TextEditingController(text: store.garageName);
    _addrCtrl = TextEditingController(text: store.address);
    _hotlineCtrl = TextEditingController(text: store.hotline);
    _rescueCtrl = TextEditingController(text: store.rescueHotline);
    _hoursCtrl = TextEditingController(text: store.openingHours);
    _fbCtrl = TextEditingController(text: store.facebookUrl);
    _messCtrl = TextEditingController(text: store.messengerUrl);
    _ytCtrl = TextEditingController(text: store.youtubeUrl);
    _webCtrl = TextEditingController(text: store.websiteUrl);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _hotlineCtrl.dispose();
    _rescueCtrl.dispose();
    _hoursCtrl.dispose();
    _fbCtrl.dispose();
    _messCtrl.dispose();
    _ytCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  void _saveStoreInfo() async {
    final storeProvider = Provider.of<StoreContentProvider>(context, listen: false);
    final updated = storeProvider.storeInfo.copyWith(
      garageName: _nameCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
      hotline: _hotlineCtrl.text.trim(),
      rescueHotline: _rescueCtrl.text.trim(),
      openingHours: _hoursCtrl.text.trim(),
      facebookUrl: _fbCtrl.text.trim(),
      messengerUrl: _messCtrl.text.trim(),
      youtubeUrl: _ytCtrl.text.trim(),
      websiteUrl: _webCtrl.text.trim(),
    );
    await storeProvider.updateStoreInfo(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✔ Đã lưu thông tin Tiệm & Hotline thành công! App khách hàng đã cập nhật.'),
        backgroundColor: Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top TabBar for owner
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFFE60012),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFFE60012),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.store, size: 18), text: '1. Thông tin Tiệm'),
              Tab(icon: Icon(Icons.percent, size: 18), text: '2. Chiến dịch & Ưu đãi'),
              Tab(icon: Icon(Icons.confirmation_number_outlined, size: 18), text: '3. Gói bảo dưỡng'),
              Tab(icon: Icon(Icons.calendar_month, size: 18), text: '4. Lịch bảo dưỡng'),
              Tab(icon: Icon(Icons.campaign, size: 18), text: '5. Tin tức & Banner'),
              Tab(icon: Icon(Icons.card_giftcard, size: 18), text: '6. Voucher đổi quà'),
            ],
          ),
        ),

        // Sub-Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStoreInfoTab(),
              _buildCampaignsTab(),
              _buildPackagesTab(),
              _buildMilestonesTab(),
              _buildNewsTab(),
              _buildVouchersTab(),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SUB-TAB 1: THÔNG TIN TIỆM & HOTLINE
  // =========================================================================
  Widget _buildStoreInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.business, color: Color(0xFFE60012), size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cấu hình Thương hiệu, Địa chỉ & Tổng đài',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mọi thông tin bạn thay đổi tại đây sẽ lập tức hiển thị trên ứng dụng của tất cả khách hàng.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Divider(height: 24),

                  _buildField('Tên Gara / Thương hiệu', _nameCtrl, 'VD: GARA TIỆM XE MÁY & Ô TÔ BLACKMYTH AUTO', Icons.badge),
                  const SizedBox(height: 12),
                  _buildField('Địa chỉ trụ sở chính', _addrCtrl, 'VD: 68 Võ Văn Ngân, TP. Thủ Đức', Icons.location_on),
                  const SizedBox(height: 12),

                  if (isNarrow) ...[
                    _buildField('Số Hotline CSKH', _hotlineCtrl, 'VD: 1900 6868', Icons.phone),
                    const SizedBox(height: 12),
                    _buildField('Hotline Cứu hộ 24/7', _rescueCtrl, 'VD: 0909 686 868', Icons.emergency),
                  ] else
                    Row(
                      children: [
                        Expanded(child: _buildField('Số Hotline CSKH', _hotlineCtrl, 'VD: 1900 6868', Icons.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Hotline Cứu hộ 24/7', _rescueCtrl, 'VD: 0909 686 868', Icons.emergency)),
                      ],
                    ),
                  const SizedBox(height: 12),
                  _buildField('Giờ mở cửa phục vụ', _hoursCtrl, 'VD: 07:30 - 18:00 (Tất cả các ngày trong tuần)', Icons.access_time),
                  const SizedBox(height: 16),

                  const Text(
                    'Đường dẫn Mạng xã hội của Gara (Khách bấm trên app sẽ mở link này):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B2A4A)),
                  ),
                  const SizedBox(height: 10),

                  if (isNarrow) ...[
                    _buildField('Fanpage Facebook', _fbCtrl, 'Link Facebook tiệm', Icons.facebook),
                    const SizedBox(height: 12),
                    _buildField('Messenger / Zalo', _messCtrl, 'Link Messenger hoặc Zalo', Icons.chat),
                    const SizedBox(height: 12),
                    _buildField('Kênh Youtube', _ytCtrl, 'Link Youtube tiệm', Icons.play_circle_fill),
                    const SizedBox(height: 12),
                    _buildField('Trang Web Gara', _webCtrl, 'Link Website tiệm', Icons.language),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(child: _buildField('Fanpage Facebook', _fbCtrl, 'Link Facebook tiệm', Icons.facebook)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Messenger / Zalo', _messCtrl, 'Link Messenger hoặc Zalo', Icons.chat)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField('Kênh Youtube', _ytCtrl, 'Link Youtube tiệm', Icons.play_circle_fill)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Trang Web Gara', _webCtrl, 'Link Website tiệm', Icons.language)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Responsive action buttons (Wrap prevents right overflow)
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<StoreContentProvider>(context, listen: false).resetToDefaults();
                          final def = StoreInfo.defaultInfo();
                          setState(() {
                            _nameCtrl.text = def.garageName;
                            _addrCtrl.text = def.address;
                            _hotlineCtrl.text = def.hotline;
                            _rescueCtrl.text = def.rescueHotline;
                            _hoursCtrl.text = def.openingHours;
                            _fbCtrl.text = def.facebookUrl;
                            _messCtrl.text = def.messengerUrl;
                            _ytCtrl.text = def.youtubeUrl;
                            _webCtrl.text = def.websiteUrl;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã khôi phục thông tin tiệm mặc định.')),
                          );
                        },
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: const Text('Khôi phục mặc định'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveStoreInfo,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('LƯU THÔNG TIN TIỆM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE60012),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 2: CHIẾN DỊCH & KHUYẾN MÃI (%)
  // =========================================================================
  Widget _buildCampaignsTab() {
    return Consumer<StoreContentProvider>(
      builder: (context, provider, _) {
        final list = provider.allCampaigns;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chiến dịch dịch vụ & Khuyến mãi (%)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                    ),
                    Text(
                      'Hiển thị trong ô "% Chiến dịch dịch vụ" của khách hàng.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCampaignEditDialog(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm Khuyến Mãi Mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Chưa có chương trình khuyến mãi nào. Bấm nút Thêm để tạo mới.'),
                ),
              )
            else
              ...list.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE60012).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.percent, color: Color(0xFFE60012), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      c.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B2A4A)),
                                    ),
                                    if (c.discountPercent > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE60012),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'GIẢM ${c.discountPercent}%',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(c.highlight, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(c.description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                const SizedBox(height: 6),
                                Text('Hạn áp dụng: ${c.validUntil}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                tooltip: 'Chỉnh sửa',
                                onPressed: () => _showCampaignEditDialog(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                tooltip: 'Xóa',
                                onPressed: () => _confirmDelete('khuyến mãi', () {
                                  provider.deleteCampaign(c.id);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showCampaignEditDialog(CampaignItem? item) {
    final titleCtrl = TextEditingController(text: item?.title ?? '🔥 Khuyến mãi mới:');
    final highlightCtrl = TextEditingController(text: item?.highlight ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final discountCtrl = TextEditingController(text: item != null ? item.discountPercent.toString() : '20');
    final validCtrl = TextEditingController(text: item?.validUntil ?? '31/12/2026');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm Chiến Dịch Khuyến Mãi' : 'Chỉnh Sửa Chiến Dịch Khuyến Mãi'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Tiêu đề chiến dịch', titleCtrl, 'VD: 🔥 Khuyến mãi mùa mưa:'),
                const SizedBox(height: 10),
                _buildField('Điểm nhấn nổi bật', highlightCtrl, 'VD: Giảm 20% gạt mưa chính hãng và dầu động cơ.'),
                const SizedBox(height: 10),
                _buildField('Mô tả chi tiết', descCtrl, 'VD: Miễn phí kiểm tra bình ắc quy và phanh...'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField('Mức giảm (%)', discountCtrl, '20')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Hạn áp dụng', validCtrl, '31/12/2026')),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60012), foregroundColor: Colors.white),
            onPressed: () {
              final prov = Provider.of<StoreContentProvider>(context, listen: false);
              final newItem = CampaignItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleCtrl.text.trim(),
                highlight: highlightCtrl.text.trim(),
                description: descCtrl.text.trim(),
                discountPercent: int.tryParse(discountCtrl.text.trim()) ?? 0,
                validUntil: validCtrl.text.trim(),
              );
              if (item == null) {
                prov.addCampaign(newItem);
              } else {
                prov.updateCampaign(newItem);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật chiến dịch thành công!')));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 3: GÓI BẢO DƯỠNG TRẢ TRƯỚC
  // =========================================================================
  Widget _buildPackagesTab() {
    return Consumer<StoreContentProvider>(
      builder: (context, provider, _) {
        final list = provider.allPackages;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gói Bảo Dưỡng Trả Trước Định Kỳ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                    ),
                    Text(
                      'Hiển thị trong ô "Gói bảo dưỡng trả trước" của khách hàng.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showPackageEditDialog(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm Gói Mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có gói bảo dưỡng nào.')))
            else
              ...list.map((pkg) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF2ECC71), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      pkg.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B2A4A)),
                                    ),
                                    Text(
                                      _currency.format(pkg.price),
                                      style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (pkg.savings.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      pkg.savings,
                                      style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                ...pkg.benefits.map((b) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          const Text('✔ ', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 12)),
                                          Expanded(child: Text(b, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                onPressed: () => _showPackageEditDialog(pkg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () => _confirmDelete('gói bảo dưỡng', () {
                                  provider.deletePackage(pkg.id);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showPackageEditDialog(PrepaidPackageItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '💎 Gói 1 Năm (2 lần bảo dưỡng)');
    final priceCtrl = TextEditingController(text: item != null ? item.price.toInt().toString() : '1500000');
    final savingsCtrl = TextEditingController(text: item?.savings ?? 'Tiết kiệm 15% so với giá lẻ');
    final durationCtrl = TextEditingController(text: item != null ? item.durationMonths.toString() : '12');
    final benefitsCtrl = TextEditingController(text: item != null ? item.benefits.join('\n') : '2 lần thay nhớt động cơ chính hãng\nMiễn phí công kiểm tra 30 hạng mục an toàn\nƯu tiên phục vụ không cần chờ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm Gói Bảo Dưỡng Trả Trước' : 'Chỉnh Sửa Gói Bảo Dưỡng'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Tên gói', nameCtrl, 'VD: 💎 Gói 1 Năm (2 lần bảo dưỡng)'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField('Giá trọn gói (VNĐ)', priceCtrl, '1500000')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Thời hạn (tháng)', durationCtrl, '12')),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Mức tiết kiệm / Ưu đãi', savingsCtrl, 'VD: Tiết kiệm 15% so với giá lẻ'),
                const SizedBox(height: 10),
                _buildField('Danh sách quyền lợi (Mỗi dòng một mục)', benefitsCtrl, 'Nhập quyền lợi...', null, 4),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60012), foregroundColor: Colors.white),
            onPressed: () {
              final prov = Provider.of<StoreContentProvider>(context, listen: false);
              final benefits = benefitsCtrl.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final newItem = PrepaidPackageItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                savings: savingsCtrl.text.trim(),
                durationMonths: int.tryParse(durationCtrl.text.trim()) ?? 12,
                benefits: benefits,
              );
              if (item == null) {
                prov.addPackage(newItem);
              } else {
                prov.updatePackage(newItem);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật gói bảo dưỡng thành công!')));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 4: LỊCH BẢO DƯỠNG ĐỊNH KỲ
  // =========================================================================
  Widget _buildMilestonesTab() {
    return Consumer<StoreContentProvider>(
      builder: (context, provider, _) {
        final list = provider.milestones;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch Trình Bảo Dưỡng Khuyến Nghị',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                    ),
                    Text(
                      'Hiển thị trong ô "Lịch bảo dưỡng" của khách hàng.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showMilestoneEditDialog(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm Mốc KM Mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có mốc bảo dưỡng nào.')))
            else
              ...list.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE60012).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE60012).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.speed, color: Color(0xFFE60012), size: 16),
                                const SizedBox(height: 2),
                                Text(
                                  '${NumberFormat('#,###').format(m.km)}\nKM',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE60012), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      m.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B2A4A)),
                                    ),
                                    if (m.estimatedCost > 0)
                                      Text(
                                        'Ước tính: ${_currency.format(m.estimatedCost)}',
                                        style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...m.tasks.map((task) => Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(color: Color(0xFFE60012))),
                                          Expanded(child: Text(task, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                onPressed: () => _showMilestoneEditDialog(m),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () => _confirmDelete('mốc bảo dưỡng', () {
                                  provider.deleteMilestone(m.id);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showMilestoneEditDialog(MaintenanceMilestone? item) {
    final kmCtrl = TextEditingController(text: item != null ? item.km.toString() : '5000');
    final titleCtrl = TextEditingController(text: item?.title ?? 'Mốc 5.000 km hoặc 3 tháng');
    final costCtrl = TextEditingController(text: item != null ? item.estimatedCost.toInt().toString() : '350000');
    final tasksCtrl = TextEditingController(text: item != null ? item.tasks.join('\n') : 'Thay dầu động cơ chính hãng\nKiểm tra lọc gió & buồng máy\nKiểm tra hệ thống phanh');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm Mốc Lịch Bảo Dưỡng' : 'Chỉnh Sửa Mốc Bảo Dưỡng'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildField('Số KM (VD: 5000, 10000)', kmCtrl, '5000')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Chi phí ước tính (VNĐ)', costCtrl, '350000')),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Tiêu đề mốc', titleCtrl, 'VD: Mốc 5.000 km hoặc 3 tháng'),
                const SizedBox(height: 10),
                _buildField('Các hạng mục cần làm (Mỗi dòng một mục)', tasksCtrl, 'Nhập các hạng mục...', null, 4),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60012), foregroundColor: Colors.white),
            onPressed: () {
              final prov = Provider.of<StoreContentProvider>(context, listen: false);
              final tasks = tasksCtrl.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final newItem = MaintenanceMilestone(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                km: int.tryParse(kmCtrl.text.trim()) ?? 0,
                title: titleCtrl.text.trim(),
                tasks: tasks,
                estimatedCost: double.tryParse(costCtrl.text.trim()) ?? 0,
              );
              if (item == null) {
                prov.addMilestone(newItem);
              } else {
                prov.updateMilestone(newItem);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật mốc bảo dưỡng thành công!')));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 5: TIN TỨC & BANNER
  // =========================================================================
  Widget _buildNewsTab() {
    return Consumer<StoreContentProvider>(
      builder: (context, provider, _) {
        final list = provider.newsList;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tin Tức & Sự Kiện Trang Chủ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                    ),
                    Text(
                      'Hiển thị ở thanh tin tức cuộn ngang trên Trang chủ của khách hàng.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewsEditDialog(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Đăng Tin Mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có bài tin tức nào.')))
            else
              ...list.map((n) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              n.imageUrl,
                              width: 70,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                width: 70,
                                height: 55,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B2A4A)),
                                ),
                                const SizedBox(height: 2),
                                Text(n.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                const SizedBox(height: 2),
                                Text('Ngày đăng: ${n.date}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                            onPressed: () => _showNewsEditDialog(n),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => _confirmDelete('bài tin tức', () {
                              provider.deleteNews(n.id);
                            }),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showNewsEditDialog(NewsItem? item) {
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final imgCtrl = TextEditingController(text: item?.imageUrl ?? 'https://images.unsplash.com/photo-1563720223185-11003d516935?w=500');
    final sumCtrl = TextEditingController(text: item?.summary ?? '');
    final dateCtrl = TextEditingController(text: item?.date ?? DateFormat('dd/MM/yyyy').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Đăng Bài Tin Mới' : 'Chỉnh Sửa Bài Tin'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Tiêu đề bài tin', titleCtrl, 'VD: KHAI TRƯƠNG CƠ SỞ ỦY QUYỀN MỚI'),
                const SizedBox(height: 10),
                _buildField('Link hình ảnh (URL)', imgCtrl, 'https://...'),
                const SizedBox(height: 10),
                _buildField('Tóm tắt nội dung', sumCtrl, 'Nội dung ngắn...', null, 3),
                const SizedBox(height: 10),
                _buildField('Ngày hiển thị', dateCtrl, '28/10/2026'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60012), foregroundColor: Colors.white),
            onPressed: () {
              final prov = Provider.of<StoreContentProvider>(context, listen: false);
              final newItem = NewsItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleCtrl.text.trim(),
                imageUrl: imgCtrl.text.trim(),
                summary: sumCtrl.text.trim(),
                date: dateCtrl.text.trim(),
              );
              if (item == null) {
                prov.addNews(newItem);
              } else {
                prov.updateNews(newItem);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật tin tức thành công!')));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-TAB 6: VOUCHER ĐỔI QUÀ
  // =========================================================================
  Widget _buildVouchersTab() {
    return Consumer<StoreContentProvider>(
      builder: (context, provider, _) {
        final list = provider.vouchers;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quà Tặng & Voucher Đổi Điểm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                    ),
                    Text(
                      'Hiển thị trong mục "Đổi quà" của khách hàng.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showVoucherEditDialog(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm Voucher Mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60012),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có voucher nào.')))
            else
              ...list.map((v) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.card_giftcard, color: Colors.amber.shade800, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      v.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B2A4A)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade700,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${v.pointsRequired} ĐIỂM',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(v.description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(v.category, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                    ),
                                    Text('Hạn dùng: ${v.validUntil}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                onPressed: () => _showVoucherEditDialog(v),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () => _confirmDelete('voucher', () {
                                  provider.deleteVoucher(v.id);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showVoucherEditDialog(RewardVoucherItem? item) {
    final titleCtrl = TextEditingController(text: item?.title ?? 'Voucher Dịch Vụ 500.000 VNĐ');
    final pointsCtrl = TextEditingController(text: item != null ? item.pointsRequired.toString() : '250');
    final catCtrl = TextEditingController(text: item?.category ?? 'Voucher dịch vụ');
    final descCtrl = TextEditingController(text: item?.description ?? 'Áp dụng cho mọi hóa đơn bảo dưỡng');
    final validCtrl = TextEditingController(text: item?.validUntil ?? '02/2027');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm Voucher Đổi Quà' : 'Chỉnh Sửa Voucher'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Tên Voucher', titleCtrl, 'VD: Voucher Dịch Vụ 500.000 VNĐ'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField('Số điểm cần đổi', pointsCtrl, '250')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Danh mục', catCtrl, 'Voucher dịch vụ')),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Mô tả điều kiện', descCtrl, 'Áp dụng cho...'),
                const SizedBox(height: 10),
                _buildField('Hạn sử dụng', validCtrl, '02/2027'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60012), foregroundColor: Colors.white),
            onPressed: () {
              final prov = Provider.of<StoreContentProvider>(context, listen: false);
              final newItem = RewardVoucherItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleCtrl.text.trim(),
                pointsRequired: int.tryParse(pointsCtrl.text.trim()) ?? 0,
                category: catCtrl.text.trim(),
                description: descCtrl.text.trim(),
                validUntil: validCtrl.text.trim(),
              );
              if (item == null) {
                prov.addVoucher(newItem);
              } else {
                prov.updateVoucher(newItem);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật voucher thành công!')));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  Widget _buildField(String label, TextEditingController controller, String hint, [IconData? icon, int maxLines = 1]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B2A4A))),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFFE60012)) : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(String itemType, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa $itemType?'),
        content: Text('Bạn có chắc muốn xóa $itemType này không? Hành động này sẽ cập nhật ngay trên máy khách hàng.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
