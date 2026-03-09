// ============================================================
// Screen 09: Savings Dashboard / Financials Screen
// Shows total savings and recent transaction history
// ============================================================

import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/bottom_nav_bar.dart';

class SavingsDashboardScreen extends StatefulWidget {
  const SavingsDashboardScreen({super.key});

  @override
  State<SavingsDashboardScreen> createState() =>
      _SavingsDashboardScreenState();
}

class _SavingsDashboardScreenState extends State<SavingsDashboardScreen> {

  // Simulate wallet balance state
  // Data is now pulled from DataStore in build

  void _showTopUpModal(BuildContext context, DataStore dataStore) {
    int selectedAmount = 200;
    String selectedMethod = 'GCash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Up Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('SELECT AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [100, 200, 500, 1000].map((amount) {
                    final isSelected = selectedAmount == amount;
                    return ChoiceChip(
                      label: Text('₱$amount'),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1A56DB),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      onSelected: (selected) {
                        setModalState(() => selectedAmount = amount);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('PAYMENT METHOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                ...['GCash', 'Maya', 'Bank Transfer'].map((method) => RadioListTile(
                  title: Text(method),
                  value: method,
                  groupValue: selectedMethod,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF1A56DB),
                  onChanged: (val) {
                    setModalState(() => selectedMethod = val.toString());
                  },
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Update DataStore
                      setState(() {
                        dataStore.balance += selectedAmount;
                        dataStore.transactions.insert(0, Transaction(
                          date: 'Just now',
                          label: 'Top Up via $selectedMethod',
                          amount: selectedAmount.toDouble(),
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully added ₱$selectedAmount to wallet!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                    child: const Text('CONFIRM TOP UP'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showFinancialsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem<String>(
          value: 'export',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined),
            title: Text('Export Statement'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'payment',
          child: ListTile(
            leading: Icon(Icons.credit_card_outlined),
            title: Text('Payment Methods'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'export') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statement exported successfully! (Simulated)')),
        );
      } else if (value == 'payment') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigating to Payment Methods... (Simulated)')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();
    
    // Calculate dynamic stats based on transaction history
    final expenseTransactions = dataStore.transactions.where((t) => t.amount < 0).toList();
    final tripsCount = expenseTransactions.length;
    final totalSpent = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount.abs());
    // Mock savings calculation (e.g., 20% saved compared to solo booking)
    final estimatedSavings = totalSpent * 0.20; 
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FINANCIALS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () => _showFinancialsMenu(context),
                      );
                    }
                  ),
                ],
              ),
            ),

            // Savings summary card - dark blue card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SAVINGS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${dataStore.totalSavings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BALANCE: ₱${dataStore.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        // Top Up button
                        GestureDetector(
                          onTap: () => _showTopUpModal(context, dataStore),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A56DB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'TOP UP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                      'Trips', '$tripsCount', Icons.local_shipping_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard(
                      'Est. Savings', '₱${estimatedSavings.toStringAsFixed(0)}', Icons.savings_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard('Total Spent', '₱${totalSpent.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent transactions header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (ctx) => Container(
                          padding: const EdgeInsets.all(20),
                          height: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('All Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: dataStore.transactions.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final tx = dataStore.transactions[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(tx.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text(tx.date),
                                      trailing: Text('₱${tx.amount.abs().toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount < 0 ? Colors.red : Colors.green)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1A56DB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transactions list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: dataStore.transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = dataStore.transactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        // Transaction icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              tx.date,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '₱${tx.amount.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: tx.amount < 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
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

  // Small stat card widget (reused 3 times in this screen)
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1A56DB)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
