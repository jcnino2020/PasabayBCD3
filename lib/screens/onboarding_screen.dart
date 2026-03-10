// ============================================================
// Screen 02: Onboarding Screen
// Shows the value proposition with page dots navigation
// ============================================================

import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Track which onboarding page the user is on
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Onboarding content data
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Returns the icon widget for each page
  Widget _buildPageIcon(String iconKey) {
    String imagePath;
    switch (iconKey) {
      case 'box':
        imagePath = 'assets/images/onboarding_box.png';
        break;
      case 'map':
        imagePath = 'assets/images/onboarding_map.png';
        break;
      default:
        imagePath = 'assets/images/onboarding_truck.png';
    }
    // Using Image.asset to show a more engaging illustration.
    return Image.asset(imagePath, height: 150, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ),

            // Page view takes up most of the screen
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  // setState() triggers a UI rebuild so the dot indicator updates
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration placeholder (grey box with icon)
                        Container(
                          width: 250,
                          height: 220,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: _buildPageIcon(_pages[index]['icon']!),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Page title
                        Text(
                          _pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Page subtitle
                        Text(
                          _pages[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
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

            // Page dot indicators
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

            // Get Started / Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      // Go to next page
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // On last page, navigate to login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
}
