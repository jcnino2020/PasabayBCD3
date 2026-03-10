import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import '../models/booking.dart'; // For DataStore

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataStore _dataStore = DataStore();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final File resizedFile = await _resizeImage(File(image.path));
      final uri = Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/user_profile_upload.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = _dataStore.userId.toString();
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
          _dataStore.profilePhotoUrl = responseData['profile_photo_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${errorData['error'] ?? 'Server error'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<File> _resizeImage(File originalFile, {int maxWidth = 512}) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return originalFile;

    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    final resizedBytes = img.encodeJpg(image, quality: 90);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(resizedBytes);
    return tempFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildProfileAvatar(),
              const SizedBox(height: 20),
              Text(
                _dataStore.merchantName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _dataStore.marketLocation,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildInfoTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet Balance',
                trailing: '₱${_dataStore.balance.toStringAsFixed(2)}',
              ),
              _buildInfoTile(
                icon: Icons.verified_user_outlined,
                title: 'Verification Status',
                trailing: _dataStore.isKycVerified ? 'Verified' : 'Not Verified',
                trailingColor: _dataStore.isKycVerified ? const Color(0xFF10B981) : Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    // Use a cache-busting URL by appending a timestamp
    final imageUrl = _dataStore.profilePhotoUrl != null
        ? '${_dataStore.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? const Icon(Icons.storefront, size: 60, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndUploadProfilePhoto,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String trailing, Color? trailingColor}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade500),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(
        trailing,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: trailingColor ?? Colors.black87,
        ),
      ),
    );
  }
}