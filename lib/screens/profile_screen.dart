// ============================================================
// Screen 10: Account Management / Merchant Profile Screen
// Shows merchant info, KYC status, and a full settings panel
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
import 'faq_screen.dart';
import 'booking_history_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // ── Settings state ──────────────────────────────────────────
  bool _notifBookingUpdates = true;
  bool _notifPromos = false;
  bool _notifDriverArrival = true;
  bool _notifSMS = false;
  bool _notifEmail = true;
  bool _darkMode = false;
  bool _biometricLock = false;
  bool _twoFactorAuth = false;
  bool _locationSharing = true;
  bool _autoAcceptRatings = false;
  bool _savePaymentInfo = true;
  bool _analyticsOptIn = true;
  bool _compactView = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'PHP (₱)';
  String _selectedMapStyle = 'Standard';
  double _defaultWeightKg = 10.0;
  String _preferredPayment = 'Cash on Delivery';

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
                            'merchant_name':
                                nameController.text.trim(),
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
                            content: Text('Network error. Please try again.'),
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
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
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
              leading:
                  const Icon(Icons.question_answer, color: Colors.orange),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FaqScreen()));
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

  Future<void> _pickAndUploadProfilePhoto(DataStore dataStore) async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      final File resizedFile =
          await _resizeImage(File(image.path));
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
          dataStore.profilePhotoUrl =
              responseData['profile_photo_url'];
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

  Future<File> _resizeImage(File originalFile,
      {int maxWidth = 512}) async {
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

  // ── Dialogs for picker settings ─────────────────────────────

  void _showLanguagePicker() {
    final languages = [
      'English',
      'Filipino',
      'Hiligaynon',
      'Cebuano',
      'Ilocano',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Select Language',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...languages.map((lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check,
                        color: Color(0xFF1A56DB))
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['PHP (₱)', 'USD (\$)', 'EUR (€)'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Select Currency',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...currencies.map((c) => ListTile(
                title: Text(c),
                trailing: _selectedCurrency == c
                    ? const Icon(Icons.check,
                        color: Color(0xFF1A56DB))
                    : null,
                onTap: () {
                  setState(() => _selectedCurrency = c);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showMapStylePicker() {
    final styles = ['Standard', 'Satellite', 'Terrain', 'Dark'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Map Style',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...styles.map((s) => ListTile(
                title: Text(s),
                trailing: _selectedMapStyle == s
                    ? const Icon(Icons.check,
                        color: Color(0xFF1A56DB))
                    : null,
                onTap: () {
                  setState(() => _selectedMapStyle = s);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPaymentPicker() {
    final methods = [
      'Cash on Delivery',
      'GCash',
      'Maya',
      'Bank Transfer',
      'Credit / Debit Card',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Preferred Payment Method',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...methods.map((m) => ListTile(
                title: Text(m),
                trailing: _preferredPayment == m
                    ? const Icon(Icons.check,
                        color: Color(0xFF1A56DB))
                    : null,
                onTap: () {
                  setState(() => _preferredPayment = m);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showWeightDialog() {
    double tempWeight = _defaultWeightKg;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Default Cargo Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${tempWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A56DB))),
              Slider(
                value: tempWeight,
                min: 1,
                max: 200,
                divisions: 199,
                label: '${tempWeight.toStringAsFixed(0)} kg',
                onChanged: (v) => setS(() => tempWeight = v),
              ),
              const Text('Drag to set your most common shipment weight.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() => _defaultWeightKg = tempWeight);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password change request sent.'),
                    backgroundColor: Color(0xFF10B981)),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLinkedAccountsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Linked Accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _linkedAccountTile(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                linked: true,
                color: Colors.red),
            const Divider(height: 1),
            _linkedAccountTile(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                linked: false,
                color: const Color(0xFF1877F2)),
            const Divider(height: 1),
            _linkedAccountTile(
                icon: Icons.phone_android,
                label: 'Mobile Number',
                linked: true,
                color: Colors.green),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _linkedAccountTile({
    required IconData icon,
    required String label,
    required bool linked,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(label),
      trailing: linked
          ? Chip(
              label: const Text('Linked',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              backgroundColor: Colors.green,
              padding: EdgeInsets.zero,
            )
          : OutlinedButton(
              onPressed: () {},
              child: const Text('Link'),
            ),
    );
  }

  void _showDataStorageInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Storage & Data',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _storageRow('App Cache', '14.2 MB', Icons.storage),
            _storageRow(
                'Offline Maps', '0 MB', Icons.map_outlined),
            _storageRow(
                'Saved Photos', '3.1 MB', Icons.photo_library_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cache cleared!'),
                        backgroundColor: Color(0xFF10B981)),
                  );
                },
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear Cache'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storageRow(String label, String size, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 15))),
          Text(size,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRateAppDialog() {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Rate PasabayBCD'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enjoying the app? Leave us a rating!',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () =>
                              setS(() => selectedStars = i + 1),
                          child: Icon(
                            i < selectedStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 36,
                            color: const Color(0xFFF59E0B),
                          ),
                        )),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedStars > 0
                  ? () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Thanks for rating us $selectedStars star${selectedStars > 1 ? 's' : ''}!'),
                            backgroundColor:
                                const Color(0xFF10B981)),
                      );
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.red)),
        content: const Text(
            'This action is permanent and cannot be undone. All your data, bookings, and history will be deleted.\n\nAre you absolutely sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Account deletion request submitted.'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );
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
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.grey),
                    onPressed: () =>
                        _showEditProfileDialog(context, dataStore),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ── Profile Card ──────────────────────
                    _buildProfileCard(dataStore),
                    const SizedBox(height: 20),

                    // ── Stats Row ─────────────────────────
                    _buildStatsRow(dataStore),
                    const SizedBox(height: 20),

                    // ── Section: Account ──────────────────
                    _buildSectionHeader('Account'),
                    _buildSettingsCard([
                      _buildMenuTile(
                        icon: Icons.verified_user_outlined,
                        label: 'Business Verification (KYC)',
                        color: const Color(0xFF1A56DB),
                        onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const KycVerificationScreen()))
                            .then((_) => setState(() {})),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        color: Colors.grey.shade600,
                        onTap: () =>
                            _showChangePasswordDialog(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.link,
                        label: 'Linked Accounts',
                        color: Colors.grey.shade600,
                        onTap: () =>
                            _showLinkedAccountsDialog(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.badge_outlined,
                        label: 'Merchant ID',
                        color: Colors.grey.shade600,
                        trailing: Text(
                          '#${(dataStore.userId ?? 0).toString().padLeft(6, '0')}',
                          style: const TextStyle(
                              color: Color(0xFF1A56DB),
                              fontWeight: FontWeight.w600),
                        ),
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Notifications ────────────
                    _buildSectionHeader('Notifications'),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.local_shipping_outlined,
                        label: 'Booking Updates',
                        subtitle: 'Get push alerts on every booking status change',
                        value: _notifBookingUpdates,
                        onChanged: (v) => setState(
                            () => _notifBookingUpdates = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.directions_car_outlined,
                        label: 'Driver Arrival Alerts',
                        subtitle: 'Notify when your driver is nearby',
                        value: _notifDriverArrival,
                        onChanged: (v) => setState(
                            () => _notifDriverArrival = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.local_offer_outlined,
                        label: 'Promos & Offers',
                        subtitle: 'Receive discount and promotion alerts',
                        value: _notifPromos,
                        onChanged: (v) =>
                            setState(() => _notifPromos = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.sms_outlined,
                        label: 'SMS Notifications',
                        subtitle: 'Receive updates via text message',
                        value: _notifSMS,
                        onChanged: (v) =>
                            setState(() => _notifSMS = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.email_outlined,
                        label: 'Email Notifications',
                        subtitle: 'Get receipts and summaries by email',
                        value: _notifEmail,
                        onChanged: (v) =>
                            setState(() => _notifEmail = v),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Booking Preferences ──────
                    _buildSectionHeader('Booking Preferences'),
                    _buildSettingsCard([
                      _buildMenuTile(
                        icon: Icons.payments_outlined,
                        label: 'Preferred Payment',
                        color: Colors.grey.shade600,
                        trailing: Text(_preferredPayment,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13)),
                        onTap: () => _showPaymentPicker(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.scale_outlined,
                        label: 'Default Cargo Weight',
                        color: Colors.grey.shade600,
                        trailing: Text(
                            '${_defaultWeightKg.toStringAsFixed(0)} kg',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13)),
                        onTap: () => _showWeightDialog(),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.star_outline,
                        label: 'Auto-Accept Ratings',
                        subtitle: 'Automatically submit 5-star after delivery',
                        value: _autoAcceptRatings,
                        onChanged: (v) => setState(
                            () => _autoAcceptRatings = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.credit_card_outlined,
                        label: 'Save Payment Info',
                        subtitle: 'Securely store payment details for faster checkout',
                        value: _savePaymentInfo,
                        onChanged: (v) => setState(
                            () => _savePaymentInfo = v),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Security & Privacy ───────
                    _buildSectionHeader('Security & Privacy'),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.fingerprint,
                        label: 'Biometric Login',
                        subtitle: 'Use fingerprint or Face ID to unlock the app',
                        value: _biometricLock,
                        onChanged: (v) =>
                            setState(() => _biometricLock = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.security,
                        label: 'Two-Factor Authentication',
                        subtitle: 'Extra security layer on login',
                        value: _twoFactorAuth,
                        onChanged: (v) =>
                            setState(() => _twoFactorAuth = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.location_on_outlined,
                        label: 'Location Sharing',
                        subtitle: 'Allow drivers to see your live location',
                        value: _locationSharing,
                        onChanged: (v) =>
                            setState(() => _locationSharing = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.analytics_outlined,
                        label: 'Analytics & Diagnostics',
                        subtitle: 'Share anonymous usage data to improve the app',
                        value: _analyticsOptIn,
                        onChanged: (v) =>
                            setState(() => _analyticsOptIn = v),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Appearance ───────────────
                    _buildSectionHeader('Appearance'),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        subtitle: 'Switch to a dark color theme',
                        value: _darkMode,
                        onChanged: (v) =>
                            setState(() => _darkMode = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        icon: Icons.view_compact_outlined,
                        label: 'Compact View',
                        subtitle: 'Show more items in list screens',
                        value: _compactView,
                        onChanged: (v) =>
                            setState(() => _compactView = v),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.language,
                        label: 'Language',
                        color: Colors.grey.shade600,
                        trailing: Text(_selectedLanguage,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13)),
                        onTap: () => _showLanguagePicker(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.attach_money_outlined,
                        label: 'Currency Display',
                        color: Colors.grey.shade600,
                        trailing: Text(_selectedCurrency,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13)),
                        onTap: () => _showCurrencyPicker(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.map_outlined,
                        label: 'Map Style',
                        color: Colors.grey.shade600,
                        trailing: Text(_selectedMapStyle,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13)),
                        onTap: () => _showMapStylePicker(),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Activity ─────────────────
                    _buildSectionHeader('Activity'),
                    _buildSettingsCard([
                      _buildMenuTile(
                        icon: Icons.history,
                        label: 'Shipment History',
                        color: Colors.grey.shade600,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const BookingHistoryScreen())),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        color: Colors.grey.shade600,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsScreen())),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Transaction Receipts',
                        color: Colors.grey.shade600,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Receipts feature coming soon.')),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Support ──────────────────
                    _buildSectionHeader('Support & Info'),
                    _buildSettingsCard([
                      _buildMenuTile(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        color: Colors.grey.shade600,
                        onTap: () => _showHelpSupport(context),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.question_answer_outlined,
                        label: 'FAQs',
                        color: Colors.grey.shade600,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FaqScreen())),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.storage_outlined,
                        label: 'Storage & Data',
                        color: Colors.grey.shade600,
                        onTap: () => _showDataStorageInfo(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.star_rate_outlined,
                        label: 'Rate the App',
                        color: Colors.grey.shade600,
                        onTap: () => _showRateAppDialog(),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.share_outlined,
                        label: 'Share PasabayBCD',
                        color: Colors.grey.shade600,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Share sheet opened!')),
                          );
                        },
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.policy_outlined,
                        label: 'Privacy Policy',
                        color: Colors.grey.shade600,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Opening Privacy Policy...')),
                          );
                        },
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        color: Colors.grey.shade600,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Opening Terms of Service...')),
                          );
                        },
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.info_outline,
                        label: 'About PasabayBCD',
                        color: Colors.grey.shade600,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AboutScreen())),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Section: Danger Zone ──────────────
                    _buildSectionHeader('Danger Zone'),
                    _buildSettingsCard([
                      _buildMenuTile(
                        icon: Icons.logout,
                        label: 'Log Out',
                        color: Colors.red,
                        onTap: () => _showLogoutDialog(dataStore),
                      ),
                      _divider(),
                      _buildMenuTile(
                        icon: Icons.delete_forever_outlined,
                        label: 'Delete Account',
                        color: Colors.red.shade700,
                        onTap: () => _showDeleteAccountDialog(),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // App version
                    Center(
                      child: Text(
                        'PasabayBCD v1.0.0 · BSIT 3-B',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
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

  // ── Sub-widget builders ──────────────────────────────────────

  Widget _buildProfileCard(DataStore dataStore) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10)
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
                    dataStore.isKycVerified
                        ? 'KYC Verified'
                        : 'KYC Pending',
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56);

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A56DB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A56DB)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1A56DB),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
          color: color == Colors.red || color == Colors.red.shade700
              ? Colors.red
              : const Color(0xFF111827),
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
              ? const Icon(Icons.store_outlined, size: 44, color: Colors.grey)
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
                  : const Icon(Icons.edit, color: Colors.white, size: 18),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
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
