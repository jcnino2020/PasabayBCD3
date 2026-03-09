import 'package:flutter/material.dart';
import '../models/booking.dart'; // For DataStore

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  bool _isSubmitting = false;
  bool _idUploaded = false;

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();
    final isVerified = dataStore.isKycVerified;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Business Verification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isVerified ? _buildVerifiedState() : _buildForm(dataStore),
    );
  }

  Widget _buildVerifiedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 80, color: Color(0xFF10B981)),
          const SizedBox(height: 24),
          const Text(
            'You are Verified!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your business identity has been confirmed.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(DataStore dataStore) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify your Identity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a valid government ID and business permit to unlock full features.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          
          const TextField(
            decoration: InputDecoration(labelText: 'Full Legal Name'),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Business Permit Number'),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => setState(() => _idUploaded = !_idUploaded),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _idUploaded ? const Color(0xFFECFDF5) : Colors.white,
                border: Border.all(
                  color: _idUploaded ? const Color(0xFF10B981) : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _idUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                    size: 40,
                    color: _idUploaded ? const Color(0xFF10B981) : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _idUploaded ? 'ID Uploaded' : 'Tap to upload Valid ID',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _idUploaded ? const Color(0xFF065F46) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      setState(() => _isSubmitting = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;
                      
                      setState(() {
                        dataStore.isKycVerified = true;
                        _isSubmitting = false;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification Successful!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('SUBMIT VERIFICATION'),
            ),
          ),
        ],
      ),
    );
  }
}