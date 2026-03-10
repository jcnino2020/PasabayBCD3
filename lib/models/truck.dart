// ============================================================
// Model: Truck
// Represents a truck/vehicle available for cargo booking
// ============================================================

class Truck {
  final String id;
  final String type;        // e.g., "L300 VAN", "MULTICAB"
  final String driverName;  // Note: In a real app, this would come from a JOIN with a drivers/users table
  final double rating;      // Note: This would also come from the driver/user record
  final String plateNumber;
  final String route;       // e.g., "Libertad → Mansilingan"
  final String departTime;  // e.g., "2:30 PM"
  final double price;       // from base_price in DB
  final double capacityKg;
  final double capacityCbm; // cubic meters
  final String? profilePhotoUrl;

  Truck({
    required this.id,
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

// Sample data matching the wireframe
List<Truck> sampleTrucks = [
  Truck(
    id: '1',
    type: 'L300 VAN',
    driverName: 'Manong Juan',
    rating: 4.7,
    plateNumber: 'BCD-123',
    route: 'Libertad → Mansilingan',
    departTime: '2:30 PM',
    price: 150,
    capacityKg: 200,
    capacityCbm: 1.5,
    // Placeholder image from a free-to-use service
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver1',
  ),
  Truck(
    id: '2',
    type: 'MULTICAB',
    driverName: 'Kuya Ben',
    rating: 4.5,
    plateNumber: 'PAD-682',
    route: 'Burgos → Bata',
    departTime: '3:00 PM',
    price: 80,
    capacityKg: 100,
    capacityCbm: 0.8,
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver2',
  ),
  Truck(
    id: '3',
    type: 'L300 VAN',
    driverName: 'Lolo Bert',
    rating: 4.3,
    plateNumber: 'BCD-445',
    route: 'Central Market → Tangub',
    departTime: '4:00 PM',
    price: 120,
    capacityKg: 180,
    capacityCbm: 1.2,
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver3',
  ),
  Truck(
    id: '4',
    type: 'MULTICAB',
    driverName: 'Mang Kardo',
    rating: 4.8,
    plateNumber: 'BAK-111',
    route: 'Libertad → Alijis',
    departTime: '2:45 PM',
    price: 90,
    capacityKg: 120,
    capacityCbm: 1.0,
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver4',
  ),
  Truck(
    id: '5',
    type: 'L300 VAN',
    driverName: 'Kuya Romy',
    rating: 4.6,
    plateNumber: 'CAR-555',
    route: 'Burgos → Estefania',
    departTime: '3:15 PM',
    price: 160,
    capacityKg: 220,
    capacityCbm: 1.6,
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver5',
  ),
  Truck(
    id: '6',
    type: 'MULTICAB',
    driverName: 'Nong Pido',
    rating: 4.4,
    plateNumber: 'XYZ-999',
    route: 'Central Market → Sum-ag',
    departTime: '4:30 PM',
    price: 110,
    capacityKg: 150,
    capacityCbm: 1.1,
    profilePhotoUrl: 'https://i.pravatar.cc/150?u=driver6',
  ),
];
