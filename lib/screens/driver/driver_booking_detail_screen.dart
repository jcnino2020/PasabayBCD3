// ============================================================
// Driver Booking Detail Screen
// Full booking info + status management
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriverBookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onStatusUpdate;
  const DriverBookingDetailScreen({super.key, required this.booking, this.onStatusUpdate});

  @override
  State<DriverBookingDetailScreen> createState() => _DriverBookingDetailScreenState();
}

class _DriverBookingDetailScreenState extends State<DriverBookingDetailScreen> {
  static const String _baseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api';
  bool _isUpdating = false;
  late Map<String, dynamic> _booking;

  @override
  void initState() {
    super.initState();
    _booking = Map<String, dynamic>.from(widget.booking);
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/driver_update_status.php'),
        body: {
          'payload': json.encode({
            'booking_id': _booking['id'].toString(),
            'status': status,
          }),
        },
      );
      if (response.statusCode == 200 && mounted) {
        setState(() => _booking['status'] = status);
        widget.onStatusUpdate?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking $status successfully.'), backgroundColor: const Color(0xFF10B981)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status.'), backgroundColor: Color(0xFFEF4444)),
        );
      }
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF10B981);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'in_transit': return const Color(0xFF1A56DB);
      case 'completed': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _booking['status'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Booking #${_booking['id']}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (status ?? '').replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            _Section(
              title: 'Customer',
              children: [
                _Row(label: 'Name', value: _booking['full_name'] ?? '-'),
                _Row(label: 'Business', value: _booking['merchant_name'] ?? '-'),
              ],
            ),
            const SizedBox(height: 20),

            _Section(
              title: 'Cargo',
              children: [
                _Row(label: 'Category', value: _booking['cargo_category'] ?? '-'),
                _Row(label: 'Weight', value: '${_booking['cargo_weight_kg'] ?? '-'} kg'),
                _Row(label: 'Quantity', value: '${_booking['cargo_quantity'] ?? '-'} pcs'),
                _Row(label: 'Est. Fee', value: '₱${_booking['estimated_fee'] ?? '-'}'),
              ],
            ),
            const SizedBox(height: 20),

            _Section(
              title: 'Schedule',
              children: [
                _Row(label: 'Booked', value: _booking['created_at'] ?? '-'),
                _Row(label: 'Completed', value: _booking['completed_at'] ?? 'Not yet'),
              ],
            ),
            const SizedBox(height: 36),

            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else if (status == 'pending') ...[
              _ActionButton(
                label: 'Accept Booking',
                color: const Color(0xFF10B981),
                onPressed: () => _updateStatus('confirmed'),
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Reject Booking',
                color: const Color(0xFFEF4444),
                onPressed: () => _updateStatus('cancelled'),
              ),
            ] else if (status == 'confirmed') ...[
              _ActionButton(
                label: 'Start Trip',
                color: const Color(0xFF1A56DB),
                onPressed: () => _updateStatus('in_transit'),
              ),
            ] else if (status == 'in_transit') ...[
              _ActionButton(
                label: 'Complete Trip',
                color: const Color(0xFF10B981),
                onPressed: () => _updateStatus('completed'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
