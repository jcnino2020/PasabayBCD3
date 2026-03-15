// ============================================================
// Screen: Notifications
// Dedicated full-screen view of user notifications
// ============================================================

import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notification data — in a real app these would come from an API or
    // local push notifications. Each entry has a type to determine the icon.
    final notifications = [
      {
        'type': 'delivery',
        'title': 'Delivery Complete',
        'body': 'Your shipment to Mansilingan has been delivered successfully.',
        'time': '2 mins ago',
        'isRead': false,
      },
      {
        'type': 'driver',
        'title': 'Driver Arrived',
        'body': 'Manong Juan has arrived at Libertad Market for pickup.',
        'time': '15 mins ago',
        'isRead': false,
      },
      {
        'type': 'booking',
        'title': 'Booking Confirmed',
        'body': 'Your trip to Bata via Multicab has been confirmed.',
        'time': '1 hr ago',
        'isRead': true,
      },
      {
        'type': 'promo',
        'title': 'Weekend Promo!',
        'body': 'Get 15% off your next booking this Saturday & Sunday.',
        'time': '3 hrs ago',
        'isRead': true,
      },
      {
        'type': 'wallet',
        'title': 'Top-Up Successful',
        'body': 'Your wallet has been topped up with ₱500 via GCash.',
        'time': '1 day ago',
        'isRead': true,
      },
      {
        'type': 'system',
        'title': 'App Update Available',
        'body': 'PasabayBCD v1.1 is now available. Update for new features!',
        'time': '2 days ago',
        'isRead': true,
      },
    ];

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
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _buildNotificationCard(n);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] as bool;

    // Choose icon and color based on notification type
    IconData icon;
    Color iconColor;
    switch (notification['type']) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Unread notifications have a subtle blue tint
        color: isRead ? Colors.white : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        // Unread items get a left accent border
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
            child: Icon(icon, color: iconColor, size: 20),
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
                    Text(
                      notification['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    // Unread indicator dot
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
                  notification['body'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  notification['time'] as String,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
