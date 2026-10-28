class VehicleModel {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final String vehicleType;
  final int currentOdometer;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.vehicleType,
    this.currentOdometer = 0,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      licensePlate: json['licensePlate'] ?? '',
      color: json['color'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      currentOdometer: json['currentOdometer'] ?? 0,
    );
  }
}
