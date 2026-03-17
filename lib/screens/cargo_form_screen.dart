// ============================================================
// Screen 06: Cargo Form Screen (Core)
// "What are you sending?" - cargo details booking form
// ============================================================

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/truck.dart';
import '../models/booking.dart';
import 'driver_confirmation_screen.dart';

class CargoFormScreen extends StatefulWidget {
  final Truck truck;

  const CargoFormScreen({super.key, required this.truck});

  @override
  State<CargoFormScreen> createState() => _CargoFormScreenState();
}

class _CargoFormScreenState extends State<CargoFormScreen> {
  // State: which cargo category is selected
  String _selectedCategory = 'Produce';

  // State: weight and quantity values
  int _weight = 15;
  int _quantity = 2;

  // State for capturing and handling the cargo image
  File? _cargoPhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Available cargo categories from the wireframe
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Produce', 'icon': Icons.grass},
    {'label': 'Box', 'icon': Icons.inventory_2_outlined},
    {'label': 'Textile', 'icon': Icons.checkroom_outlined},
  ];

  // Compute estimated fee based on truck price and weight
  double get _estimatedFee {
    double base = widget.truck.price;
    if (_weight > 20) base += (_weight - 20) * 2.5;
    return base;
  }

  /// Opens the camera to take a picture of the cargo.
  Future<void> _snapPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // Initial compression
    );

    if (photo != null) {
      setState(() {
        _cargoPhoto = File(photo.path);
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

  /// Uploads booking details and cargo photo, then proceeds to confirmation.
  Future<void> _uploadAndConfirm() async {
    if (_cargoPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a photo of your cargo.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Resize the image before uploading
      final File resizedFile = await _resizeImage(_cargoPhoto!);

      // 2. Prepare the multipart request
      final uri =
          Uri.parse('http://ov3.238.mytemp.website/pasabaybcd/api/bookings.php');
      final request = http.MultipartRequest('POST', uri);

      // 3. Add text fields (booking data)
      final dataStore = DataStore();
      request.fields['user_id'] = dataStore.userId?.toString() ?? '0';
      request.fields['truck_id'] = widget.truck.id;
      request.fields['driver_name'] = widget.truck.driverName;
      request.fields['cargo_category'] = _selectedCategory;
      request.fields['weight_kg'] = _weight.toString();
      request.fields['quantity'] = _quantity.toString();
      request.fields['estimated_fee'] = _estimatedFee.toString();

      // 4. Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'cargo_photo', // API parameter name for the file
        resizedFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // 5. Send the request and wait for response
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      // 6. Handle the response
      if (response.statusCode == 201) { // 201 Created is a good practice for POST
        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking failed: Server returned an empty response.'), backgroundColor: Colors.red));
          return;
        }
        final responseData = json.decode(responseBody);

        // Create a Booking object from the server's response
        final newBooking = Booking.fromJson(responseData['booking']);

        // Navigate to the confirmation screen
        Navigator.push(context, MaterialPageRoute(builder: (_) => DriverConfirmationScreen(truck: widget.truck, booking: newBooking)));
      } else {
        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed (Code: ${response.statusCode}). No details from server.'), backgroundColor: Colors.red));
          return;
        }
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: ${errorData['error'] ?? 'Unknown server error'}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BOOKING DETAILS',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator (2 steps)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A56DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'What are you sending?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),

            // Snap photo section
            GestureDetector(
              onTap: _snapPhoto,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: _cargoPhoto != null ? const Color(0xFFEBF2FF) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _cargoPhoto != null ? const Color(0xFF1A56DB) : Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                // Show the captured image or the prompt to take one.
                child: _cargoPhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.5),
                        child: Image.file(
                          _cargoPhoto!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Snap Photo of Cargo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Cargo category label
            const Text(
              'CARGO CATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // Category selector chips
            Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['label'];
                return GestureDetector(
                  onTap: () {
                    // Update selected category using setState
                    setState(() => _selectedCategory = cat['label']);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A56DB)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Weight and Quantity inputs
            Row(
              children: [
                // Weight field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEIGHT (KG)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Custom stepper control
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _weight > 1
                                  ? () => setState(() => _weight--)
                                  : null,
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$_weight',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => setState(() => _weight++),
                              color: const Color(0xFF1A56DB),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Quantity field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUANTITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => setState(() => _quantity++),
                              color: const Color(0xFF1A56DB),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Estimated fee + Confirm button
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EST. FEE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${_estimatedFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Confirm button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadAndConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF1A56DB).withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'CONFIRM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
