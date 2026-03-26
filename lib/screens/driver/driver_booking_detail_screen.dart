// ============================================================
// Driver Booking Detail Screen
// Full details: cargo info, addresses, merchant contact
// Actions: Accept, Reject, Start Trip
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_active_trip_screen.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final driverJson = prefs.getString('driverData');
      final driverData = driverJson != null ? json.decode(driverJson) : {};

      final response = await http.post(
        Uri.parse('$_baseUrl/driver_update_status.php'),
        body: {
          'payload': json.encode({
            'driver_id': driverData['driver_id'],
            'booking_id': _booking['booking_id'].toString(),
            'status': status,
          }),
        },
      );

      if (response.statusCode == 200) {
        setState(() => _booking['status'] = status);
        widget.onStatusUpdate?.call();

        if (status == 'in_transit' && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DriverActiveTripScreen(booking: _booking)),
          );
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to ${status.replaceAll('_', ' ')}'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    final status = _booking['status'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Booking #${_booking['booking_id']}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            _StatusBadge(status: status),
            const SizedBox(height: 24),

            // Addresses
            _SectionTitle('Route'),
            _DetailCard(children: [
              _DetailRow(label: 'Pickup', value: _booking['pickup_address'] ?? '-', icon: Icons.circle_outlined),
              const Divider(height: 20),
              _DetailRow(label: 'Delivery', value: _booking['delivery_address'] ?? '-', icon: Icons.location_on_outlined),
            ]),
            const SizedBox(height: 20),

            // Cargo info
            _SectionTitle('Cargo Details'),
            _DetailCard(children: [
              _DetailRow(label: 'Type', value: _booking['cargo_type'] ?? '-'),
              _DetailRow(label: 'Weight', value: '${_booking['weight'] ?? '-'} kg'),
              _DetailRow(label: 'Volume', value: '${_booking['volume'] ?? '-'} m\u00b3'),
              _DetailRow(label: 'Notes', value: _booking['notes'] ?? 'None'),
            ]),
            const SizedBox(height: 20),

            // Schedule
            _SectionTitle('Schedule'),
            _DetailCard(children: [
              _DetailRow(label: 'Pickup Date', value: _booking['pickup_date'] ?? '-'),
              _DetailRow(label: 'Pickup Time', value: _booking['pickup_time'] ?? '-'),
            ]),
            const SizedBox(height: 32),

            // Action buttons
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else ...
            [
              if (status == 'pending') ...
              [
                _ActionButton(
                  label: 'Accept Booking',
                  color: const Color(0xFF10B981),
                  onPressed: () => _updateStatus('accepted'),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Reject Booking',
                  color: const Color(0xFFEF4444),
                  outline: true,
                  onPressed: () => _updateStatus('rejected'),
                ),
              ],
              if (status == 'accepted')
                _ActionButton(
                  label: 'Start Trip',
                  color: const Color(0xFF1A56DB),
                  onPressed: () => _updateStatus('in_transit'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  Color get _color {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        (status ?? 'unknown').replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  const _DetailRow({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 6)],
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool outline;
  const _ActionButton({required this.label, required this.color, required this.onPressed, this.outline = false});

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );
    }
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
