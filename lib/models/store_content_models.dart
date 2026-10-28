/// Thông tin liên hệ và giới thiệu của Gara
class StoreInfo {
  final String garageName;
  final String address;
  final String hotline;
  final String rescueHotline;
  final String openingHours;
  final String facebookUrl;
  final String messengerUrl;
  final String youtubeUrl;
  final String websiteUrl;

  StoreInfo({
    required this.garageName,
    required this.address,
    required this.hotline,
    required this.rescueHotline,
    required this.openingHours,
    this.facebookUrl = 'https://facebook.com',
    this.messengerUrl = 'https://m.me',
    this.youtubeUrl = 'https://youtube.com',
    this.websiteUrl = 'https://blackmythauto.vn',
  });

  StoreInfo copyWith({
    String? garageName,
    String? address,
    String? hotline,
    String? rescueHotline,
    String? openingHours,
    String? facebookUrl,
    String? messengerUrl,
    String? youtubeUrl,
    String? websiteUrl,
  }) {
    return StoreInfo(
      garageName: garageName ?? this.garageName,
      address: address ?? this.address,
      hotline: hotline ?? this.hotline,
      rescueHotline: rescueHotline ?? this.rescueHotline,
      openingHours: openingHours ?? this.openingHours,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      messengerUrl: messengerUrl ?? this.messengerUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
    );
  }

  factory StoreInfo.defaultInfo() {
    return StoreInfo(
      garageName: 'GARA TIỆM XE MÁY & Ô TÔ BLACKMYTH AUTO',
      address: '68 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức, TP. Hồ Chí Minh',
      hotline: '1900 6868',
      rescueHotline: '0909 686 868 (Cứu hộ 24/7)',
      openingHours: '07:30 - 18:00 (Tất cả các ngày trong tuần)',
      facebookUrl: 'https://facebook.com/blackmythauto',
      messengerUrl: 'https://m.me/blackmythauto',
      youtubeUrl: 'https://youtube.com/@blackmythauto',
      websiteUrl: 'https://blackmythauto.vn',
    );
  }

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      garageName:
          json['garageName'] ?? 'GARA TIỆM XE MÁY & Ô TÔ BLACKMYTH AUTO',
      address: json['address'] ?? '68 Võ Văn Ngân, TP. Thủ Đức',
      hotline: json['hotline'] ?? '1900 6868',
      rescueHotline: json['rescueHotline'] ?? '0909 686 868',
      openingHours: json['openingHours'] ?? '07:30 - 18:00',
      facebookUrl: json['facebookUrl'] ?? 'https://facebook.com',
      messengerUrl: json['messengerUrl'] ?? 'https://m.me',
      youtubeUrl: json['youtubeUrl'] ?? 'https://youtube.com',
      websiteUrl: json['websiteUrl'] ?? 'https://blackmythauto.vn',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'garageName': garageName,
      'address': address,
      'hotline': hotline,
      'rescueHotline': rescueHotline,
      'openingHours': openingHours,
      'facebookUrl': facebookUrl,
      'messengerUrl': messengerUrl,
      'youtubeUrl': youtubeUrl,
      'websiteUrl': websiteUrl,
    };
  }
}

/// Chiến dịch dịch vụ (%) / Khuyến mãi
class CampaignItem {
  final String id;
  final String title;
  final String highlight;
  final String description;
  final int discountPercent;
  final String validUntil;
  final bool isActive;

  CampaignItem({
    required this.id,
    required this.title,
    required this.highlight,
    required this.description,
    this.discountPercent = 20,
    this.validUntil = '31/12/2026',
    this.isActive = true,
  });

  factory CampaignItem.fromJson(Map<String, dynamic> json) {
    return CampaignItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      highlight: json['highlight'] ?? '',
      description: json['description'] ?? '',
      discountPercent: json['discountPercent'] ?? 0,
      validUntil: json['validUntil'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'highlight': highlight,
      'description': description,
      'discountPercent': discountPercent,
      'validUntil': validUntil,
      'isActive': isActive,
    };
  }

  static List<CampaignItem> defaultCampaigns() {
    return [
      CampaignItem(
        id: 'c1',
        title: '🔥 Khuyến mãi mùa mưa:',
        highlight: 'Giảm 20% gạt mưa chính hãng và dầu động cơ.',
        description: 'Miễn phí kiểm tra bình ắc quy, hệ thống phanh và kiểm tra lốp an toàn.',
        discountPercent: 20,
        validUntil: '31/12/2026',
      ),
      CampaignItem(
        id: 'c2',
        title: '⚡ Tri ân khách hàng thân thiết:',
        highlight: 'Tặng 01 lần rửa xe bọt tuyết & khử khuẩn nano bạc.',
        description:
            'Áp dụng cho mọi hóa đơn bảo dưỡng định kỳ trên 1.000.000 đ.',
        discountPercent: 15,
        validUntil: 'Hàng tháng',
      ),
    ];
  }
}

/// Gói bảo dưỡng trả trước
class PrepaidPackageItem {
  final String id;
  final String name;
  final double price;
  final String savings;
  final List<String> benefits;
  final int durationMonths;
  final bool isActive;

  PrepaidPackageItem({
    required this.id,
    required this.name,
    required this.price,
    required this.savings,
    required this.benefits,
    this.durationMonths = 12,
    this.isActive = true,
  });

  factory PrepaidPackageItem.fromJson(Map<String, dynamic> json) {
    return PrepaidPackageItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      savings: json['savings'] ?? '',
      benefits:
          (json['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      durationMonths: json['durationMonths'] ?? 12,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'savings': savings,
      'benefits': benefits,
      'durationMonths': durationMonths,
      'isActive': isActive,
    };
  }

  static List<PrepaidPackageItem> defaultPackages() {
    return [
      PrepaidPackageItem(
        id: 'pkg1',
        name: '💎 Gói 1 Năm (2 lần bảo dưỡng)',
        price: 1500000,
        savings: 'Tiết kiệm 15% so với giá lẻ',
        benefits: [
          '2 lần thay nhớt động cơ chính hãng',
          'Miễn phí công kiểm tra 30 hạng mục an toàn',
          'Ưu tiên tiếp nhận nhanh không cần chờ',
        ],
        durationMonths: 12,
      ),
      PrepaidPackageItem(
        id: 'pkg2',
        name: '💎 Gói 2 Năm (4 lần bảo dưỡng)',
        price: 2800000,
        savings: 'Tiết kiệm 25% + Quà tặng độc quyền',
        benefits: [
          '4 lần thay nhớt & lọc nhớt chính hãng',
          'Tặng 02 voucher rửa xe chuyên sâu',
          'Hỗ trợ cứu hộ khẩn cấp miễn phí bán kính 15km',
        ],
        durationMonths: 24,
      ),
    ];
  }
}

/// Mốc cẩm nang lịch bảo dưỡng theo số KM
class MaintenanceMilestone {
  final String id;
  final int km;
  final String title;
  final List<String> tasks;
  final double estimatedCost;

  MaintenanceMilestone({
    required this.id,
    required this.km,
    required this.title,
    required this.tasks,
    this.estimatedCost = 0,
  });

  factory MaintenanceMilestone.fromJson(Map<String, dynamic> json) {
    return MaintenanceMilestone(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      km: json['km'] ?? 0,
      title: json['title'] ?? '',
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'km': km,
      'title': title,
      'tasks': tasks,
      'estimatedCost': estimatedCost,
    };
  }

  static List<MaintenanceMilestone> defaultMilestones() {
    return [
      MaintenanceMilestone(
        id: 'm5k',
        km: 5000,
        title: 'Mốc 5.000 km hoặc 3 tháng',
        tasks: [
          'Thay dầu động cơ chính hãng',
          'Kiểm tra lọc gió & vệ sinh buồng máy',
          'Kiểm tra áp suất lốp và hệ thống phanh cơ bản',
        ],
        estimatedCost: 350000,
      ),
      MaintenanceMilestone(
        id: 'm10k',
        km: 10000,
        title: 'Mốc 10.000 km hoặc 6 tháng',
        tasks: [
          'Thay dầu động cơ & thay cốc lọc nhớt',
          'Đảo lốp và cân bằng động',
          'Vệ sinh thắng phanh trước/sau & kiểm tra nước làm mát',
        ],
        estimatedCost: 650000,
      ),
      MaintenanceMilestone(
        id: 'm20k',
        km: 20000,
        title: 'Mốc 20.000 km hoặc 12 tháng',
        tasks: [
          'Thay lọc gió động cơ, lọc gió điều hòa không khí',
          'Thay dầu phanh, kiểm tra hệ thống treo & rô-tuyn',
          'Kiểm tra ắc quy và hệ thống sạc điện',
        ],
        estimatedCost: 1200000,
      ),
      MaintenanceMilestone(
        id: 'm40k',
        km: 40000,
        title: 'Mốc 40.000 km (Đại tu định kỳ cấp lớn)',
        tasks: [
          'Thay toàn bộ dầu hộp số, dầu phanh, nước làm mát',
          'Thay bugi đánh lửa, lọc nhiên liệu',
          'Vệ sinh họng ga, kim phun buồng đốt bằng máy chuyên dụng',
        ],
        estimatedCost: 2500000,
      ),
    ];
  }
}

/// Bài viết Tin tức / Banner Trang chủ
class NewsItem {
  final String id;
  final String title;
  final String imageUrl;
  final String summary;
  final String date;

  NewsItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.date,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      summary: json['summary'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'summary': summary,
      'date': date,
    };
  }

  static List<NewsItem> defaultNews() {
    return [
      NewsItem(
        id: 'n1',
        title: 'KHAI TRƯƠNG CƠ SỞ ỦY QUYỀN TẠI CAO BẰNG',
        imageUrl: 'https://images.unsplash.com/photo-1563720223185-11003d516935?w=500',
        summary: 'Tưng bừng khai trương cơ sở dịch vụ mới đạt chuẩn quốc tế với đầy đủ trang thiết bị chẩn đoán hiện đại.',
        date: '28/10/2026',
      ),
      NewsItem(
        id: 'n2',
        title: 'KHAI TRƯƠNG NHÀ PHÂN PHỐI BITCAR KHÁNH HÒA',
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=500',
        summary: 'Mở rộng mạng lưới phục vụ quý khách hàng tại khu vực duyên hải miền Trung.',
        date: '20/10/2026',
      ),
      NewsItem(
        id: 'n3',
        title: 'CHƯƠNG TRÌNH TRI ÂN BẢO DƯỠNG MIỄN PHÍ DẦU NHỚT',
        imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=500',
        summary: 'Tặng ngay 1 lon nhớt cao cấp khi đặt lịch trước qua ứng dụng Blackmyth Auto.',
        date: '15/10/2026',
      ),
    ];
  }
}

/// Voucher đổi điểm quà tặng
class RewardVoucherItem {
  final String id;
  final String title;
  final int pointsRequired;
  final String category; // 'Voucher dịch vụ', 'Phiếu quà tặng Gotit', 'Tất cả'
  final String description;
  final String validUntil;

  RewardVoucherItem({
    required this.id,
    required this.title,
    required this.pointsRequired,
    required this.category,
    required this.description,
    required this.validUntil,
  });

  factory RewardVoucherItem.fromJson(Map<String, dynamic> json) {
    return RewardVoucherItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      pointsRequired: json['pointsRequired'] ?? 0,
      category: json['category'] ?? 'Voucher dịch vụ',
      description: json['description'] ?? '',
      validUntil: json['validUntil'] ?? '02/2027',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pointsRequired': pointsRequired,
      'category': category,
      'description': description,
      'validUntil': validUntil,
    };
  }

  static List<RewardVoucherItem> defaultVouchers() {
    return [
      RewardVoucherItem(
        id: 'v1',
        title: 'Voucher Dịch Vụ 1.000.000 VNĐ (Loyalty)',
        pointsRequired: 500,
        category: 'Voucher dịch vụ',
        description:
            'Áp dụng giảm trừ trực tiếp cho hóa đơn dịch vụ từ 2.000.000 đ.',
        validUntil: '02/2027',
      ),
      RewardVoucherItem(
        id: 'v2',
        title: 'Voucher Dịch Vụ 500.000 VNĐ (Loyalty)',
        pointsRequired: 250,
        category: 'Voucher dịch vụ',
        description:
            'Áp dụng cho mọi hóa đơn bảo dưỡng hoặc thay thế phụ tùng.',
        validUntil: '02/2027',
      ),
      RewardVoucherItem(
        id: 'v3',
        title: 'Miễn phí kiểm tra 30 hạng mục an toàn',
        pointsRequired: 100,
        category: 'Voucher dịch vụ',
        description:
            'Kiểm tra toàn diện hệ thống phanh, lốp, động cơ và điện xe.',
        validUntil: '02/2027',
      ),
      RewardVoucherItem(
        id: 'v4',
        title: 'Phiếu quà tặng GotIt trị giá 100.000 VNĐ',
        pointsRequired: 150,
        category: 'Phiếu quà tặng Gotit',
        description:
            'Sử dụng thanh toán tại hơn 300 thương hiệu ăn uống & mua sắm.',
        validUntil: '01/2027',
      ),
    ];
  }
}
