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

  Booking({
    required this.id,
    required this.truckId,
    required this.driverName,
    required this.cargoCategory,
    required this.weightKg,
    required this.quantity,
    required this.estimatedFee,
    this.status = 'pending',
  });
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
    isKycVerified = (userData['is_kyc_verified'] == 1 || userData['is_kyc_verified'] == true);
    balance = (userData['wallet_balance'] as num?)?.toDouble() ?? 0.0;
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
}
