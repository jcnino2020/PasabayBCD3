// ============================================================
// Widget: PasabayBottomNavBar
// Reusable bottom navigation bar used across core screens
// ============================================================

import 'package:flutter/material.dart';

class PasabayBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PasabayBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A56DB),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 13,
      unselectedFontSize: 13,
      elevation: 8,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Active',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
