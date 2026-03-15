// ============================================================
// Model: Booking
// Represents a cargo booking made by a merchant
// ============================================================

import 'truck.dart';

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

class Booking {
  final String id;
  final String truckId;
  final String driverName;
  final String cargoCategory; // Produce, Box, Textile
  final double weightKg;
  final int quantity;
  final double estimatedFee;
  final String status; // pending, confirmed, in_transit, delivered
  final String? cargoPhotoUrl;

  Booking({
    required this.id,
    required this.truckId,
    required this.driverName,
    required this.cargoCategory,
    required this.weightKg,
    required this.quantity,
    required this.estimatedFee,
    this.status = 'pending',
    this.cargoPhotoUrl,
  });

  // Factory constructor to create a Booking from a JSON object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      truckId: json['truck_id'].toString(),
      driverName: json['driver_name'] ?? 'N/A',
      cargoCategory: json['cargo_category'] ?? 'N/A',
      weightKg: _toDouble(json['cargo_weight_kg']),
      quantity: _toInt(json['cargo_quantity']),
      estimatedFee: _toDouble(json['estimated_fee']),
      status: json['status'] ?? 'pending',
      cargoPhotoUrl: json['cargo_photo_url'],
    );
  }
}

// Represents a wallet transaction (top-up or trip expense)
class Transaction {
  final String date;
  final String label;
  final double amount; // negative = expense

  Transaction({
    required this.date,
    required this.label,
    required this.amount,
  });

  // Factory constructor to create a Transaction from a JSON object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      date: json['formatted_date'] ?? 'N/A',
      label: json['label'] ?? 'Unknown Transaction',
      amount: _toDouble(json['amount']),
    );
  }
}

// ============================================================
// DataStore: Centralized State Management (Singleton)
// Acts as a local backend for the app
// ============================================================
class DataStore {
  static final DataStore _instance = DataStore._internal();
  factory DataStore() => _instance;
  DataStore._internal();

  int? userId;
  // User Profile
  String merchantName = "Aling Nena's Stall";
  String marketLocation = 'Libertad Market, Aisle 8';
  String? profilePhotoUrl;
  bool isKycVerified = false;

  // Wallet & Financials
  double balance = 460.0;
  double totalSavings = 2840.0;
  List<Transaction> transactions = [];

  // Active Trip — stores both the booking and the truck used
  Booking? activeBooking;
  Truck? activeTruck;

  void setUserData(Map<String, dynamic> userData) {
    userId = userData['id'] as int?;
    merchantName = userData['merchant_name'] ?? 'N/A';
    marketLocation = userData['market_location'] ?? 'N/A';
    profilePhotoUrl = userData['profile_photo_url'] as String?;
    isKycVerified = (userData['is_kyc_verified'] == 1 || userData['is_kyc_verified'] == true);

    // Handle wallet_balance which may be a String or a number from JSON
    final dynamic balanceValue = userData['wallet_balance'];
    if (balanceValue is String) {
      balance = double.tryParse(balanceValue) ?? 0.0;
    } else if (balanceValue is num) {
      balance = balanceValue.toDouble();
    }
  }

  void addBooking(Booking booking, {Truck? truck}) {
    activeBooking = booking;
    activeTruck = truck;
    balance -= booking.estimatedFee;
    transactions.insert(0, Transaction(
      date: 'Today',
      label: 'Trip: ${booking.driverName}',
      amount: -booking.estimatedFee,
    ));
  }

  void completeBooking() {
    activeBooking = null;
    activeTruck = null;
  }

  /// Clears all user-specific data and resets the DataStore to its initial state.
  /// This is used during logout.
  void clearUserData() {
    userId = null;
    merchantName = "Aling Nena's Stall";
    marketLocation = 'Libertad Market, Aisle 8';
    profilePhotoUrl = null;
    isKycVerified = false;
    balance = 460.0;
    totalSavings = 2840.0;
    transactions = [];
    activeBooking = null;
    activeTruck = null;
  }
}
