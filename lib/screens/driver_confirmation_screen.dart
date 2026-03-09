// ============================================================
// Screen 07: Driver Confirmation / Algorithm Matching Screen
// Shows loading animation while driver reviews the cargo photo
// ============================================================

import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../models/booking.dart';
import 'main_screen.dart';

class DriverConfirmationScreen extends StatefulWidget {
  final Truck truck;
  final Booking booking;

  const DriverConfirmationScreen({
    super.key,
    required this.truck,
    required this.booking,
  });

  @override
  State<DriverConfirmationScreen> createState() =>
      _DriverConfirmationScreenState();
}

class _DriverConfirmationScreenState extends State<DriverConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Status message that updates over time to simulate driver review
  String _statusMessage = 'Sending your cargo details...';

  @override
  void initState() {
    super.initState();

    // Pulsing animation for the search icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate driver review stages
    _simulateMatching();
  }

  void _simulateMatching() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _statusMessage = '${widget.truck.driverName} is reviewing your cargo photo to ensure it fits.');

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _statusMessage = 'Almost there! Confirming route details...');

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Auto-navigate to live tracking when confirmed
    
    // Save booking to DataStore (deducts balance, adds transaction)
    DataStore().addBooking(widget.booking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(initialIndex: 1),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),

              // Pulsing search/matching icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A56DB).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.manage_search,
                    size: 50,
                    color: Color(0xFF1A56DB),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Confirming with Driver...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic status message (updates via setState in _simulateMatching)
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Loading dots animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      // Each dot has slightly different opacity for a wave effect
                      final offset = index * 0.3;
                      final value = (_pulseController.value + offset) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            Colors.grey.shade300,
                            const Color(0xFF1A56DB),
                            value,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const Spacer(),

              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'CANCEL REQUEST',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
