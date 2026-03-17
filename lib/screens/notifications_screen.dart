// ============================================================
// Screen: Notifications
// Fetches and displays user notifications from the backend API
// ============================================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  /// Fetches notifications for the current user from the API
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final userId = DataStore().userId ?? 0;
    final uri = Uri.parse(
      'http://ov3.238.mytemp.website/pasabaybcd/api/notifications.php?user_id=$userId',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  /// Marks all notifications as read via POST
  Future<void> _markAllRead() async {
    final userId = DataStore().userId ?? 0;
    final uri = Uri.parse(
      'http://ov3.238.mytemp.website/pasabaybcd/api/notifications.php',
    );

    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'mark_all_read',
          'user_id': userId,
        }),
      );

      // Refresh the list after marking as read
      setState(() {
        _notificationsFuture = _fetchNotifications();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not mark as read. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Mark all as read button
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(fontSize: 14, color: Color(0xFF1A56DB)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 52, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load notifications',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _notificationsFuture = _fetchNotifications();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildNotificationCard(notifications[index]);
            },
          );
        },
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 68, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = (notification['is_read'] == 1 || notification['is_read'] == true);
    final String type = notification['type'] ?? 'system';

    // Choose icon and color based on notification type
    IconData icon;
    Color iconColor;
    switch (type) {
      case 'delivery':
        icon = Icons.check_circle_outline;
        iconColor = const Color(0xFF10B981);
        break;
      case 'driver':
        icon = Icons.local_shipping_outlined;
        iconColor = const Color(0xFF1A56DB);
        break;
      case 'booking':
        icon = Icons.event_available;
        iconColor = const Color(0xFF7C3AED);
        break;
      case 'promo':
        icon = Icons.local_offer_outlined;
        iconColor = const Color(0xFFD97706);
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = const Color(0xFF065F46);
        break;
      default: // system
        icon = Icons.info_outline;
        iconColor = Colors.grey;
    }

    // Format the created_at timestamp into a readable string
    final String timeText = notification['created_at'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: isRead
            ? null
            : const Border(left: BorderSide(color: Color(0xFF1A56DB), width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification type icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A56DB),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['body'] as String? ?? '',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  timeText,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
