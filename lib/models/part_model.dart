class PartModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String category; // 'SPARE_PART' or 'ACCESSORY'

  PartModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.category = 'SPARE_PART',
  });

  bool get isAccessory => category.toUpperCase() == 'ACCESSORY';
  bool get isSparePart => !isAccessory;

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category']?.toString() ?? 'SPARE_PART',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'category': category,
    };
  }
}
