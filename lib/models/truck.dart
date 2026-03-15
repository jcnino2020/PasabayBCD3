// ============================================================
// Model: Truck
// Represents a truck/vehicle available for cargo booking
// ============================================================

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
      driverId: (json['driver_id'] as num?)?.toInt() ?? 0,
      type: json['type'] ?? 'N/A',
      driverName: json['driver_name'] ?? 'Unknown Driver',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      plateNumber: json['plate_number'] ?? 'N/A',
      route: json['current_route'] ?? 'No route',
      departTime: json['depart_time'] ?? 'N/A',
      price: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      capacityKg: (json['capacity_kg'] as num?)?.toDouble() ?? 0.0,
      capacityCbm: (json['capacity_cbm'] as num?)?.toDouble() ?? 0.0,
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
