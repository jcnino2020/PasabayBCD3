// ============================================================
// Screen 01: Splash Screen
// Shows the app logo and name, auto-navigates after 2 seconds
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/booking.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for the logo fade-in effect
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up a simple fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Check for a saved session instead of just waiting
    _checkSession();
  }

  void _checkSession() async {
    // Wait for splash animation to be visible for a bit
    await Future.delayed(const Duration(milliseconds: 2000));

    final prefs = await SharedPreferences.getInstance();
    // Check for the saved user data JSON string, which is now saved by the login screen.
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      // User session found. Restore the session data directly without a network call.
      if (mounted) {
        try {
          final userData = json.decode(userDataString);
          DataStore().setUserData(userData);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
          return; // Exit function on success
        } catch (e) {
          // If JSON is corrupted or data is invalid, clear it and proceed to login.
          debugPrint("Failed to parse saved user data: $e");
          await prefs.remove('userData');
        }
      }
    }

    // If no session is found or restoring it fails, go to onboarding
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo - hexagon icon with truck
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              // App name
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
              // Tagline
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
              // Loading indicator
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
    );
  }
}
