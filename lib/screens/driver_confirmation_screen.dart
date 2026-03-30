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
  int _pollCount = 0;
  static const int _maxPolls = 12; // 12 × 5s = 60s timeout
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check immediately, then poll every 5 seconds
    _checkStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    _pollCount++;

    // Timeout after _maxPolls attempts
    if (_pollCount > _maxPolls) {
      _pollingTimer?.cancel();
      if (mounted) {
        setState(() {
          _errorMessage = 'No response from driver after 60 seconds.\nPlease try again or cancel.';
        });
      }
      return;
    }

    try {
      final uri = Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/bookings.php')
          .replace(queryParameters: {'booking_id': widget.booking.id.toString()});
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Handle both flat object {"status": "..."} and array [{"status": "..."}]
        String? status;
        if (decoded is Map<String, dynamic>) {
          status = decoded['status'] as String?;
        } else if (decoded is List && decoded.isNotEmpty) {
          final first = decoded[0];
          if (first is Map<String, dynamic>) {
            status = first['status'] as String?;
          }
        }

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
        } else if (status == 'rejected' || status == 'cancelled') {
          _pollingTimer?.cancel();
          setState(() {
            _errorMessage = 'The driver declined this booking.\nPlease choose another driver.';
          });
        } else {
          // Still pending — clear any stale error message
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Server error (${response.statusCode}). Retrying...';
          });
        }
      }
    } catch (e) {
      debugPrint('Status check error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error. Retrying...';
        });
      }
    }
  }

  void _retryPolling() {
    setState(() {
      _errorMessage = null;
      _pollCount = 0;
    });
    _pollingTimer?.cancel();
    _checkStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
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
    final bool hasError = _errorMessage != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon — changes color on error
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: hasError
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFEBF2FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    hasError ? Icons.error_outline : Icons.search,
                    color: hasError
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF1A56DB),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  hasError ? 'Something went wrong' : 'Confirming with Driver...',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Error message or normal subtitle
                Text(
                  hasError
                      ? _errorMessage!
                      : '${widget.truck.driverName} is reviewing your cargo photo to ensure it fits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: hasError ? const Color(0xFFDC2626) : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Progress bar — only show while actively polling
                if (!hasError)
                  const LinearProgressIndicator(
                    backgroundColor: Color(0xFFEBF2FF),
                    color: Color(0xFF1A56DB),
                  ),

                const SizedBox(height: 40),

                // Retry button — only shown on error
                if (hasError)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _retryPolling,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                if (hasError) const SizedBox(height: 12),

                // Cancel button — always visible
                TextButton(
                  onPressed: _isCancelling ? null : _cancelRequest,
                  child: _isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'CANCEL REQUEST',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
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
