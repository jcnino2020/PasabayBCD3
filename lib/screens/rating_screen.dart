// ============================================================
// Screen: Driver Rating & Review
// Allows users to rate and leave feedback after a delivery
// ============================================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking.dart';
import 'main_screen.dart';

class RatingScreen extends StatefulWidget {
  final String driverName;
  final String truckType;
  final int driverId;      // Driver's DB id — needed for the ratings API
  final String? bookingId; // Optional booking reference

  const RatingScreen({
    super.key,
    required this.driverName,
    required this.truckType,
    required this.driverId,
    this.bookingId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // The selected star rating (1-5), starts at 0 meaning no selection yet
  int _selectedRating = 0;
  // Controller for the optional text review
  final _reviewController = TextEditingController();
  // Quick feedback tags the user can tap
  final List<String> _feedbackTags = [
    'On Time',
    'Careful Handler',
    'Friendly',
    'Clean Vehicle',
    'Fast Delivery',
    'Good Communication',
  ];
  // Which tags the user has selected
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// Submits the rating to the backend API
  void _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse(
        'http://ov3.238.mytemp.website/pasabaybcd/api/ratings.php',
      );

      final body = {
        'user_id': DataStore().userId ?? 0,
        'driver_id': widget.driverId,
        'rating': _selectedRating,
        'tags': _selectedTags.toList().join(','),
        'review_text': _reviewController.text.trim(),
      };

      // Include booking_id if available
      if (widget.bookingId != null) {
        body['booking_id'] = widget.bookingId!;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        // Show error but still navigate home so user isn't stuck
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save rating. Please try again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Your rating was not saved.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        // Navigate back to home regardless of success/failure
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
          onPressed: () {
            // Allow skipping the review
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Rate Your Experience',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Driver info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Driver avatar placeholder
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFEBF2FF),
                    child: Icon(Icons.person, size: 36, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.driverName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.truckType,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // "How was your experience?" label
            const Text(
              'How was your delivery?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),

            // Star rating row — tap a star to select that rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starNumber),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starNumber <= _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: starNumber <= _selectedRating
                          ? const Color(0xFFFBBF24)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            // Rating label text
            Text(
              _selectedRating == 0
                  ? 'Tap a star to rate'
                  : _selectedRating <= 2
                      ? 'Could be better'
                      : _selectedRating <= 3
                          ? 'It was okay'
                          : _selectedRating <= 4
                              ? 'Good experience!'
                              : 'Excellent!',
              style: TextStyle(
                fontSize: 13,
                color: _selectedRating == 0 ? Colors.grey.shade400 : const Color(0xFF1A56DB),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            // Quick feedback tags
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QUICK FEEDBACK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedbackTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1A56DB) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Optional text review
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ADDITIONAL COMMENTS (OPTIONAL)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us more about your experience...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A56DB), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56DB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF1A56DB).withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Skip button
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
                  (route) => false,
                );
              },
              child: Text(
                'Skip for now',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
