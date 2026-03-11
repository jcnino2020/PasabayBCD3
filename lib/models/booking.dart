// ============================================================
// Model: Booking
// Represents a cargo booking made by a merchant
// ============================================================

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
      weightKg: (json['cargo_weight_kg'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['cargo_quantity'] as num?)?.toInt() ?? 0,
      estimatedFee: (json['estimated_fee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      cargoPhotoUrl: json['cargo_photo_url'],
    );
  }
}

// Sample past transactions for the savings dashboard
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
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

List<Transaction> sampleTransactions = [
  Transaction(date: 'Jan 14', label: 'Libertad Trip', amount: -150),
  Transaction(date: 'Jan 12', label: 'Burgos Trip', amount: -80),
  Transaction(date: 'Jan 10', label: 'Central Market Trip', amount: -120),
  Transaction(date: 'Jan 8', label: 'Tangub Trip', amount: -95),
];

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
  List<Transaction> transactions = List.from(sampleTransactions);

  // Active Trip
  Booking? activeBooking;

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

  void addBooking(Booking booking) {
    activeBooking = booking;
    balance -= booking.estimatedFee;
    transactions.insert(0, Transaction(
      date: 'Today',
      label: 'Trip: ${booking.driverName}',
      amount: -booking.estimatedFee,
    ));
  }

  void completeBooking() {
    activeBooking = null;
  }

  /// Clears all user-specific data and resets the DataStore to its initial state.
  /// This is used during logout.
  void clearUserData() {
    userId = null;
    merchantName = "Aling Nena's Stall"; // Reset to default
    marketLocation = 'Libertad Market, Aisle 8'; // Reset to default
    profilePhotoUrl = null;
    isKycVerified = false;
    balance = 460.0; // Reset to default
    totalSavings = 2840.0; // Reset to default
    transactions = List.from(sampleTransactions);
    activeBooking = null;
  }
}
