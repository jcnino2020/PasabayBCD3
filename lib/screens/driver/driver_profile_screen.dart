// ============================================================
// Driver Profile Screen
// Shows driver info from SharedPreferences
// Logout action
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../splash_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _driverData;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  Future<void> _loadDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final driverJson = prefs.getString('driverData');
    if (driverJson != null) {
      setState(() => _driverData = json.decode(driverJson));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('driverData');
      await prefs.remove('isDriver');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _driverData?['name'] ?? _driverData?['driver_name'] ?? 'Driver';
    final driverId = _driverData?['driver_id'] ?? '-';
    final phone = _driverData?['phone'] ?? '-';
    final truckId = _driverData?['truck_id'] ?? '-';
    final licenseNo = _driverData?['license_no'] ?? _driverData?['license_number'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF1A56DB).withOpacity(0.1),
              child: const Icon(Icons.person, size: 44, color: Color(0xFF1A56DB)),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Driver', style: TextStyle(color: Color(0xFF1A56DB), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _ProfileRow(icon: Icons.badge_outlined, label: 'Driver ID', value: driverId.toString()),
                  const Divider(height: 20),
                  _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: phone.toString()),
                  const Divider(height: 20),
                  _ProfileRow(icon: Icons.local_shipping_outlined, label: 'Truck ID', value: truckId.toString()),
                  const Divider(height: 20),
                  _ProfileRow(icon: Icons.credit_card_outlined, label: 'License No.', value: licenseNo.toString()),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                label: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A56DB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }
}
