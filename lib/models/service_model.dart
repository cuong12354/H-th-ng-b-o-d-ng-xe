class ServiceModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int estimatedMinutes;
  final String category;
  final String imageUrl;
  final bool isPopular;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedMinutes,
    required this.category,
    required this.imageUrl,
    this.isPopular = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimatedMinutes': estimatedMinutes,
      'category': category,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
    };
  }
}
