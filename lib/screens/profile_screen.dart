// ============================================================
// Screen 10: Account Management / Merchant Profile Screen
// Original clean layout restored — Settings moved to its own screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import '../models/booking.dart';
import 'login_screen.dart';
import 'kyc_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  void _showEditProfileDialog(BuildContext context, DataStore dataStore) {
    final nameController =
        TextEditingController(text: dataStore.merchantName);
    final locationController =
        TextEditingController(text: dataStore.marketLocation);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Merchant Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration:
                    const InputDecoration(labelText: 'Market Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);
                      try {
                        final uri = Uri.parse(
                          'http://ov3.238.mytemp.website/pasabaybcd/api/update_profile.php',
                        );
                        final response = await http.post(
                          uri,
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'user_id': dataStore.userId ?? 0,
                            'merchant_name': nameController.text.trim(),
                            'market_location':
                                locationController.text.trim(),
                          }),
                        );
                        if (!ctx.mounted) return;
                        if (response.statusCode == 200) {
                          setState(() {
                            dataStore.merchantName =
                                nameController.text.trim();
                            dataStore.marketLocation =
                                locationController.text.trim();
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Could not update profile. Try again.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          setDialogState(() => isSaving = false);
                        }
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Network error. Please try again.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        setDialogState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadProfilePhoto(DataStore dataStore) async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      final File resizedFile = await _resizeImage(File(image.path));
      final uri = Uri.parse(
          'http://ov3.238.mytemp.website/pasabaybcd/api/user_profile_upload.php');
      final request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = dataStore.userId.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'profile_photo',
        resizedFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      final response = await request.send();
      if (!mounted) return;
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        setState(() {
          dataStore.profilePhotoUrl = responseData['profile_photo_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile photo updated!'),
              backgroundColor: Color(0xFF10B981)),
        );
      } else {
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Upload failed: ${errorData['error'] ?? 'Server error'}'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<File> _resizeImage(File originalFile, {int maxWidth = 512}) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return originalFile;
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }
    final resizedBytes = img.encodeJpg(image, quality: 90);
    final tempDir = Directory.systemTemp;
    final tempFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(resizedBytes);
    return tempFile;
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MERCHANT PROFILE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: Colors.grey),
                        tooltip: 'Settings',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.grey),
                        tooltip: 'Edit Profile',
                        onPressed: () =>
                            _showEditProfileDialog(context, dataStore),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Profile Card ──────────────────────
                    _buildProfileCard(dataStore),
                    const SizedBox(height: 20),

                    // ── Stats Row ─────────────────────────
                    _buildStatsRow(dataStore),
                    const SizedBox(height: 20),

                    // ── Quick Actions ─────────────────────
                    _buildQuickActions(context, dataStore),
                    const SizedBox(height: 20),

                    // ── KYC Banner (if pending) ───────────
                    if (!dataStore.isKycVerified)
                      _buildKycBanner(context, dataStore),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widget builders ──────────────────────────────────────

  Widget _buildProfileCard(DataStore dataStore) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(dataStore),
          const SizedBox(height: 14),
          Text(
            dataStore.merchantName,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            dataStore.marketLocation,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(
                  () => dataStore.isKycVerified = !dataStore.isKycVerified);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(dataStore.isKycVerified
                      ? 'KYC Verification complete!'
                      : 'KYC verification removed.'),
                  backgroundColor: dataStore.isKycVerified
                      ? const Color(0xFF10B981)
                      : Colors.orange,
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: dataStore.isKycVerified
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    dataStore.isKycVerified
                        ? Icons.verified
                        : Icons.pending_outlined,
                    size: 16,
                    color: dataStore.isKycVerified
                        ? const Color(0xFF065F46)
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dataStore.isKycVerified ? 'KYC Verified' : 'KYC Pending',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dataStore.isKycVerified
                            ? const Color(0xFF065F46)
                            : const Color(0xFFD97706)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DataStore dataStore) {
    return Row(
      children: [
        _statCard('Shipments',
            '${dataStore.transactions.length}', Icons.local_shipping_outlined),
        const SizedBox(width: 12),
        _statCard('Savings',
            '₱${dataStore.totalSavings.toStringAsFixed(0)}',
            Icons.savings_outlined),
        const SizedBox(width: 12),
        _statCard('Rating', '4.8 ★', Icons.star_outline),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1A56DB)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DataStore dataStore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Column(
            children: [
              _quickActionTile(
                icon: Icons.verified_user_outlined,
                label: 'Business Verification (KYC)',
                subtitle: dataStore.isKycVerified
                    ? 'Verified'
                    : 'Pending verification',
                color: const Color(0xFF1A56DB),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KycVerificationScreen())),
              ),
              const Divider(height: 1, indent: 56),
              _quickActionTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                subtitle: 'Notifications, security, appearance & more',
                color: Colors.grey.shade700,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen())),
              ),
              const Divider(height: 1, indent: 56),
              _quickActionTile(
                icon: Icons.logout,
                label: 'Log Out',
                subtitle: 'Sign out of your account',
                color: Colors.red,
                onTap: () => _showLogoutDialog(dataStore),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color == Colors.red ? Colors.red : const Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  Widget _buildKycBanner(BuildContext context, DataStore dataStore) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const KycVerificationScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD97706), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete your KYC verification',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Verify your business to unlock higher shipment limits.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFD97706), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(DataStore dataStore) {
    final imageUrl = dataStore.profilePhotoUrl != null
        ? '${dataStore.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}'
        : null;
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? const Icon(Icons.store_outlined,
                  size: 44, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _pickAndUploadProfilePhoto(dataStore),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.edit,
                      color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(DataStore dataStore) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content:
            const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userData');
              DataStore().clearUserData();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
