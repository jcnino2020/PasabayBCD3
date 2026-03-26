// ============================================================
// Driver Profile Screen
// Shows driver info, logout
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      setState(() => _userData = json.decode(userJson));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _userData?['full_name'] ?? 'Driver';
    final email = _userData?['email'] ?? '';
    final photo = _userData?['profile_photo_url'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF1A56DB).withOpacity(0.1),
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null
                  ? const Icon(Icons.person, size: 48, color: Color(0xFF1A56DB))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('DRIVER', style: TextStyle(color: Color(0xFF1A56DB), fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(height: 36),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: const Text('Log Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
