// ============================================================
// Database Helper (Singleton)
// Central manager for SQLite database operations.
// Uses sqflite + path_provider for local offline storage.
// Supports versioned schema with onCreate / onUpgrade.
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  // Singleton pattern -- one DB instance across the entire app
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  // Database configuration
  static const String _dbName = 'pasabaybcd.db';
  static const int _dbVersion = 1;

  /// Returns the database instance, initializing it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Opens (or creates) the database file.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // Schema: Version 1 (initial)
  // ============================================================

  /// Called only when the database file does not yet exist.
  /// Runs every migration from version 1 up to [version].
  Future<void> _onCreate(Database db, int version) async {
    for (int v = 1; v <= version; v++) {
      await _applyMigration(db, v);
    }
  }

  /// Called when the stored version is lower than [newVersion].
  /// Runs each migration step between old and new.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      await _applyMigration(db, v);
    }
  }

  /// Central migration router.
  /// Add a new case here each time you bump [_dbVersion].
  Future<void> _applyMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _migrateV1(db);
        break;
      // case 2:
      //   await _migrateV2(db);
      //   break;
      default:
        break;
    }
  }

  // ----------------------------------------------------------
  // Version 1 tables
  // ----------------------------------------------------------

  Future<void> _migrateV1(Database db) async {
    // Generic items table for flexible local storage
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT    NOT NULL DEFAULT 'items',
        data       TEXT    NOT NULL,
        created_at TEXT    NOT NULL,
        updated_at TEXT    NOT NULL,
        is_synced  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Bookings table -- mirrors the API booking data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id      TEXT,
        truck_id       TEXT,
        driver_name    TEXT,
        cargo_category TEXT,
        cargo_weight_kg REAL    DEFAULT 0,
        cargo_quantity  INTEGER DEFAULT 0,
        estimated_fee   REAL    DEFAULT 0,
        status         TEXT    DEFAULT 'pending',
        cargo_photo_url TEXT,
        created_at     TEXT    NOT NULL,
        updated_at     TEXT    NOT NULL,
        is_synced      INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Trucks table -- cache of available trucks from the API
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trucks (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id        TEXT,
        driver_id        INTEGER DEFAULT 0,
        type             TEXT,
        driver_name      TEXT,
        rating           REAL    DEFAULT 0,
        plate_number     TEXT,
        current_route    TEXT,
        depart_time      TEXT,
        base_price       REAL    DEFAULT 0,
        capacity_kg      REAL    DEFAULT 0,
        capacity_cbm     REAL    DEFAULT 0,
        profile_photo_url TEXT,
        created_at       TEXT    NOT NULL,
        updated_at       TEXT    NOT NULL,
        is_synced        INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // User profile cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id       INTEGER,
        merchant_name   TEXT,
        market_location TEXT,
        profile_photo_url TEXT,
        is_kyc_verified INTEGER DEFAULT 0,
        wallet_balance  REAL    DEFAULT 0,
        updated_at      TEXT    NOT NULL,
        is_synced       INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Indexes for faster queries
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_table_name ON items(table_name)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_is_synced ON items(is_synced)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookings_is_synced ON bookings(is_synced)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_trucks_type ON trucks(type)');
  }

  // ============================================================
  // Low-level helpers (used by repository layer)
  // ============================================================

  /// Insert a row and return the auto-generated id.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update rows matching [where] and return the count of affected rows.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Delete rows matching [where] and return the count of deleted rows.
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Query rows from [table].
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Run a raw SQL query. Use sparingly.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute a batch of operations inside a single transaction.
  Future<void> batch(void Function(Batch batch) actions) async {
    final db = await database;
    final b = db.batch();
    actions(b);
    await b.commit(noResult: true);
  }

  /// Close the database. Call during app shutdown if needed.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
