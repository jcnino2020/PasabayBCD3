// ============================================================
// Service: Sync Service (Placeholder)
// Handles pushing unsynced local data to the API and pulling
// fresh server data into the local database.
//
// STATUS: Scaffold only -- wire up actual API calls later.
// ============================================================

import 'package:flutter/foundation.dart';
import '../repository/booking_repository.dart';
import '../repository/item_repository.dart';

class SyncService {
  final BookingRepository _bookingRepo = BookingRepository();
  final ItemRepository _itemRepo = ItemRepository();

  /// Run a full sync cycle:
  /// 1. Push unsynced local data to server
  /// 2. Pull latest server data into local DB
  ///
  /// Returns true if sync completed without errors.
  Future<bool> syncAll() async {
    try {
      await pushUnsyncedBookings();
      await pushUnsyncedItems();
      // await pullBookingsFromServer();
      // await pullTrucksFromServer();
      return true;
    } catch (e) {
      debugPrint('SyncService.syncAll() error: $e');
      return false;
    }
  }

  /// Push any bookings created or modified offline to the server.
  Future<void> pushUnsyncedBookings() async {
    final unsynced = await _bookingRepo.getUnsyncedBookings();
    if (unsynced.isEmpty) return;

    for (final booking in unsynced) {
      try {
        // TODO: POST booking to API
        // final response = await http.post(
        //   Uri.parse('$apiBaseUrl/bookings.php'),
        //   body: json.encode(booking),
        // );
        // if (response.statusCode == 200) {
        //   final serverData = json.decode(response.body);
        //   await _bookingRepo.markAsSynced(
        //     booking['id'] as int,
        //     serverId: serverData['id']?.toString(),
        //   );
        // }

        debugPrint(
          'SyncService: Would push booking id=${booking['id']} to server',
        );
      } catch (e) {
        debugPrint('SyncService: Failed to push booking id=${booking['id']}: $e');
      }
    }
  }

  /// Push any generic items created offline to the server.
  Future<void> pushUnsyncedItems() async {
    final unsynced = await _itemRepo.getUnsyncedItems();
    if (unsynced.isEmpty) return;

    for (final item in unsynced) {
      try {
        // TODO: POST item to API
        debugPrint(
          'SyncService: Would push item id=${item['id']} to server',
        );
      } catch (e) {
        debugPrint('SyncService: Failed to push item id=${item['id']}: $e');
      }
    }
  }

  // ------------------------------------------------------------------
  // Pull methods (implement when API endpoints are ready)
  // ------------------------------------------------------------------

  // Future<void> pullBookingsFromServer() async {
  //   final userId = DataStore().userId ?? 0;
  //   final response = await http.get(
  //     Uri.parse('$apiBaseUrl/booking_history.php?user_id=$userId'),
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     await _bookingRepo.replaceAll(data.cast<Map<String, dynamic>>());
  //   }
  // }

  // Future<void> pullTrucksFromServer() async {
  //   final response = await http.get(Uri.parse('$apiBaseUrl/trucks.php'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     await _truckRepo.replaceAll(data.cast<Map<String, dynamic>>());
  //   }
  // }
}
