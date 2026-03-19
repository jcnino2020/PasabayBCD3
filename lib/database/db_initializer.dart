// ============================================================
// Database Initializer
// Call once during app startup to make sure the database is
// created and ready before any screen tries to use it.
// ============================================================

import 'package:flutter/foundation.dart';
import 'db_helper.dart';

class DbInitializer {
  /// Initialize the database. Safe to call multiple times --
  /// subsequent calls return the existing instance.
  static Future<void> initialize() async {
    try {
      // This triggers openDatabase which runs onCreate / onUpgrade
      await DbHelper().database;
      debugPrint('DbInitializer: Database ready.');
    } catch (e) {
      debugPrint('DbInitializer: Failed to initialize database: $e');
      rethrow;
    }
  }
}
