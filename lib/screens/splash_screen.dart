// ============================================================
// Screen 01: Splash Screen
// Shows the app logo and name, auto-navigates after 2 seconds.
// Checks for saved session AND onboarding_seen flag.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/booking.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'driver/driver_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkSession();
  }

  void _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    if (!mounted) return;

    // If logged in, route based on role
    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        DataStore().setUserData(userData);
        final role = userData['role'] ?? 'passenger';
        if (role == 'driver') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverMainScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
        }
        return;
      } catch (e) {
        debugPrint('Failed to parse saved user data: $e');
        await prefs.remove('userData');
      }
    }

    // If onboarding was already seen, go to login directly
    if (onboardingSeen) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // First time user — show onboarding
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 20),
                const Text(
                  'PasabayBCD',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SME LOGISTICS HUB',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(4),
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
