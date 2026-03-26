// ============================================================
// Screen 07: Driver Confirmation (Algorithm Matching)
// Shows a waiting state while the driver reviews the cargo photo.
// On success, navigates to Booking Confirmation screen.
// ============================================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/truck.dart';
import 'booking_confirmation_screen.dart';
import 'trip_matching_screen.dart';

class DriverConfirmationScreen extends StatefulWidget {
  final Truck truck;
  final Booking booking;

  const DriverConfirmationScreen({
    super.key,
    required this.truck,
    required this.booking,
  });

  @override
  State<DriverConfirmationScreen> createState() => _DriverConfirmationScreenState();
}

class _DriverConfirmationScreenState extends State<DriverConfirmationScreen> {
  Timer? _pollingTimer;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    // Poll every 5 seconds to check if the driver confirmed
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
    // Also check immediately
    _checkStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final uri = Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/bookings.php')
          .replace(queryParameters: {'booking_id': widget.booking.id.toString()});
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String?;

        if (status == 'confirmed') {
          _pollingTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BookingConfirmationScreen(
                booking: widget.booking,
                truck: widget.truck,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Status check error: $e');
    }
  }

  Future<void> _cancelRequest() async {
    setState(() => _isCancelling = true);
    _pollingTimer?.cancel();

    try {
      await http.post(
        Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/bookings.php'),
        body: {'payload': json.encode({'booking_id': widget.booking.id, 'action': 'cancel'})},
      );
    } catch (e) {
      debugPrint('Cancel error: $e');
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TripMatchingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing search icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF2FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.search, color: Color(0xFF1A56DB), size: 50),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Confirming with Driver...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.truck.driverName} is reviewing your cargo photo to ensure it fits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 32),
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFFEBF2FF),
                  color: Color(0xFF1A56DB),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: _isCancelling ? null : _cancelRequest,
                  child: _isCancelling
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text(
                          'CANCEL REQUEST',
                          style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
