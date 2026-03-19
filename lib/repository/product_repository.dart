import 'dart:async';
import 'dart:convert';
import '../models/product.dart';
import '../database/db_helper.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  final DBHelper _dbHelper = DBHelper();
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initialize the repository and start listening for connectivity changes
  void init() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected) {
          syncAll();
        }
      },
    );
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  // ─── Product Operations ───────────────────────────────────────

  /// Get all products (local-first, then sync from API in background)
  Future<List<Product>> getProducts() async {
    return await _dbHelper.getProducts();
  }

  /// Add a product - saves locally first, then queues for sync
  Future<Product> addProduct({
    required String name,
    required double price,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      updatedAt: now,
      isSynced: false,
      version: 1,
    );

    await _dbHelper.insertProduct(product);

    // Queue for sync
    await _dbHelper.addToSyncQueue(
      operation: 'INSERT',
      tableName: 'products',
      recordId: product.id,
      data: json.encode(product.toJson()),
    );

    // Try immediate sync if online
    _trySyncInBackground();

    return product;
  }

  /// Update a product - saves locally first, then queues for sync
  Future<Product> updateProduct(Product product) async {
    final updated = product.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
      version: product.version + 1,
    );

    await _dbHelper.updateProduct(updated);

    // Queue for sync
    await _dbHelper.addToSyncQueue(
      operation: 'UPDATE',
      tableName: 'products',
      recordId: updated.id,
      data: json.encode(updated.toJson()),
    );

    _trySyncInBackground();

    return updated;
  }

  /// Delete a product - removes locally, then queues deletion for sync
  Future<void> deleteProduct(String id) async {
    await _dbHelper.deleteProduct(id);

    // Queue for sync
    await _dbHelper.addToSyncQueue(
      operation: 'DELETE',
      tableName: 'products',
      recordId: id,
    );

    _trySyncInBackground();
  }

  // ─── Sync Operations ─────────────────────────────────────────

  /// Sync all pending changes and pull latest from server
  Future<SyncResult> syncAll() async {
    if (_isSyncing) return SyncResult(pushed: 0, pulled: 0, conflicts: 0);
    _isSyncing = true;

    int pushed = 0;
    int pulled = 0;
    int conflicts = 0;

    try {
      final isOnline = await _connectivity.isConnected;
      if (!isOnline) {
        return SyncResult(pushed: 0, pulled: 0, conflicts: 0);
      }

      // Step 1: Push local changes (process sync queue)
      final queue = await _dbHelper.getSyncQueue();
      for (final item in queue) {
        final success = await _processSyncItem(item);
        if (success) {
          await _dbHelper.removeSyncQueueItem(item['id'] as int);
          pushed++;
        }
      }

      // Step 2: Pull latest from server and merge
      final serverProducts = await _apiService.getProducts();
      for (final serverProduct in serverProducts) {
        final localProduct = await _dbHelper.getProductById(serverProduct.id);

        if (localProduct == null) {
          // New from server - insert locally
          await _dbHelper.insertProduct(serverProduct);
          pulled++;
        } else if (localProduct.isSynced) {
          // Local is synced - server version is authoritative
          if (serverProduct.version > localProduct.version ||
              serverProduct.updatedAt.isAfter(localProduct.updatedAt)) {
            await _dbHelper.updateProduct(serverProduct);
            pulled++;
          }
        } else {
          // Conflict: local has unsynced changes AND server has changes
          final resolved = _resolveConflict(localProduct, serverProduct);
          await _dbHelper.updateProduct(resolved);
          conflicts++;
        }
      }
    } finally {
      _isSyncing = false;
    }

    return SyncResult(pushed: pushed, pulled: pulled, conflicts: conflicts);
  }

  /// Process a single sync queue item
  Future<bool> _processSyncItem(Map<String, dynamic> item) async {
    final operation = item['operation'] as String;
    final recordId = item['recordId'] as String;
    final data = item['data'] as String?;

    switch (operation) {
      case 'INSERT':
        if (data != null) {
          final product = Product.fromJson(json.decode(data));
          final result = await _apiService.addProduct(product);
          if (result != null) {
            await _dbHelper.markProductSynced(recordId);
            return true;
          }
        }
        return false;

      case 'UPDATE':
        if (data != null) {
          final product = Product.fromJson(json.decode(data));
          final result = await _apiService.updateProduct(product);
          if (result != null) {
            await _dbHelper.markProductSynced(recordId);
            return true;
          }
        }
        return false;

      case 'DELETE':
        final result = await _apiService.deleteProduct(recordId);
        return result;

      default:
        return false;
    }
  }

  /// Resolve conflict between local and server versions.
  /// Strategy: Higher version wins. If same version, most recent updatedAt wins.
  /// This prevents silent overwrites.
  Product _resolveConflict(Product local, Product server) {
    if (server.version > local.version) {
      // Server has a newer version - server wins
      return server;
    } else if (local.version > server.version) {
      // Local has a newer version - local wins (keep unsynced)
      return local;
    } else {
      // Same version - last write wins based on timestamp
      if (server.updatedAt.isAfter(local.updatedAt)) {
        return server;
      } else {
        return local;
      }
    }
  }

  /// Try to sync in background without blocking the caller
  void _trySyncInBackground() async {
    final isOnline = await _connectivity.isConnected;
    if (isOnline) {
      syncAll();
    }
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    return await _dbHelper.getSyncQueueCount();
  }
}

/// Result of a sync operation
class SyncResult {
  final int pushed;
  final int pulled;
  final int conflicts;

  SyncResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
  });

  int get total => pushed + pulled + conflicts;
  bool get hasChanges => total > 0;
}
