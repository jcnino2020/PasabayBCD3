import 'package:flutter/material.dart';
import '../models/truck.dart';
import 'cargo_form_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final Truck truck;
  // Receives the market location selected on TripMatchingScreen
  final String selectedLocation;

  const TripDetailsScreen({
    super.key,
    required this.truck,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header Image (could be a generic truck image or map snippet)
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: Colors.grey.shade200,
            child: Center(child: Icon(Icons.local_shipping, size: 104, color: Colors.grey.shade400)),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // DraggableScrollableSheet for details
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: truck.profilePhotoUrl != null
                                ? NetworkImage('${truck.profilePhotoUrl!}?v=${DateTime.now().millisecondsSinceEpoch}')
                                : null,
                            child: truck.profilePhotoUrl == null ? const Icon(Icons.person, size: 34, color: Colors.grey) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  truck.driverName,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  truck.plateNumber,
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                truck.rating.toString(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Vehicle Details
                      const Text("VEHICLE DETAILS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.local_shipping_outlined, "Vehicle Type", truck.type),
                      _buildDetailRow(Icons.scale_outlined, "Max Capacity", "${truck.capacityKg.toInt()} kg"),
                      _buildDetailRow(Icons.all_inbox_outlined, "Max Volume", "${truck.capacityCbm} cbm"),
                      const SizedBox(height: 16),

                      // Route Details
                      const Text("ROUTE DETAILS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      // Show the user's selected pickup location
                      _buildDetailRow(Icons.location_on_outlined, "Pickup From", selectedLocation),
                      _buildDetailRow(Icons.route_outlined, "Route", truck.route),
                      _buildDetailRow(Icons.schedule_outlined, "Departs Around", truck.departTime),
                      const SizedBox(height: 32),

                      // Booking Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Forward selectedLocation to CargoFormScreen
                                builder: (_) => CargoFormScreen(
                                  truck: truck,
                                  selectedLocation: selectedLocation,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A56DB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Book for ₱${truck.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 22),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
