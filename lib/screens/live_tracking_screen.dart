// ============================================================
// Screen 08: Live Tracking Screen (Core)
// Shows a simulated map with driver route and ETA
// ============================================================

import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../models/booking.dart';
import '../widgets/bottom_nav_bar.dart';
import 'main_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Truck? truck;
  final Booking? booking;

  const LiveTrackingScreen({
    super.key,
    this.truck,
    this.booking,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _truckAnimController;
  late Animation<double> _truckPositionAnim;
  double _etaMinutes = 8;

  @override
  void initState() {
    super.initState();
    // Animate the truck icon moving along the dotted route
    _truckAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _truckPositionAnim = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _truckAnimController, curve: Curves.easeInOut),
    );

    // Simulate reducing ETA over time
    _simulateEtaCountdown();
  }

  void _simulateEtaCountdown() async {
    while (mounted && _etaMinutes > 0) {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _etaMinutes = (_etaMinutes - 0.5).clamp(0, 60));
      }
    }
  }

  @override
  void dispose() {
    _truckAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve booking from args or DataStore
    final activeBooking = widget.booking ?? DataStore().activeBooking;
    
    // If no active booking, show empty state
    if (activeBooking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No active trips', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    // Resolve truck
    final activeTruck = widget.truck ?? 
        sampleTrucks.firstWhere((t) => t.id == activeBooking.truckId, orElse: () => sampleTrucks[0]);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        // Stack lets us overlay the bottom card on top of the "map"
        children: [
          // Simulated map background
          _buildSimulatedMap(),

          // Status badge at top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // In Transit badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'In Transit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Booking ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      activeBooking.id.substring(0, 7),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ETA row
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          color: Color(0xFF1A56DB), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Arriving in ${_etaMinutes.toStringAsFixed(0)} mins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      // Call driver button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${activeTruck.driverName}...')),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone,
                              color: Color(0xFF1A56DB), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Manong Juan is transporting your shipment.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Driver info row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            color: Colors.grey, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeTruck.driverName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${activeTruck.type} • ${activeTruck.plateNumber}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            activeTruck.rating.toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Complete Delivery Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark booking as complete in DataStore
                        DataStore().completeBooking();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cargo received! Transaction completed.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        
                        // Return to home
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('MARK AS RECEIVED', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simulated map with dotted route and animated truck icon
  Widget _buildSimulatedMap() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F0FE),
            Color(0xFFD1E3FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Road/grid simulation
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: _MapPainter(),
          ),

          // Animated truck icon on the dotted route
          AnimatedBuilder(
            animation: _truckPositionAnim,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              // Move from bottom-right to upper-left
              final x = screenWidth * 0.6 -
                  (screenWidth * 0.3 * _truckPositionAnim.value);
              final y = screenHeight * 0.7 -
                  (screenHeight * 0.45 * _truckPositionAnim.value);
              return Positioned(
                left: x - 20,
                top: y - 20,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A56DB).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping,
                      color: Colors.white, size: 20),
                ),
              );
            },
          ),

          // ETA chip on map
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_etaMinutes.toStringAsFixed(0)} mins away',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Destination pin
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25,
            top: MediaQuery.of(context).size.height * 0.15,
            child: const Icon(Icons.location_on,
                color: Color(0xFF10B981), size: 32),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the map background (roads and dotted route)
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final dottedRoutePaint = Paint()
      ..color = const Color(0xFF1A56DB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw a few road lines to simulate a street map
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );

    // Draw dotted route line from bottom-right to top-left
    final path = Path()
      ..moveTo(size.width * 0.65, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.5,
        size.width * 0.25,
        size.height * 0.15,
      );

    // Draw dashes along the path
    final dashPaint = Paint()
      ..color = const Color(0xFF1A56DB).withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 10.0;
    const gapLength = 8.0;
    final pathMetric = path.computeMetrics().first;
    double distance = 0;
    while (distance < pathMetric.length) {
      final start = pathMetric.getTangentForOffset(distance)?.position;
      final end = pathMetric
          .getTangentForOffset(distance + dashLength)
          ?.position;
      if (start != null && end != null) {
        canvas.drawLine(start, end, dashPaint);
      }
      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
