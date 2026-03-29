// ============================================================
// Screen 02: Onboarding Screen
// Shows the value proposition with page dots navigation.
// Saves a 'onboarding_seen' flag so it only shows once.
// Illustrations are drawn with Flutter widgets — no PNG needed.
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Share space, Save cost',
      'subtitle':
          'Utilize empty truck space from Libertad, Burgos, and Central Market to any point in Bacolod.',
      'icon': 'truck',
    },
    {
      'title': 'Book in seconds',
      'subtitle':
          'Snap a photo of your cargo, enter the details, and get matched with a nearby driver instantly.',
      'icon': 'box',
    },
    {
      'title': 'Track your delivery',
      'subtitle':
          'Follow your cargo in real time from pickup to drop-off with live driver tracking.',
      'icon': 'map',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          ),
                          child: Container(
                            width: 250,
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F7FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: _buildIllustration(
                                  _pages[index]['icon']!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF1A56DB)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(String iconKey) {
    switch (iconKey) {
      case 'truck':
        return const _TruckIllustration();
      case 'box':
        return const _BoxIllustration();
      case 'map':
        return const _MapIllustration();
      default:
        return const _TruckIllustration();
    }
  }
}

// ─────────────────────────────────────────────
// Illustration 1 — Truck with speed lines
// ─────────────────────────────────────────────
class _TruckIllustration extends StatelessWidget {
  const _TruckIllustration();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1A56DB);
    const lightBlue = Color(0xFFD1E4FF);

    return SizedBox(
      width: 160,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Speed lines
          Positioned(
            left: 0,
            top: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _speedLine(lightBlue, 28),
                const SizedBox(height: 6),
                _speedLine(lightBlue, 20),
                const SizedBox(height: 6),
                _speedLine(lightBlue, 24),
              ],
            ),
          ),

          // Truck body (cargo box)
          Positioned(
            left: 30,
            top: 30,
            child: Container(
              width: 88,
              height: 52,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: const Center(
                child: Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),

          // Cab
          Positioned(
            left: 100,
            top: 44,
            child: Container(
              width: 46,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1245A8),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Align(
                alignment: Alignment(0.3, -0.2),
                child: Icon(Icons.person_rounded,
                    color: Colors.white70, size: 18),
              ),
            ),
          ),

          // Chassis / floor
          Positioned(
            left: 28,
            top: 80,
            child: Container(
              width: 120,
              height: 8,
              color: const Color(0xFF0D3B9E),
            ),
          ),

          // Wheel rear
          Positioned(
            left: 42,
            top: 82,
            child: _wheel(),
          ),

          // Wheel front
          Positioned(
            left: 106,
            top: 82,
            child: _wheel(),
          ),
        ],
      ),
    );
  }

  Widget _wheel() => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1F2937),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Center(
          child: CircleAvatar(radius: 3, backgroundColor: Colors.white54),
        ),
      );

  Widget _speedLine(Color color, double width) => Container(
        width: width,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

// ─────────────────────────────────────────────
// Illustration 2 — Package box with sparkles
// ─────────────────────────────────────────────
class _BoxIllustration extends StatelessWidget {
  const _BoxIllustration();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1A56DB);
    const amber = Color(0xFFFBBF24);

    return SizedBox(
      width: 150,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Box body
          Positioned(
            left: 25,
            top: 30,
            child: Container(
              width: 96,
              height: 86,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Box lid
          Positioned(
            left: 20,
            top: 22,
            child: Container(
              width: 106,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF1245A8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),

          // Ribbon horizontal
          Positioned(
            left: 25,
            top: 60,
            child: Container(width: 96, height: 6, color: amber),
          ),

          // Ribbon vertical
          Positioned(
            left: 68,
            top: 22,
            child: Container(width: 6, height: 94, color: amber),
          ),

          // Bow knot
          Positioned(
            left: 56,
            top: 14,
            child: Container(
              width: 32,
              height: 18,
              decoration: BoxDecoration(
                color: amber,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.white, size: 14),
            ),
          ),

          // Sparkle top-right
          Positioned(
            right: 4,
            top: 10,
            child: _sparkle(amber, 16),
          ),

          // Sparkle bottom-left
          Positioned(
            left: 2,
            bottom: 10,
            child: _sparkle(blue.withValues(alpha: 0.5), 12),
          ),
        ],
      ),
    );
  }

  Widget _sparkle(Color color, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparkPainter(color),
    );
  }
}

// ─────────────────────────────────────────────
// Illustration 3 — Map pin with route dots
// ─────────────────────────────────────────────
class _MapIllustration extends StatelessWidget {
  const _MapIllustration();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1A56DB);
    const green = Color(0xFF10B981);
    const red = Color(0xFFEF4444);

    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Map card background
          Positioned(
            left: 10,
            top: 20,
            child: Container(
              width: 128,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: blue.withValues(alpha: 0.2), width: 1.5),
              ),
              child: CustomPaint(painter: _RoutePainter()),
            ),
          ),

          // Origin dot (green)
          Positioned(
            left: 26,
            top: 68,
            child: _mapDot(green, Icons.circle, 10),
          ),

          // Destination pin (red)
          Positioned(
            right: 18,
            top: 28,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 16),
                ),
                Container(
                  width: 3,
                  height: 8,
                  color: red,
                ),
              ],
            ),
          ),

          // Truck icon moving on route
          Positioned(
            left: 66,
            top: 54,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 16),
            ),
          ),

          // "LIVE" badge
          Positioned(
            left: 10,
            top: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapDot(Color color, IconData icon, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─────────────────────────────────────────────
// Custom painters
// ─────────────────────────────────────────────

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A56DB).withValues(alpha: 0.25)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFF1A56DB).withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a curved route path
    final path = Path()
      ..moveTo(20, size.height * 0.75)
      ..cubicTo(
        size.width * 0.3, size.height * 0.2,
        size.width * 0.6, size.height * 0.8,
        size.width * 0.88, size.height * 0.22,
      );

    // Draw dashed
    _drawDashed(canvas, path, dashPaint, 6, 4);

    // Road grid lines (subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFF1A56DB).withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, double dash, double gap) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final end = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkPainter extends CustomPainter {
  final Color color;
  const _SparkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) * 2 * i;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * r * 0.3, cy + math.sin(angle) * r * 0.3),
        Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
