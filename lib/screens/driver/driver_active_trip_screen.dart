// ============================================================
// Driver Active Trip Screen
// Controls: Start Trip, Complete Trip
// Shows live booking info while in_transit
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_main_screen.dart';

class DriverActiveTripScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  const DriverActiveTripScreen({super.key, required this.booking});

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  static const String _baseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api';
  bool _isUpdating = false;
  late Map<String, dynamic> _booking;

  @override
  void initState() {
    super.initState();
    _booking = Map<String, dynamic>.from(widget.booking);
  }

  Future<void> _completeTrip() async {
    setState(() => _isUpdating = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverJson = prefs.getString('driverData');
      final driverData = driverJson != null ? json.decode(driverJson) : {};

      final response = await http.post(
        Uri.parse('$_baseUrl/driver_update_status.php'),
        body: {
          'payload': json.encode({
            'driver_id': driverData['driver_id'],
            'booking_id': _booking['booking_id'].toString(),
            'status': 'completed',
          }),
        },
      );

      if (response.statusCode == 200 && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Trip Completed!', style: TextStyle(fontWeight: FontWeight.w800)),
            content: const Text('Great job! The delivery has been marked as completed.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DriverMainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56DB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete trip.'), backgroundColor: Color(0xFFEF4444)),
        );
      }
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Active Trip', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        surfaceTintColor: const Color(0xFF1A56DB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1A56DB).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: Color(0xFF1A56DB), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('In Transit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A56DB))),
                      Text('Booking #${_booking['booking_id']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Route
            const Text('Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 12),
            _RouteCard(
              pickup: _booking['pickup_address'] ?? '-',
              delivery: _booking['delivery_address'] ?? '-',
            ),
            const SizedBox(height: 24),

            // Cargo summary
            const Text('Cargo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Type', value: _booking['cargo_type'] ?? '-'),
                  _InfoRow(label: 'Weight', value: '${_booking['weight'] ?? '-'} kg'),
                  _InfoRow(label: 'Notes', value: _booking['notes'] ?? 'None'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Complete trip button
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _completeTrip,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Completed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String pickup;
  final String delivery;
  const _RouteCard({required this.pickup, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle_outlined, size: 14, color: Color(0xFF1A56DB)),
              const SizedBox(width: 10),
              Expanded(child: Text(pickup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: List.generate(3, (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.more_vert, size: 10, color: Colors.grey)),
              )),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              Expanded(child: Text(delivery, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
