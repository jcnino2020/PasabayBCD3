// ============================================================
// Booking Confirmation Screen
// Shows a receipt-style summary after a booking is confirmed
// ============================================================

import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/truck.dart';
import 'main_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final Truck truck;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.truck,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF065F46),
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your cargo has been booked.\nThe driver has been notified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 36),

              // Receipt card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildRow('Booking ID', '#${booking.id}'),
                    const Divider(height: 24),
                    _buildRow('Driver', truck.driverName),
                    const SizedBox(height: 12),
                    _buildRow('Vehicle', truck.type),
                    const SizedBox(height: 12),
                    _buildRow('Plate No.', truck.plateNumber),
                    const SizedBox(height: 12),
                    _buildRow('Cargo', booking.cargoCategory),
                    const SizedBox(height: 12),
                    _buildRow('Weight', '${booking.weightKg} kg'),
                    const SizedBox(height: 12),
                    _buildRow('Quantity', '${booking.quantity} pcs'),
                    const Divider(height: 24),
                    _buildRow(
                      'Total Fee',
                      '\u20B1${booking.estimatedFee.toStringAsFixed(2)}',
                      highlight: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Go to Home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Set active booking & truck so tracking tab works
                    DataStore().setActiveBooking(booking);
                    DataStore().setActiveTruck(truck);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Track order button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Set active booking & truck so tracking tab works
                    DataStore().setActiveBooking(booking);
                    DataStore().setActiveTruck(truck);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 1)),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A56DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Track My Order',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A56DB)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? const Color(0xFF1A56DB) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}