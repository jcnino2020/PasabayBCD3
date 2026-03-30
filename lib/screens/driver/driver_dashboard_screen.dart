// ============================================================
// Driver Dashboard Screen
// Shows active/pending booking summary and quick actions
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_booking_requests_screen.dart';
import 'driver_active_trip_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  static const String _baseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api';

  Map<String, dynamic>? _userData;
  List<dynamic> _pendingBookings = [];
  Map<String, dynamic>? _activeBooking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      setState(() => _userData = json.decode(userJson));
    } else {
      setState(() => _isLoading = false);
      return;
    }
    await _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (_userData == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final driverId = _userData!['id'];
      final response = await http.get(
        Uri.parse('$_baseUrl/driver_bookings.php?driver_id=$driverId'),
      );
      if (response.statusCode == 200) {
        final bookings = (json.decode(response.body) as List).cast<Map<String, dynamic>>();
        setState(() {
          _pendingBookings = bookings.where((b) => b['status'] == 'pending').toList();
          final active = bookings.where((b) =>
              b['status'] == 'confirmed' || b['status'] == 'in_transit').toList();
          _activeBooking = active.isNotEmpty ? active.first : null;
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final driverName = _userData?['full_name'] ?? _userData?['name'] ?? 'Driver';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Hi, $driverName!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here\'s your overview for today.',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    // Summary cards
                    Row(
                      children: [
                        _StatCard(
                          label: 'Pending',
                          value: '${_pendingBookings.length}',
                          icon: Icons.pending_actions_outlined,
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Active Trip',
                          value: _activeBooking != null ? '1' : '0',
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Active trip card
                    if (_activeBooking != null) ...[
                      const Text('Active Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                      const SizedBox(height: 12),
                      _ActiveTripCard(
                        booking: _activeBooking!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DriverActiveTripScreen(booking: _activeBooking!)),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Pending requests
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                        if (_pendingBookings.isNotEmpty)
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DriverBookingRequestsScreen()),
                            ),
                            child: const Text('See All', style: TextStyle(color: Color(0xFF1A56DB))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_pendingBookings.isEmpty)
                      const _EmptyState(message: 'No pending booking requests.')
                    else
                      ..._pendingBookings.take(3).map((b) => _PendingBookingTile(booking: b)),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 13, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;
  const _ActiveTripCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A56DB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Booking #${booking['id'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    (booking['status'] ?? '').toString().replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking['pickup_address'] ?? 'Pickup address', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const Icon(Icons.arrow_downward, color: Colors.white54, size: 16),
            Text(booking['delivery_address'] ?? 'Delivery address', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Tap to manage trip >', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _PendingBookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _PendingBookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking #${booking['id'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(booking['cargo_category'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
