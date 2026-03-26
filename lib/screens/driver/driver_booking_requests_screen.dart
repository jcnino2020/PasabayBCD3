// ============================================================
// Driver Booking Requests Screen
// Lists all pending bookings for the driver's truck
// Accept / Reject inline
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_booking_detail_screen.dart';

class DriverBookingRequestsScreen extends StatefulWidget {
  const DriverBookingRequestsScreen({super.key});

  @override
  State<DriverBookingRequestsScreen> createState() => _DriverBookingRequestsScreenState();
}

class _DriverBookingRequestsScreenState extends State<DriverBookingRequestsScreen> {
  static const String _baseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api';

  Map<String, dynamic>? _driverData;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final driverJson = prefs.getString('driverData');
    if (driverJson != null) _driverData = json.decode(driverJson);
    await _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (_driverData == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/driver_bookings.php'),
        body: {
          'payload': json.encode({'driver_id': _driverData!['driver_id']}),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _bookings = data['bookings'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/driver_update_status.php'),
        body: {
          'payload': json.encode({
            'driver_id': _driverData!['driver_id'],
            'booking_id': bookingId,
            'status': status,
          }),
        },
      );
      await _fetchBookings();
    } catch (_) {}
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'accepted': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      case 'in_transit': return const Color(0xFF1A56DB);
      case 'completed': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Booking Requests', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _fetchBookings)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final b = _bookings[index] as Map<String, dynamic>;
                      final status = b['status'] as String?;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DriverBookingDetailScreen(booking: b, onStatusUpdate: _fetchBookings)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Booking #${b['booking_id']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      (status ?? '').replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _AddressRow(icon: Icons.circle_outlined, label: b['pickup_address'] ?? '-'),
                              const SizedBox(height: 4),
                              _AddressRow(icon: Icons.location_on_outlined, label: b['delivery_address'] ?? '-'),
                              if (status == 'pending') ...
                              [
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(b['booking_id'].toString(), 'rejected'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFFEF4444),
                                          side: const BorderSide(color: Color(0xFFEF4444)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateStatus(b['booking_id'].toString(), 'accepted'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AddressRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
      ],
    );
  }
}
