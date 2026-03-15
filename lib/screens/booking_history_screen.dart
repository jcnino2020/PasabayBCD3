// ============================================================
// Screen: Booking History
// Dedicated full-screen view of past bookings with status badges
// ============================================================

import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();
    final transactions = dataStore.transactions;

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
          'Shipment History',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : _buildTransactionList(transactions),
    );
  }

  // Shown when there are no transactions yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No shipments yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your completed deliveries will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        // Determine if this is a shipment expense or a top-up
        final isExpense = tx.amount < 0;
        // Assign a simulated status based on position in the list
        // First item = most recent, could be "In Transit"; rest are "Delivered"
        final status = index == 0 && DataStore().activeBooking != null
            ? 'In Transit'
            : isExpense
                ? 'Delivered'
                : 'Top Up';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon based on transaction type
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isExpense ? const Color(0xFFEBF2FF) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpense ? Icons.local_shipping_outlined : Icons.account_balance_wallet_outlined,
                  color: isExpense ? const Color(0xFF1A56DB) : const Color(0xFF065F46),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          tx.date,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        _buildStatusBadge(status),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '${isExpense ? '-' : '+'}₱${tx.amount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isExpense ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Returns a small colored badge showing the delivery status
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'In Transit':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'Delivered':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      default: // Top Up
        bgColor = const Color(0xFFEBF2FF);
        textColor = const Color(0xFF1A56DB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
