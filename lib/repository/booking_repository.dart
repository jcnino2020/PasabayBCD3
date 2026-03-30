// ============================================================
// Repository: Bookings
// CRUD operations on the "bookings" table.
// Works with the existing Booking model from models/booking.dart.
// ============================================================

import '../database/db_helper.dart';

class BookingRepository {
  final DbHelper _db = DbHelper();
  static const String _table = 'bookings';

  /// Insert a booking from API JSON data. Returns the row id.
  Future<int> insertBooking(Map<String, dynamic> apiJson) async {
    final now = DateTime.now().toIso8601String();
    return await _db.insert(_table, {
      'server_id': apiJson['id']?.toString(),
      'truck_id': apiJson['truck_id']?.toString(),
      'driver_name': apiJson['driver_name'] ?? 'N/A',
      'cargo_category': apiJson['cargo_category'] ?? 'N/A',
      'cargo_weight_kg': _toDouble(apiJson['cargo_weight_kg']),
      'cargo_quantity': _toInt(apiJson['cargo_quantity']),
      'estimated_fee': _toDouble(apiJson['estimated_fee']),
      'status': apiJson['status'] ?? 'pending',
      'cargo_photo_url': apiJson['cargo_photo_url'],
      'created_at': apiJson['created_at'] ?? now,
      'updated_at': now,
      'is_synced': 1, // came from the server, so it is synced
    });
  }

  /// Insert a locally created booking (offline). Returns the row id.
  Future<int> insertLocalBooking({
    required String truckId,
    required String driverName,
    required String cargoCategory,
    required double weightKg,
    required int quantity,
    required double estimatedFee,
    String? cargoPhotoUrl,
  }) async {
    final now = DateTime.now().toIso8601String();
    return await _db.insert(_table, {
      'truck_id': truckId,
      'driver_name': driverName,
      'cargo_category': cargoCategory,
      'cargo_weight_kg': weightKg,
      'cargo_quantity': quantity,
      'estimated_fee': estimatedFee,
      'status': 'pending',
      'cargo_photo_url': cargoPhotoUrl,
      'created_at': now,
      'updated_at': now,
      'is_synced': 0, // created offline, needs sync later
    });
  }

  /// Get all bookings, newest first.
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    return await _db.query(_table, orderBy: 'created_at DESC');
  }

  /// Get bookings filtered by status.
  Future<List<Map<String, dynamic>>> getBookingsByStatus(String status) async {
    return await _db.query(
      _table,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
  }

  /// Get a single booking by its local id.
  Future<Map<String, dynamic>?> getBookingById(int id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Update booking status (e.g., pending -> in_transit -> delivered).
  Future<int> updateStatus(int id, String newStatus) async {
    return await _db.update(
      _table,
      {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a booking by local id.
  Future<int> deleteBooking(int id) async {
    return await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// Get bookings that have not been synced to the server.
  Future<List<Map<String, dynamic>>> getUnsyncedBookings() async {
    return await _db.query(
      _table,
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  /// Mark a booking as synced after successful API push.
  Future<int> markAsSynced(int id, {String? serverId}) async {
    final values = <String, dynamic>{
      'is_synced': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (serverId != null) {
      values['server_id'] = serverId;
    }
    return await _db.update(_table, values, where: 'id = ?', whereArgs: [id]);
  }

  /// Replace all bookings with fresh API data (full refresh).
  /// Useful after a successful sync or on first load.
  Future<void> replaceAll(List<Map<String, dynamic>> apiBookings) async {
    await _db.batch((batch) {
      batch.delete(_table);
      final now = DateTime.now().toIso8601String();
      for (final b in apiBookings) {
        batch.insert(_table, {
          'server_id': b['id']?.toString(),
          'truck_id': b['truck_id']?.toString(),
          'driver_name': b['driver_name'] ?? 'N/A',
          'cargo_category': b['cargo_category'] ?? 'N/A',
          'cargo_weight_kg': _toDouble(b['cargo_weight_kg']),
          'cargo_quantity': _toInt(b['cargo_quantity']),
          'estimated_fee': _toDouble(b['estimated_fee']),
          'status': b['status'] ?? 'pending',
          'cargo_photo_url': b['cargo_photo_url'],
          'created_at': b['created_at'] ?? now,
          'updated_at': now,
          'is_synced': 1,
        });
      }
    });
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
