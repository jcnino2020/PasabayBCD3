import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/booking.dart'; // For DataStore
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  bool _isSubmitting = false;
  File? _idImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _permitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _permitController.dispose();
    super.dispose();
  }

  /// Opens the gallery to pick an ID image.
  Future<void> _pickIdImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = File(image.path);
      });
    }
  }

  /// Resizes the captured image to a max width to save bandwidth.
  Future<File> _resizeImage(File originalFile, {int maxWidth = 1080}) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return originalFile;

    // Resize if width > maxWidth
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    final resizedBytes = img.encodeJpg(image, quality: 85);

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${originalFile.uri.pathSegments.last}');
    await tempFile.writeAsBytes(resizedBytes);

    return tempFile;
  }

  /// Submits the KYC form data and ID image to the server.
  Future<void> _submitVerification(DataStore dataStore) async {
    // --- Form Validation ---
    if (_nameController.text.isEmpty || _permitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_idImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image of your ID.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Resize the image
      final File resizedId = await _resizeImage(_idImage!);

      // 2. Prepare the multipart request
      final uri = Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/kyc_upload.php');
      final request = http.MultipartRequest('POST', uri);

      // 3. Add text fields
      request.fields['user_id'] = dataStore.userId.toString();
      request.fields['full_name'] = _nameController.text;
      request.fields['business_permit_number'] = _permitController.text;

      // 4. Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'id_photo', // This key must match the $_FILES key in PHP
        resizedId.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // 5. Send the request and handle response
      final response = await request.send();
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => dataStore.isKycVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification Successful!'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed (Code: ${response.statusCode}). No details from server.'), backgroundColor: Colors.red),
          );
          return;
        }
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${errorData['error'] ?? 'Unknown server error'}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Legal Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _permitController,
            decoration: const InputDecoration(labelText: 'Business Permit Number'),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _pickIdImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _idImage != null ? const Color(0xFFECFDF5) : Colors.white,
                border: Border.all(
                  color: _idImage != null ? const Color(0xFF10B981) : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _idImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(_idImage!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload Valid ID',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
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
              onPressed: _isSubmitting ? null : () => _submitVerification(dataStore),
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