// ============================================================
// Repository: Generic Items
// CRUD operations on the generic "items" table.
// Each item stores arbitrary JSON in its `data` column,
// tagged by `table_name` for flexible grouping.
// ============================================================

import 'dart:convert';
import '../database/db_helper.dart';

class ItemRepository {
  final DbHelper _db = DbHelper();
  static const String _table = 'items';

  /// Insert a new item. Returns the auto-generated row id.
  ///
  /// [data] is a Map that gets JSON-encoded into the `data` column.
  /// [tableName] is an optional logical tag (default: 'items').
  Future<int> insertItem(
    Map<String, dynamic> data, {
    String tableName = 'items',
  }) async {
    final now = DateTime.now().toIso8601String();
    return await _db.insert(_table, {
      'table_name': tableName,
      'data': json.encode(data),
      'created_at': now,
      'updated_at': now,
      'is_synced': 0,
    });
  }

  /// Update an existing item by [id].
  /// Merges [data] into the `data` column (full replace).
  Future<int> updateItem(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    return await _db.update(
      _table,
      {
        'data': json.encode(data),
        'updated_at': now,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard-delete an item by [id].
  Future<int> deleteItem(int id) async {
    return await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// Get all items, optionally filtered by [tableName].
  /// Returns a list of maps with `id`, `table_name`, decoded `data`,
  /// `created_at`, `updated_at`, and `is_synced`.
  Future<List<Map<String, dynamic>>> getItems({
    String? tableName,
    String orderBy = 'updated_at DESC',
  }) async {
    final rows = await _db.query(
      _table,
      where: tableName != null ? 'table_name = ?' : null,
      whereArgs: tableName != null ? [tableName] : null,
      orderBy: orderBy,
    );

    return rows.map((row) {
      return {
        'id': row['id'],
        'table_name': row['table_name'],
        'data': json.decode(row['data'] as String),
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
        'is_synced': row['is_synced'],
      };
    }).toList();
  }

  /// Get a single item by [id].
  Future<Map<String, dynamic>?> getItemById(int id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    return {
      'id': row['id'],
      'table_name': row['table_name'],
      'data': json.decode(row['data'] as String),
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
      'is_synced': row['is_synced'],
    };
  }

  /// Get items that have not been synced yet (is_synced == 0).
  Future<List<Map<String, dynamic>>> getUnsyncedItems() async {
    final rows = await _db.query(
      _table,
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'updated_at ASC',
    );

    return rows.map((row) {
      return {
        'id': row['id'],
        'table_name': row['table_name'],
        'data': json.decode(row['data'] as String),
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
        'is_synced': row['is_synced'],
      };
    }).toList();
  }

  /// Mark an item as synced.
  Future<int> markAsSynced(int id) async {
    return await _db.update(
      _table,
      {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark multiple items as synced in a single batch.
  Future<void> markMultipleAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final now = DateTime.now().toIso8601String();
    await _db.batch((batch) {
      for (final id in ids) {
        batch.update(
          _table,
          {'is_synced': 1, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }
}
