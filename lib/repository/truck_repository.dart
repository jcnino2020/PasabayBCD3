// ============================================================
// Repository: Trucks
// CRUD operations on the "trucks" table.
// Used for caching truck data fetched from the API so the
// trip matching screen can load instantly on app start.
// ============================================================

import '../database/db_helper.dart';

class TruckRepository {
  final DbHelper _db = DbHelper();
  static const String _table = 'trucks';

  /// Cache a single truck from API JSON. Returns the row id.
  Future<int> insertTruck(Map<String, dynamic> apiJson) async {
    final now = DateTime.now().toIso8601String();
    return await _db.insert(_table, {
      'server_id': apiJson['id']?.toString(),
      'driver_id': _toInt(apiJson['driver_id']),
      'type': apiJson['type'] ?? 'N/A',
      'driver_name': apiJson['driver_name'] ?? 'Unknown Driver',
      'rating': _toDouble(apiJson['rating']),
      'plate_number': apiJson['plate_number'] ?? 'N/A',
      'current_route': apiJson['current_route'] ?? 'No route',
      'depart_time': apiJson['depart_time'] ?? 'N/A',
      'base_price': _toDouble(apiJson['base_price']),
      'capacity_kg': _toDouble(apiJson['capacity_kg']),
      'capacity_cbm': _toDouble(apiJson['capacity_cbm']),
      'profile_photo_url': apiJson['profile_photo_url'],
      'created_at': now,
      'updated_at': now,
      'is_synced': 1,
    });
  }

  /// Get all cached trucks, optionally filtered.
  Future<List<Map<String, dynamic>>> getAllTrucks({
    String? vehicleType,
    String? location,
    String orderBy = 'rating DESC',
  }) async {
    String? where;
    List<Object?>? whereArgs;

    if (vehicleType != null && vehicleType != 'All') {
      where = 'type = ?';
      whereArgs = [vehicleType];
    }

    return await _db.query(
      _table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  /// Get a single truck by local id.
  Future<Map<String, dynamic>?> getTruckById(int id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Replace all cached trucks with fresh API data.
  /// Call this after a successful network fetch.
  Future<void> replaceAll(List<Map<String, dynamic>> apiTrucks) async {
    await _db.batch((batch) {
      batch.delete(_table);
      final now = DateTime.now().toIso8601String();
      for (final t in apiTrucks) {
        batch.insert(_table, {
          'server_id': t['id']?.toString(),
          'driver_id': _toInt(t['driver_id']),
          'type': t['type'] ?? 'N/A',
          'driver_name': t['driver_name'] ?? 'Unknown Driver',
          'rating': _toDouble(t['rating']),
          'plate_number': t['plate_number'] ?? 'N/A',
          'current_route': t['current_route'] ?? 'No route',
          'depart_time': t['depart_time'] ?? 'N/A',
          'base_price': _toDouble(t['base_price']),
          'capacity_kg': _toDouble(t['capacity_kg']),
          'capacity_cbm': _toDouble(t['capacity_cbm']),
          'profile_photo_url': t['profile_photo_url'],
          'created_at': now,
          'updated_at': now,
          'is_synced': 1,
        });
      }
    });
  }

  /// Delete all cached trucks.
  Future<int> deleteAll() async {
    return await _db.delete(_table);
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
