// ============================================================
// Model: Truck
// Represents a truck/vehicle available for cargo booking
// ============================================================

class Truck {
  final String id;
  final String type;        // e.g., "L300 VAN", "MULTICAB"
  final String driverName;
  final double rating;
  final String plateNumber;
  final String route;       // e.g., "Libertad → Mansilingan"
  final String departTime;  // e.g., "2:30 PM"
  final double price;       // in PHP
  final double capacityKg;
  final double capacityCbm; // cubic meters
  final bool isVaccinated;

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
    this.isVaccinated = false,
  });
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
    isVaccinated: true,
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
    isVaccinated: false,
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
    isVaccinated: true,
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
    isVaccinated: true,
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
    isVaccinated: true,
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
    isVaccinated: false,
  ),
];
