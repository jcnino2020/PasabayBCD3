// ============================================================
// Driver Active Trip Screen
// Controls: Start Trip, Complete Trip
// Shows live booking info while in_transit
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      final response = await http.post(
        Uri.parse('$_baseUrl/driver_update_status.php'),
        body: {
          'payload': json.encode({
            'booking_id': _booking['id'].toString(),
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
                child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete trip.'), backgroundColor: Color(0xFFEF4444)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.'), backgroundColor: Color(0xFFEF4444)),
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
                      Text('Booking #${_booking['id']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Cargo Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
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
                  _InfoRow(label: 'Category', value: _booking['cargo_category'] ?? '-'),
                  _InfoRow(label: 'Weight', value: '${_booking['cargo_weight_kg'] ?? '-'} kg'),
                  _InfoRow(label: 'Qty', value: '${_booking['cargo_quantity'] ?? '-'} pcs'),
                  _InfoRow(label: 'Fee', value: '₱${_booking['estimated_fee'] ?? '-'}'),
                  _InfoRow(label: 'Customer', value: _booking['full_name'] ?? _booking['merchant_name'] ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 40),

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
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
