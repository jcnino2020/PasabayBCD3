// ============================================================
// Settings Screen — Full app settings hub
// Opened from the Settings button/tile in ProfileScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/booking.dart';
import 'login_screen.dart';
import 'kyc_screen.dart';
import 'faq_screen.dart';
import 'booking_history_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
  bool _autoBackup = true;
  bool _readReceipts = true;
  bool _onlineStatus = true;
  bool _dataSaver = false;
  bool _crashReports = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _autoNightMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'PHP (₱)';
  String _selectedMapStyle = 'Standard';
  double _defaultWeightKg = 10.0;
  String _preferredPayment = 'Cash on Delivery';
  String _selectedFontSize = 'Medium';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedDistanceUnit = 'Kilometers';
  String _selectedWeightUnit = 'Kilograms';
  int _selectedAccentIndex = 0;
  String _appLockTimeout = '5 minutes';
  String _selectedRegion = 'Negros Occidental';
  bool _showOnlineDriversOnly = false;
  bool _receiptAutoEmail = false;
  bool _priceAlerts = true;
  bool _surgeAlerts = true;
  bool _weatherAlerts = false;
  bool _weeklyDigest = true;
  int _maxBookingsPerDay = 5;
  String _deliveryPriority = 'Standard';

  static const List<String> _accentNames = [
    'Blue', 'Green', 'Orange', 'Purple', 'Red'
  ];

  // ── Init: load persisted prefs ───────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifBookingUpdates = prefs.getBool('setting_notif_booking') ?? true;
      _notifPromos = prefs.getBool('setting_notif_promos') ?? false;
      _notifDriverArrival = prefs.getBool('setting_notif_driver') ?? true;
      _notifSMS = prefs.getBool('setting_notif_sms') ?? false;
      _notifEmail = prefs.getBool('setting_notif_email') ?? true;
      _darkMode = prefs.getBool('setting_dark_mode') ?? false;
      _biometricLock = prefs.getBool('setting_biometric') ?? false;
      _twoFactorAuth = prefs.getBool('setting_2fa') ?? false;
      _locationSharing = prefs.getBool('setting_location') ?? true;
      _autoAcceptRatings = prefs.getBool('setting_auto_rating') ?? false;
      _savePaymentInfo = prefs.getBool('setting_save_payment') ?? true;
      _analyticsOptIn = prefs.getBool('setting_analytics') ?? true;
      _compactView = prefs.getBool('setting_compact') ?? false;
      _autoBackup = prefs.getBool('setting_auto_backup') ?? true;
      _readReceipts = prefs.getBool('setting_read_receipts') ?? true;
      _onlineStatus = prefs.getBool('setting_online_status') ?? true;
      _dataSaver = prefs.getBool('setting_data_saver') ?? false;
      _crashReports = prefs.getBool('setting_crash_reports') ?? true;
      _soundEffects = prefs.getBool('setting_sound') ?? true;
      _hapticFeedback = prefs.getBool('setting_haptic') ?? true;
      _autoNightMode = prefs.getBool('setting_auto_night') ?? false;
      _showOnlineDriversOnly = prefs.getBool('setting_online_drivers') ?? false;
      _receiptAutoEmail = prefs.getBool('setting_receipt_email') ?? false;
      _priceAlerts = prefs.getBool('setting_price_alerts') ?? true;
      _surgeAlerts = prefs.getBool('setting_surge_alerts') ?? true;
      _weatherAlerts = prefs.getBool('setting_weather_alerts') ?? false;
      _weeklyDigest = prefs.getBool('setting_weekly_digest') ?? true;
      _selectedLanguage = prefs.getString('setting_language') ?? 'English';
      _selectedCurrency = prefs.getString('setting_currency') ?? 'PHP (₱)';
      _selectedMapStyle = prefs.getString('setting_map_style') ?? 'Standard';
      _preferredPayment = prefs.getString('setting_payment') ?? 'Cash on Delivery';
      _selectedFontSize = prefs.getString('setting_font_size') ?? 'Medium';
      _selectedDateFormat = prefs.getString('setting_date_format') ?? 'MM/DD/YYYY';
      _selectedDistanceUnit = prefs.getString('setting_distance_unit') ?? 'Kilometers';
      _selectedWeightUnit = prefs.getString('setting_weight_unit') ?? 'Kilograms';
      _appLockTimeout = prefs.getString('setting_lock_timeout') ?? '5 minutes';
      _selectedRegion = prefs.getString('setting_region') ?? 'Negros Occidental';
      _deliveryPriority = prefs.getString('setting_delivery_priority') ?? 'Standard';
      _defaultWeightKg = prefs.getDouble('setting_default_weight') ?? 10.0;
      _maxBookingsPerDay = prefs.getInt('setting_max_bookings') ?? 5;
      _selectedAccentIndex = prefs.getInt('setting_accent_color') ?? 0;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // ── Helpers ──────────────────────────────────────────────────

  void _showBottomPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...options.map((opt) => ListTile(
                title: Text(opt),
                trailing: currentValue == opt
                    ? const Icon(Icons.check, color: Color(0xFF1A56DB))
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 24),
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
              Text('Drag to set your most common shipment weight.',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
                _saveDouble('setting_default_weight', tempWeight);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaxBookingsDialog() {
    int temp = _maxBookingsPerDay;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Max Bookings Per Day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$temp bookings',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A56DB))),
              Slider(
                value: temp.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: '$temp',
                onChanged: (v) => setS(() => temp = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() => _maxBookingsPerDay = temp);
                _saveInt('setting_max_bookings', temp);
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
    final formKey = GlobalKey<FormState>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setS(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setS(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setS(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  validator: (v) => v != newCtrl.text ? 'Passwords do not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password changed successfully.'),
                        backgroundColor: Color(0xFF10B981)),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
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
            _linkedTile(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                linked: true,
                color: Colors.red),
            const Divider(height: 1),
            _linkedTile(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                linked: false,
                color: const Color(0xFF1877F2)),
            const Divider(height: 1),
            _linkedTile(
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

  Widget _linkedTile({
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

  void _showDataStorageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Storage & Data',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _storageRow('App Cache', '14.2 MB', Icons.storage),
            _storageRow('Offline Maps', '0 MB', Icons.map_outlined),
            _storageRow('Saved Photos', '3.1 MB', Icons.photo_library_outlined),
            _storageRow('Downloaded Receipts', '0.8 MB', Icons.receipt_long_outlined),
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
              child: Text(label, style: const TextStyle(fontSize: 15))),
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
    int selected = 0;
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
                          onTap: () => setS(() => selected = i + 1),
                          child: Icon(
                            i < selected
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
              onPressed: selected > 0
                  ? () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Thanks for rating us $selected star${selected > 1 ? 's' : ''}!'),
                            backgroundColor: const Color(0xFF10B981)),
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

  void _showHelpSupport() {
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
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final confirmCtrl = TextEditingController();
    const confirmText = 'DELETE';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Delete Account',
              style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'This action is permanent and cannot be undone. All your data, bookings, and history will be deleted.\n\nType DELETE to confirm:'),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                onChanged: (_) => setS(() {}),
                decoration: const InputDecoration(
                  hintText: 'Type DELETE here',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: confirmCtrl.text == confirmText
                  ? () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Account deletion request submitted.'),
                            backgroundColor: Colors.red),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),
              child: const Text('Delete My Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrustedDevicesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trusted Devices',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _deviceRow('iPhone 13 · iOS 17', 'Active now', true),
            const Divider(height: 1),
            _deviceRow('Samsung A26 · Android 14', '2 days ago', false),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign out all other devices',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceRow(String device, String lastSeen, bool isThisDevice) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.phone_android,
          color: Color(0xFF1A56DB), size: 24),
      title: Text(device,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(lastSeen,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      trailing: isThisDevice
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('This device',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46))),
            )
          : TextButton(
              onPressed: () {},
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red, fontSize: 13))),
    );
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Sessions',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('1 active session on your account',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            _sessionRow(
                'Bacolod City, PH',
                'iPhone 13 · PasabayBCD App',
                'Just now',
                true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionRow(
      String location, String device, String time, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: Color(0xFF1A56DB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(device,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                Text(time,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Current',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46))),
            ),
        ],
      ),
    );
  }

  void _showEmergencyContactDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: 'Maria Santos');
    final phoneCtrl = TextEditingController(text: '+63 917 000 0000');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Contact Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Phone Number'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (!RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(v.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Emergency contact saved.'),
                      backgroundColor: Color(0xFF10B981)),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Privacy Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  Text(
                    'Last updated: March 2026\n\n'
                    '1. Information We Collect\nWe collect information you provide directly to us, such as when you create an account, make a booking, or contact support. This includes name, contact details, and transaction data.\n\n'
                    '2. How We Use Your Information\nWe use the information to provide, maintain, and improve our services, process transactions, send notifications, and comply with legal obligations.\n\n'
                    '3. Data Sharing\nWe do not sell your personal information. We may share data with drivers and partners solely to fulfill your bookings.\n\n'
                    '4. Data Retention\nWe retain your data for as long as your account is active or as needed to provide services.\n\n'
                    '5. Your Rights\nYou may request access, correction, or deletion of your personal data by contacting support@pasabaybcd.com.\n\n'
                    '6. Contact Us\nFor privacy concerns, email us at privacy@pasabaybcd.com.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsOfServiceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Terms of Service',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  Text(
                    'Last updated: March 2026\n\n'
                    '1. Acceptance of Terms\nBy using PasabayBCD, you agree to be bound by these Terms of Service.\n\n'
                    '2. Use of Service\nYou agree to use the service only for lawful purposes and in accordance with these terms.\n\n'
                    '3. Account Responsibility\nYou are responsible for maintaining the confidentiality of your account credentials.\n\n'
                    '4. Prohibited Activities\nYou may not use the service for fraudulent transactions, illegal shipments, or harassment of drivers.\n\n'
                    '5. Limitation of Liability\nPasabayBCD is not liable for indirect or consequential damages arising from the use of the service.\n\n'
                    '6. Termination\nWe reserve the right to suspend or terminate accounts that violate these terms.\n\n'
                    '7. Contact\nFor questions, email legal@pasabaybcd.com.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWhatsNewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text("What's New in v1.0.0",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  _WhatsNewItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    description: 'Full dark theme support with persistent preference.',
                  ),
                  _WhatsNewItem(
                    icon: Icons.color_lens_outlined,
                    title: 'Accent Colors',
                    description: 'Choose from 5 accent colors: Blue, Green, Orange, Purple, Red.',
                  ),
                  _WhatsNewItem(
                    icon: Icons.settings_outlined,
                    title: 'Persistent Settings',
                    description: 'All your settings are now saved and restored on app launch.',
                  ),
                  _WhatsNewItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Booking System',
                    description: 'Book deliveries, track drivers, and manage shipments.',
                  ),
                  _WhatsNewItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Transaction Receipts',
                    description: 'View and download receipts for completed bookings.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got It'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareViaClipboard() {
    const shareText =
        'Check out PasabayBCD — the easiest way to book deliveries in Bacolod City! Download the app now.';
    Clipboard.setData(const ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Share link copied to clipboard!'),
          backgroundColor: Color(0xFF10B981)),
    );
  }

  void _showTransactionReceipts() {
    final dataStore = DataStore();
    final bookings = dataStore.bookings ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Transaction Receipts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            Expanded(
              child: bookings.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No receipts yet.\nComplete a booking to see receipts here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final b = bookings[i];
                        return ListTile(
                          leading: const Icon(Icons.receipt_outlined,
                              color: Color(0xFF1A56DB)),
                          title: Text(b.id ?? 'Booking #${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(b.status ?? 'Completed',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                          trailing: Text(
                            '₱${b.price?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                                color: Color(0xFF1A56DB),
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
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

  void _showShippingAnalytics() {
    final dataStore = DataStore();
    final bookings = dataStore.bookings ?? [];
    final total = bookings.length;
    final completed = bookings.where((b) => b.status == 'Completed').length;
    final totalSpend = bookings.fold<double>(
        0, (sum, b) => sum + (b.price ?? 0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Shipping Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  _analyticsCard(
                      icon: Icons.local_shipping_outlined,
                      label: 'Total Bookings',
                      value: '$total',
                      color: const Color(0xFF1A56DB)),
                  const SizedBox(height: 12),
                  _analyticsCard(
                      icon: Icons.check_circle_outline,
                      label: 'Completed',
                      value: '$completed',
                      color: const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _analyticsCard(
                      icon: Icons.payments_outlined,
                      label: 'Total Spend',
                      value: '₱${totalSpend.toStringAsFixed(2)}',
                      color: const Color(0xFFF59E0B)),
                  const SizedBox(height: 12),
                  _analyticsCard(
                      icon: Icons.trending_up_outlined,
                      label: 'Avg. Per Booking',
                      value: total > 0
                          ? '₱${(totalSpend / total).toStringAsFixed(2)}'
                          : '₱0.00',
                      color: const Color(0xFF8B5CF6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600)),
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();

    // Font size scale via MediaQuery textScaler
    final double fontScale;
    switch (_selectedFontSize) {
      case 'Small':
        fontScale = 0.85;
        break;
      case 'Large':
        fontScale = 1.15;
        break;
      case 'Extra Large':
        fontScale = 1.3;
        break;
      default:
        fontScale = 1.0;
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontScale),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF111827), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade100, height: 1),
          ),
        ),
        body: ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [

            // ── ACCOUNT ─────────────────────────────────────────
            _sectionHeader('Account'),
            _settingsCard([
              _menuTile(
                icon: Icons.verified_user_outlined,
                label: 'Business Verification (KYC)',
                subtitle: 'Verify your business identity',
                color: const Color(0xFF1A56DB),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KycVerificationScreen())),
              ),
              _divider(),
              _menuTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                subtitle: 'Update your login password',
                color: Colors.grey.shade600,
                onTap: _showChangePasswordDialog,
              ),
              _divider(),
              _menuTile(
                icon: Icons.link,
                label: 'Linked Accounts',
                subtitle: 'Google, Facebook, mobile number',
                color: Colors.grey.shade600,
                onTap: _showLinkedAccountsDialog,
              ),
              _divider(),
              _menuTile(
                icon: Icons.badge_outlined,
                label: 'Merchant ID',
                subtitle: 'Your unique merchant identifier',
                color: Colors.grey.shade600,
                trailing: Text(
                  '#${(dataStore.userId ?? 0).toString().padLeft(6, '0')}',
                  style: const TextStyle(
                      color: Color(0xFF1A56DB),
                      fontWeight: FontWeight.w600),
                ),
                onTap: () {},
              ),
              _divider(),
              _menuTile(
                icon: Icons.phone_in_talk_outlined,
                label: 'Emergency Contact',
                subtitle: 'Set a contact for urgent situations',
                color: Colors.grey.shade600,
                onTap: _showEmergencyContactDialog,
              ),
              _divider(),
              _menuTile(
                icon: Icons.business_outlined,
                label: 'Business Region',
                subtitle: 'Your primary delivery region',
                color: Colors.grey.shade600,
                trailing: Text(_selectedRegion,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Business Region',
                  options: [
                    'Negros Occidental',
                    'Bacolod City',
                    'Iloilo City',
                    'Cebu City',
                    'Davao City',
                  ],
                  currentValue: _selectedRegion,
                  onSelected: (v) {
                    setState(() => _selectedRegion = v);
                    _saveString('setting_region', v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── NOTIFICATIONS ────────────────────────────────────
            _sectionHeader('Notifications'),
            _settingsCard([
              _switchTile(
                icon: Icons.local_shipping_outlined,
                label: 'Booking Updates',
                subtitle: 'Push alerts on every booking status change',
                value: _notifBookingUpdates,
                onChanged: (v) {
                  setState(() => _notifBookingUpdates = v);
                  _saveBool('setting_notif_booking', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.directions_car_outlined,
                label: 'Driver Arrival Alerts',
                subtitle: 'Notify when your driver is nearby',
                value: _notifDriverArrival,
                onChanged: (v) {
                  setState(() => _notifDriverArrival = v);
                  _saveBool('setting_notif_driver', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.local_offer_outlined,
                label: 'Promos & Offers',
                subtitle: 'Receive discount and promo alerts',
                value: _notifPromos,
                onChanged: (v) {
                  setState(() => _notifPromos = v);
                  _saveBool('setting_notif_promos', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.sms_outlined,
                label: 'SMS Notifications',
                subtitle: 'Receive updates via text message',
                value: _notifSMS,
                onChanged: (v) {
                  setState(() => _notifSMS = v);
                  _saveBool('setting_notif_sms', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.email_outlined,
                label: 'Email Notifications',
                subtitle: 'Get receipts and summaries by email',
                value: _notifEmail,
                onChanged: (v) {
                  setState(() => _notifEmail = v);
                  _saveBool('setting_notif_email', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.trending_up_outlined,
                label: 'Price Surge Alerts',
                subtitle: 'Get notified when delivery prices spike',
                value: _surgeAlerts,
                onChanged: (v) {
                  setState(() => _surgeAlerts = v);
                  _saveBool('setting_surge_alerts', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.price_change_outlined,
                label: 'Price Drop Alerts',
                subtitle: 'Alert when prices in your route drop',
                value: _priceAlerts,
                onChanged: (v) {
                  setState(() => _priceAlerts = v);
                  _saveBool('setting_price_alerts', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.cloud_outlined,
                label: 'Weather Alerts',
                subtitle: 'Delays due to bad weather near you',
                value: _weatherAlerts,
                onChanged: (v) {
                  setState(() => _weatherAlerts = v);
                  _saveBool('setting_weather_alerts', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.summarize_outlined,
                label: 'Weekly Digest',
                subtitle: 'Summary of your weekly shipment activity',
                value: _weeklyDigest,
                onChanged: (v) {
                  setState(() => _weeklyDigest = v);
                  _saveBool('setting_weekly_digest', v);
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── BOOKING PREFERENCES ──────────────────────────────
            _sectionHeader('Booking Preferences'),
            _settingsCard([
              _menuTile(
                icon: Icons.payments_outlined,
                label: 'Preferred Payment',
                subtitle: 'Default payment method for bookings',
                color: Colors.grey.shade600,
                trailing: Text(_preferredPayment,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Preferred Payment Method',
                  options: [
                    'Cash on Delivery',
                    'GCash',
                    'Maya',
                    'Bank Transfer',
                    'Credit / Debit Card',
                  ],
                  currentValue: _preferredPayment,
                  onSelected: (v) {
                    setState(() => _preferredPayment = v);
                    _saveString('setting_payment', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.scale_outlined,
                label: 'Default Cargo Weight',
                subtitle: 'Pre-fill weight field in new bookings',
                color: Colors.grey.shade600,
                trailing: Text(
                    '${_defaultWeightKg.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: _showWeightDialog,
              ),
              _divider(),
              _menuTile(
                icon: Icons.local_shipping_outlined,
                label: 'Delivery Priority',
                subtitle: 'Choose default delivery speed tier',
                color: Colors.grey.shade600,
                trailing: Text(_deliveryPriority,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Delivery Priority',
                  options: ['Standard', 'Express', 'Overnight'],
                  currentValue: _deliveryPriority,
                  onSelected: (v) {
                    setState(() => _deliveryPriority = v);
                    _saveString('setting_delivery_priority', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.format_list_numbered_outlined,
                label: 'Max Bookings Per Day',
                subtitle: 'Limit daily bookings to avoid overload',
                color: Colors.grey.shade600,
                trailing: Text('$_maxBookingsPerDay',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: _showMaxBookingsDialog,
              ),
              _divider(),
              _switchTile(
                icon: Icons.person_search_outlined,
                label: 'Online Drivers Only',
                subtitle: 'Only show drivers currently available',
                value: _showOnlineDriversOnly,
                onChanged: (v) {
                  setState(() => _showOnlineDriversOnly = v);
                  _saveBool('setting_online_drivers', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.star_outline,
                label: 'Auto-Accept Ratings',
                subtitle: 'Auto-submit 5-star rating after delivery',
                value: _autoAcceptRatings,
                onChanged: (v) {
                  setState(() => _autoAcceptRatings = v);
                  _saveBool('setting_auto_rating', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.credit_card_outlined,
                label: 'Save Payment Info',
                subtitle: 'Securely store card details for faster checkout',
                value: _savePaymentInfo,
                onChanged: (v) {
                  setState(() => _savePaymentInfo = v);
                  _saveBool('setting_save_payment', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.receipt_outlined,
                label: 'Auto-Email Receipts',
                subtitle: 'Send receipt to your email after each booking',
                value: _receiptAutoEmail,
                onChanged: (v) {
                  setState(() => _receiptAutoEmail = v);
                  _saveBool('setting_receipt_email', v);
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── SECURITY & PRIVACY ───────────────────────────────
            _sectionHeader('Security & Privacy'),
            _settingsCard([
              _switchTile(
                icon: Icons.fingerprint,
                label: 'Biometric Login',
                subtitle: 'Use fingerprint or Face ID to unlock',
                value: _biometricLock,
                onChanged: (v) {
                  setState(() => _biometricLock = v);
                  _saveBool('setting_biometric', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.security,
                label: 'Two-Factor Authentication',
                subtitle: 'Extra security layer on login',
                value: _twoFactorAuth,
                onChanged: (v) {
                  setState(() => _twoFactorAuth = v);
                  _saveBool('setting_2fa', v);
                },
              ),
              _divider(),
              _menuTile(
                icon: Icons.timer_outlined,
                label: 'App Lock Timeout',
                subtitle: 'Auto-lock after inactivity',
                color: Colors.grey.shade600,
                trailing: Text(_appLockTimeout,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'App Lock Timeout',
                  options: [
                    '1 minute',
                    '5 minutes',
                    '15 minutes',
                    '30 minutes',
                    'Never',
                  ],
                  currentValue: _appLockTimeout,
                  onSelected: (v) {
                    setState(() => _appLockTimeout = v);
                    _saveString('setting_lock_timeout', v);
                  },
                ),
              ),
              _divider(),
              _switchTile(
                icon: Icons.location_on_outlined,
                label: 'Location Sharing',
                subtitle: 'Allow drivers to see your live location',
                value: _locationSharing,
                onChanged: (v) {
                  setState(() => _locationSharing = v);
                  _saveBool('setting_location', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.visibility_outlined,
                label: 'Online Status',
                subtitle: 'Show when you are active in the app',
                value: _onlineStatus,
                onChanged: (v) {
                  setState(() => _onlineStatus = v);
                  _saveBool('setting_online_status', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.done_all_outlined,
                label: 'Read Receipts',
                subtitle: 'Let drivers know when you read messages',
                value: _readReceipts,
                onChanged: (v) {
                  setState(() => _readReceipts = v);
                  _saveBool('setting_read_receipts', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.analytics_outlined,
                label: 'Analytics & Diagnostics',
                subtitle: 'Share anonymous usage data',
                value: _analyticsOptIn,
                onChanged: (v) {
                  setState(() => _analyticsOptIn = v);
                  _saveBool('setting_analytics', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.bug_report_outlined,
                label: 'Crash Reports',
                subtitle: 'Automatically send crash logs',
                value: _crashReports,
                onChanged: (v) {
                  setState(() => _crashReports = v);
                  _saveBool('setting_crash_reports', v);
                },
              ),
              _divider(),
              _menuTile(
                icon: Icons.devices_outlined,
                label: 'Trusted Devices',
                subtitle: 'Manage devices with saved login',
                color: Colors.grey.shade600,
                onTap: _showTrustedDevicesSheet,
              ),
              _divider(),
              _menuTile(
                icon: Icons.history_toggle_off_outlined,
                label: 'Active Sessions',
                subtitle: 'See where you are logged in',
                color: Colors.grey.shade600,
                onTap: _showActiveSessions,
              ),
            ]),
            const SizedBox(height: 16),

            // ── APPEARANCE ───────────────────────────────────────
            _sectionHeader('Appearance'),
            _settingsCard([
              _switchTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                subtitle: 'Switch to dark color theme',
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _saveBool('setting_dark_mode', v);
                  appThemeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.brightness_auto_outlined,
                label: 'Auto Night Mode',
                subtitle: 'Switch to dark mode at sunset automatically',
                value: _autoNightMode,
                onChanged: (v) {
                  setState(() => _autoNightMode = v);
                  _saveBool('setting_auto_night', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.view_compact_outlined,
                label: 'Compact View',
                subtitle: 'Show more items in list screens',
                value: _compactView,
                onChanged: (v) {
                  setState(() => _compactView = v);
                  _saveBool('setting_compact', v);
                },
              ),
              _divider(),
              // Accent color picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A56DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.color_lens_outlined,
                          size: 20, color: Color(0xFF1A56DB)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Accent Color',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          Text('Current: ${_accentNames[_selectedAccentIndex]}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(kAccentColors.length, (i) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedAccentIndex = i);
                            _saveInt('setting_accent_color', i);
                            appAccentColor.value = kAccentColors[i];
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: kAccentColors[i],
                              shape: BoxShape.circle,
                              border: _selectedAccentIndex == i
                                  ? Border.all(
                                      color: Colors.black45, width: 2.5)
                                  : null,
                            ),
                            child: _selectedAccentIndex == i
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.text_fields_outlined,
                label: 'Font Size',
                subtitle: 'Adjust text size throughout the app',
                color: Colors.grey.shade600,
                trailing: Text(_selectedFontSize,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Font Size',
                  options: ['Small', 'Medium', 'Large', 'Extra Large'],
                  currentValue: _selectedFontSize,
                  onSelected: (v) {
                    setState(() => _selectedFontSize = v);
                    _saveString('setting_font_size', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.language,
                label: 'Language',
                subtitle: 'App display language',
                color: Colors.grey.shade600,
                trailing: Text(_selectedLanguage,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Select Language',
                  options: [
                    'English',
                    'Filipino',
                    'Hiligaynon',
                    'Cebuano',
                    'Ilocano',
                  ],
                  currentValue: _selectedLanguage,
                  onSelected: (v) {
                    setState(() => _selectedLanguage = v);
                    _saveString('setting_language', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.attach_money_outlined,
                label: 'Currency Display',
                subtitle: 'Currency format shown in the app',
                color: Colors.grey.shade600,
                trailing: Text(_selectedCurrency,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Select Currency',
                  options: ['PHP (₱)', 'USD (\$)', 'EUR (€)'],
                  currentValue: _selectedCurrency,
                  onSelected: (v) {
                    setState(() => _selectedCurrency = v);
                    _saveString('setting_currency', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.map_outlined,
                label: 'Map Style',
                subtitle: 'Visual style of the delivery map',
                color: Colors.grey.shade600,
                trailing: Text(_selectedMapStyle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Map Style',
                  options: ['Standard', 'Satellite', 'Terrain', 'Dark'],
                  currentValue: _selectedMapStyle,
                  onSelected: (v) {
                    setState(() => _selectedMapStyle = v);
                    _saveString('setting_map_style', v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── REGIONAL & UNITS ─────────────────────────────────
            _sectionHeader('Regional & Units'),
            _settingsCard([
              _menuTile(
                icon: Icons.calendar_today_outlined,
                label: 'Date Format',
                subtitle: 'How dates are displayed',
                color: Colors.grey.shade600,
                trailing: Text(_selectedDateFormat,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Date Format',
                  options: [
                    'MM/DD/YYYY',
                    'DD/MM/YYYY',
                    'YYYY-MM-DD',
                  ],
                  currentValue: _selectedDateFormat,
                  onSelected: (v) {
                    setState(() => _selectedDateFormat = v);
                    _saveString('setting_date_format', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.straighten_outlined,
                label: 'Distance Unit',
                subtitle: 'Unit used for delivery distance',
                color: Colors.grey.shade600,
                trailing: Text(_selectedDistanceUnit,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Distance Unit',
                  options: ['Kilometers', 'Miles'],
                  currentValue: _selectedDistanceUnit,
                  onSelected: (v) {
                    setState(() => _selectedDistanceUnit = v);
                    _saveString('setting_distance_unit', v);
                  },
                ),
              ),
              _divider(),
              _menuTile(
                icon: Icons.monitor_weight_outlined,
                label: 'Weight Unit',
                subtitle: 'Unit used for cargo weight',
                color: Colors.grey.shade600,
                trailing: Text(_selectedWeightUnit,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                onTap: () => _showBottomPicker(
                  title: 'Weight Unit',
                  options: ['Kilograms', 'Pounds'],
                  currentValue: _selectedWeightUnit,
                  onSelected: (v) {
                    setState(() => _selectedWeightUnit = v);
                    _saveString('setting_weight_unit', v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── AUDIO & FEEDBACK ─────────────────────────────────
            _sectionHeader('Audio & Feedback'),
            _settingsCard([
              _switchTile(
                icon: Icons.volume_up_outlined,
                label: 'Sound Effects',
                subtitle: 'Play sounds on booking actions',
                value: _soundEffects,
                onChanged: (v) {
                  setState(() => _soundEffects = v);
                  _saveBool('setting_sound', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.vibration,
                label: 'Haptic Feedback',
                subtitle: 'Vibrate on button taps and alerts',
                value: _hapticFeedback,
                onChanged: (v) {
                  setState(() => _hapticFeedback = v);
                  _saveBool('setting_haptic', v);
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── DATA & STORAGE ───────────────────────────────────
            _sectionHeader('Data & Storage'),
            _settingsCard([
              _switchTile(
                icon: Icons.signal_cellular_alt_outlined,
                label: 'Data Saver',
                subtitle: 'Reduce data usage on mobile networks',
                value: _dataSaver,
                onChanged: (v) {
                  setState(() => _dataSaver = v);
                  _saveBool('setting_data_saver', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.backup_outlined,
                label: 'Auto Backup',
                subtitle: 'Automatically back up booking history',
                value: _autoBackup,
                onChanged: (v) {
                  setState(() => _autoBackup = v);
                  _saveBool('setting_auto_backup', v);
                },
              ),
              _divider(),
              _menuTile(
                icon: Icons.storage_outlined,
                label: 'Storage & Data',
                subtitle: 'View usage and clear cache',
                color: Colors.grey.shade600,
                onTap: _showDataStorageSheet,
              ),
            ]),
            const SizedBox(height: 16),

            // ── ACTIVITY ─────────────────────────────────────────
            _sectionHeader('Activity'),
            _settingsCard([
              _menuTile(
                icon: Icons.history,
                label: 'Shipment History',
                subtitle: 'View all past bookings',
                color: Colors.grey.shade600,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BookingHistoryScreen())),
              ),
              _divider(),
              _menuTile(
                icon: Icons.notifications_outlined,
                label: 'Notification Inbox',
                subtitle: 'All your recent alerts',
                color: Colors.grey.shade600,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen())),
              ),
              _divider(),
              _menuTile(
                icon: Icons.receipt_long_outlined,
                label: 'Transaction Receipts',
                subtitle: 'Download or view receipts',
                color: Colors.grey.shade600,
                onTap: _showTransactionReceipts,
              ),
              _divider(),
              _menuTile(
                icon: Icons.bar_chart_outlined,
                label: 'Shipping Analytics',
                subtitle: 'Insights on your shipping patterns',
                color: Colors.grey.shade600,
                onTap: _showShippingAnalytics,
              ),
            ]),
            const SizedBox(height: 16),

            // ── SUPPORT & INFO ───────────────────────────────────
            _sectionHeader('Support & Info'),
            _settingsCard([
              _menuTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                subtitle: 'Call, email, or chat with support',
                color: Colors.grey.shade600,
                onTap: _showHelpSupport,
              ),
              _divider(),
              _menuTile(
                icon: Icons.question_answer_outlined,
                label: 'FAQs',
                subtitle: 'Frequently asked questions',
                color: Colors.grey.shade600,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FaqScreen())),
              ),
              _divider(),
              _menuTile(
                icon: Icons.star_rate_outlined,
                label: 'Rate the App',
                subtitle: 'Leave a review on the app store',
                color: Colors.grey.shade600,
                onTap: _showRateAppDialog,
              ),
              _divider(),
              _menuTile(
                icon: Icons.share_outlined,
                label: 'Share PasabayBCD',
                subtitle: 'Invite friends and fellow merchants',
                color: Colors.grey.shade600,
                onTap: _shareViaClipboard,
              ),
              _divider(),
              _menuTile(
                icon: Icons.policy_outlined,
                label: 'Privacy Policy',
                subtitle: 'How we handle your data',
                color: Colors.grey.shade600,
                onTap: _showPrivacyPolicyModal,
              ),
              _divider(),
              _menuTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                subtitle: 'Our terms and conditions',
                color: Colors.grey.shade600,
                onTap: _showTermsOfServiceModal,
              ),
              _divider(),
              _menuTile(
                icon: Icons.new_releases_outlined,
                label: "What's New",
                subtitle: 'See the latest app updates',
                color: Colors.grey.shade600,
                onTap: _showWhatsNewSheet,
              ),
              _divider(),
              _menuTile(
                icon: Icons.info_outline,
                label: 'About PasabayBCD',
                subtitle: 'Version, credits, and licenses',
                color: Colors.grey.shade600,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AboutScreen())),
              ),
            ]),
            const SizedBox(height: 16),

            // ── DANGER ZONE ──────────────────────────────────────
            _sectionHeader('Danger Zone'),
            _settingsCard([
              _menuTile(
                icon: Icons.logout,
                label: 'Log Out',
                subtitle: 'Sign out of your account',
                color: Colors.red,
                onTap: () => _showLogoutDialog(dataStore),
              ),
              _divider(),
              _menuTile(
                icon: Icons.delete_forever_outlined,
                label: 'Delete Account',
                subtitle: 'Permanently remove your account and data',
                color: Colors.red.shade700,
                onTap: _showDeleteAccountDialog,
              ),
            ]),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'PasabayBCD v1.0.0 · BSIT 3-B',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Sub-widget builders ──────────────────────────────────────

  Widget _sectionHeader(String title) {
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

  Widget _settingsCard(List<Widget> children) {
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

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _switchTile({
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
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1A56DB),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    String? subtitle,
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
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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

// ── What's New list item widget ──────────────────────────────
class _WhatsNewItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WhatsNewItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1A56DB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
