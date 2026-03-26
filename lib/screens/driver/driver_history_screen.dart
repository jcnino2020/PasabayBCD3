// ============================================================
// Driver History Screen
// Shows completed trips
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

  Map<String, dynamic>? _userData;
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      setState(() => _userData = json.decode(userJson));
    } else {
      setState(() => _isLoading = false);
      return;
    }
    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (_userData == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final driverId = _userData!['id'];
      final response = await http.get(
        Uri.parse('$_baseUrl/driver_history.php?driver_id=$driverId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _history = data is List ? data : []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No completed trips yet.', style: TextStyle(color: Colors.grey, fontSize: 15)),
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
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Booking #${b['id']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B7280).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('COMPLETED', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(b['full_name'] ?? b['merchant_name'] ?? 'Unknown Customer',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('${b['cargo_category'] ?? '-'} · ${b['cargo_weight_kg'] ?? '-'} kg',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('₱${b['estimated_fee'] ?? '-'}',
                                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
