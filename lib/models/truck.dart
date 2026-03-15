// ============================================================
// Model: Truck
// Represents a truck/vehicle available for cargo booking
// ============================================================

// Helper to safely parse a value that might be a String or a num
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class Truck {
  final String id;
  final int driverId;       // Foreign key to the drivers table
  final String type;        // e.g., "L300 VAN", "MULTICAB"
  final String driverName;  // Comes from a JOIN with the drivers table
  final double rating;      // Driver's average rating
  final String plateNumber;
  final String route;       // e.g., "Libertad → Mansilingan"
  final String departTime;  // e.g., "2:30 PM"
  final double price;       // from base_price in DB
  final double capacityKg;
  final double capacityCbm; // cubic meters
  final String? profilePhotoUrl;

  Truck({
    required this.id,
    this.driverId = 0,
    required this.type,
    required this.driverName,
    required this.rating,
    required this.plateNumber,
    required this.route,
    required this.departTime,
    required this.price,
    required this.capacityKg,
    required this.capacityCbm,
    this.profilePhotoUrl,
  });

  // Factory constructor to create a Truck from a JSON object
  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id'].toString(),
      driverId: _toInt(json['driver_id']),
      type: json['type'] ?? 'N/A',
      driverName: json['driver_name'] ?? 'Unknown Driver',
      rating: _toDouble(json['rating']),
      plateNumber: json['plate_number'] ?? 'N/A',
      route: json['current_route'] ?? 'No route',
      departTime: json['depart_time'] ?? 'N/A',
      price: _toDouble(json['base_price']),
      capacityKg: _toDouble(json['capacity_kg']),
      capacityCbm: _toDouble(json['capacity_cbm']),
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
