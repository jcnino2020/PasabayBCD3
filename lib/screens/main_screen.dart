import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'trip_matching_screen.dart';
import 'live_tracking_screen.dart';
import 'savings_dashboard_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // The four main tabs of the application
  // IndexedStack keeps these alive, making switching instant (responsive)
  final List<Widget> _screens = [
    const TripMatchingScreen(),
    const LiveTrackingScreen(), // Handles its own "No Active Trip" state
    const SavingsDashboardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PasabayBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}