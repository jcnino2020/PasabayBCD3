// ============================================================
// Screen 10: Account Management / Merchant Profile Screen
// Shows merchant info, KYC status, and account settings
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import '../models/booking.dart'; // Import for DataStore
import 'login_screen.dart';
import 'kyc_screen.dart';
import 'faq_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // For profile photo upload
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  void _showEditProfileDialog(BuildContext context, DataStore dataStore) {
    final nameController = TextEditingController(text: dataStore.merchantName);
    final locationController = TextEditingController(text: dataStore.marketLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Merchant Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Market Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dataStore.merchantName = nameController.text;
                dataStore.marketLocation = locationController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showShipmentHistory(BuildContext context, DataStore dataStore) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: dataStore.transactions.isEmpty
                  ? const Center(child: Text('No history yet.'))
                  : ListView.separated(
                      itemCount: dataStore.transactions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (ctx, index) {
                        final tx = dataStore.transactions[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_shipping, color: Color(0xFF1A56DB)),
                          ),
                          title: Text(tx.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(tx.date),
                          trailing: Text(
                            '₱${tx.amount.abs().toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // Mock notifications
    final notifications = [
      {'title': 'Driver Arrived', 'body': 'Manong Juan has arrived at Libertad Market.', 'time': '2 mins ago'},
      {'title': 'Booking Confirmed', 'body': 'Your trip to Mansilingan is confirmed.', 'time': '1 hr ago'},
      {'title': 'Promo Alert', 'body': 'Get 10% off your next booking!', 'time': '1 day ago'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, index) {
                  final n = notifications[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEBF2FF),
                      child: Icon(Icons.notifications, color: Color(0xFF1A56DB), size: 20),
                    ),
                    title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(n['body']!),
                    trailing: Text(n['time']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Support'),
              subtitle: const Text('+63 912 345 6789'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email Us'),
              subtitle: const Text('support@pasabaybcd.com'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.orange),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Handles picking an image from the gallery and uploading it.
  Future<void> _pickAndUploadProfilePhoto(DataStore dataStore) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final File resizedFile = await _resizeImage(File(image.path));
      final uri = Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/user_profile_upload.php');
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
          const SnackBar(content: Text('Profile photo updated!'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${errorData['error'] ?? 'Server error'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// Resizes an image file to a max width to reduce upload size.
  Future<File> _resizeImage(File originalFile, {int maxWidth = 512}) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return originalFile;

    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    final resizedBytes = img.encodeJpg(image, quality: 90);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(resizedBytes);
    return tempFile;
  }

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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: () => _showEditProfileDialog(context, dataStore),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile avatar and name
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileAvatar(dataStore),
                          const SizedBox(height: 14),
                          // Merchant name
                          Text(
                            dataStore.merchantName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dataStore.marketLocation,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // KYC verified badge
                          GestureDetector(
                            onTap: () {
                              // Simulate verifying KYC using setState
                              setState(() => dataStore.isKycVerified = !dataStore.isKycVerified);
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
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
                                    size: 14,
                                    color: dataStore.isKycVerified
                                        ? const Color(0xFF065F46)
                                        : const Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dataStore.isKycVerified
                                        ? 'KYC Verified'
                                        : 'KYC Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: dataStore.isKycVerified
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu items list
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.verified_user_outlined,
                            label: 'Business Verification (KYC)',
                            color: const Color(0xFF1A56DB),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycVerificationScreen())).then((_) => setState((){})),
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildMenuTile(
                            icon: Icons.history,
                            label: 'Shipment History',
                            color: Colors.grey.shade600,
                            onTap: () => _showShipmentHistory(context, dataStore),
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildMenuTile(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            color: Colors.grey.shade600,
                            onTap: () => _showNotifications(context),
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildMenuTile(
                            icon: Icons.help_outline,
                            label: 'Help & Support',
                            color: Colors.grey.shade600,
                            onTap: () => _showHelpSupport(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Logout - in a separate card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: _buildMenuTile(
                        icon: Icons.logout,
                        label: 'Logout',
                        color: Colors.red,
                        onTap: () {
                          // Show confirmation dialog before logging out
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Log Out?'),
                              content: const Text(
                                  'You will be returned to the login screen.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Clear the saved user session
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('userData');

                                    // Reset local data store
                                    DataStore().clearUserData();

                                    if (!context.mounted) return;

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App version text
                    Text(
                      'PasabayBCD v1.0.0 · BSIT 3-B',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(DataStore dataStore) {
    // Use a cache-busting URL by appending a timestamp
    final imageUrl = dataStore.profilePhotoUrl != null
        ? '${dataStore.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? const Icon(Icons.store_outlined, size: 40, color: Colors.grey)
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // Reusable menu tile widget
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color == Colors.red ? Colors.red : const Color(0xFF111827),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }
}