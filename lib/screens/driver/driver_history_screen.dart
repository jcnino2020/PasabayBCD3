// ============================================================
// Driver History Screen
// Lists completed and rejected bookings
// Calls: POST /api/driver_history.php
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  static const String _baseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api';
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverJson = prefs.getString('driverData');
      if (driverJson == null) return;
      final driverData = json.decode(driverJson);

      final response = await http.post(
        Uri.parse('$_baseUrl/driver_history.php'),
        body: {
          'payload': json.encode({'driver_id': driverData['driver_id']}),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _history = data['history'] ?? data['bookings'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'completed': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'completed': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip History', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _fetchHistory)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No trip history yet.', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final b = _history[index] as Map<String, dynamic>;
                      final status = b['status'] as String?;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_statusIcon(status), color: _statusColor(status), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Booking #${b['booking_id']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  const SizedBox(height: 3),
                                  Text(b['pickup_address'] ?? '-', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(b['delivery_address'] ?? '-', style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    (status ?? '').toUpperCase(),
                                    style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (b['created_at'] != null) ...
                                [
                                  const SizedBox(height: 4),
                                  Text(b['created_at'].toString().substring(0, 10), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
