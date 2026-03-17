import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I book a truck?',
      'a': 'Go to the "Trips" tab, select a truck that matches your route, and click "Book Space". Fill in your cargo details and confirm.'
    },
    {
      'q': 'How is the fee calculated?',
      'a': 'Fees are based on the base price of the truck plus any additional weight charges if your cargo exceeds the standard allowance.'
    },
    {
      'q': 'Can I track my cargo?',
      'a': 'Yes! Once a driver accepts your booking, you can track them in real-time via the "Active" tab.'
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'Currently, we accept Cash on Delivery (COD) and wallet balance payments.'
    },
    {
      'q': 'How do I verify my account?',
      'a': 'Go to Profile > Business Verification (KYC) and upload a valid government ID and your business permit.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: ExpansionTile(
              title: Text(_faqs[index]['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [Text(_faqs[index]['a']!, style: TextStyle(color: Colors.grey.shade600, height: 1.5))],
            ),
          );
        },
      ),
      ),
    );
  }
}