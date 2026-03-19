// ============================================================
// Repository: User Profile
// CRUD operations on the "user_profile" table.
// Caches the logged-in user's profile data locally so the
// app can load it instantly without a network call.
// ============================================================

import '../database/db_helper.dart';

class UserRepository {
  final DbHelper _db = DbHelper();
  static const String _table = 'user_profile';

  /// Save or update the local user profile from API data.
  /// Uses a single-row pattern (deletes existing, inserts fresh).
  Future<int> saveProfile(Map<String, dynamic> userData) async {
    final now = DateTime.now().toIso8601String();

    // Clear any existing profile row first
    await _db.delete(_table);

    return await _db.insert(_table, {
      'server_id': _toInt(userData['id']),
      'merchant_name': userData['merchant_name'] ?? 'N/A',
      'market_location': userData['market_location'] ?? 'N/A',
      'profile_photo_url': userData['profile_photo_url'],
      'is_kyc_verified': (userData['is_kyc_verified'] == 1 ||
              userData['is_kyc_verified'] == true)
          ? 1
          : 0,
      'wallet_balance': _toDouble(userData['wallet_balance']),
      'updated_at': now,
      'is_synced': 1,
    });
  }

  /// Get the locally cached user profile (single row).
  Future<Map<String, dynamic>?> getProfile() async {
    final rows = await _db.query(_table, limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  /// Update specific profile fields locally.
  Future<int> updateProfile(Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    updates['is_synced'] = 0;
    return await _db.update(_table, updates);
  }

  /// Update wallet balance after a transaction.
  Future<int> updateBalance(double newBalance) async {
    return await _db.update(_table, {
      'wallet_balance': newBalance,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  /// Clear the local user profile (used on logout).
  Future<int> clearProfile() async {
    return await _db.delete(_table);
  }

  /// Check if a user profile exists in the local database.
  Future<bool> hasProfile() async {
    final rows = await _db.query(_table, limit: 1);
    return rows.isNotEmpty;
  }

  // -- private helpers ------------------------------------------------

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
