// ============================================================
// Screen 04: Trip Matching Screen (Core)
// Shows available trucks near the user's market
// ============================================================

import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../widgets/truck_card.dart';
import 'trip_details_screen.dart';

class TripMatchingScreen extends StatefulWidget {
  const TripMatchingScreen({super.key});

  @override
  State<TripMatchingScreen> createState() => _TripMatchingScreenState();
}

class _TripMatchingScreenState extends State<TripMatchingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'Libertad Market';
  String _selectedVehicleType = 'All';
  String _sortBy = 'Rating'; // Options: Rating, Price

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered list based on selected location
  List<Truck> get _filteredTrucks {
    List<Truck> list = List.from(sampleTrucks);

    // 1. Filter by Location (Origin)
    // Match the first word of selected location (e.g. "Libertad") to the route
    final locationKeyword = _selectedLocation.split(' ')[0].toLowerCase();
    list = list
        .where((t) => t.route.toLowerCase().contains(locationKeyword))
        .toList();

    // Apply Search Query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      list = list.where((t) =>
          t.route.toLowerCase().contains(query) ||
          t.driverName.toLowerCase().contains(query)).toList();
    }

    // 3. Filter by Vehicle Type
    if (_selectedVehicleType != 'All') {
      list = list.where((t) => t.type == _selectedVehicleType).toList();
    }

    // 4. Sort
    if (_sortBy == 'Price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else {
      // Default: Rating (High to Low)
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  void _showLocationPicker() {
    final locations = ['Libertad Market', 'Burgos Market', 'Central Market'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Market Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...locations.map((loc) => ListTile(
            title: Text(loc),
            trailing: _selectedLocation == loc ? const Icon(Icons.check_circle, color: Color(0xFF1A56DB)) : null,
            onTap: () {
              setState(() => _selectedLocation = loc);
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                const Text('VEHICLE TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: ['All', 'L300 VAN', 'MULTICAB'].map((type) {
                    final isSelected = _selectedVehicleType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1A56DB),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      onSelected: (selected) {
                        setState(() => _selectedVehicleType = type);
                        setModalState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text('SORT BY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                RadioListTile(
                  title: const Text('Highest Rated'),
                  value: 'Rating',
                  groupValue: _sortBy,
                  activeColor: const Color(0xFF1A56DB),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() => _sortBy = val.toString());
                    setModalState(() {});
                  },
                ),
                RadioListTile(
                  title: const Text('Lowest Price'),
                  value: 'Price',
                  groupValue: _sortBy,
                  activeColor: const Color(0xFF1A56DB),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() => _sortBy = val.toString());
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('APPLY FILTERS'),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.discount, color: Color(0xFF1A56DB), size: 20)),
                    title: Text('Welcome Discount', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Get ₱50 off your first booking!'),
                    trailing: Text('Just now', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                  Divider(),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.info, color: Color(0xFF1A56DB), size: 20)),
                    title: Text('System Update', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Maintenance scheduled for tonight.'),
                    trailing: Text('1d ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with location + notification bell
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location pin + name + notification icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showLocationPicker,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF1A56DB), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLocation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey, size: 18),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.grey),
                        onPressed: _showNotifications,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Where is cargo going?',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section header with filter button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AVAILABLE TRUCKS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedVehicleType != 'All'
                            ? const Color(0xFF1A56DB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1A56DB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 12, color: _selectedVehicleType != 'All' ? Colors.white : const Color(0xFF1A56DB)),
                          const SizedBox(width: 4),
                          Text(
                        'FILTER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _selectedVehicleType != 'All'
                              ? Colors.white
                              : const Color(0xFF1A56DB),
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Truck list - scrollable
            Expanded(
              child: _filteredTrucks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No trucks available\nfor this route.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filteredTrucks.length,
                      itemBuilder: (context, index) {
                        final truck = _filteredTrucks[index];
                        return TruckCard(
                          truck: truck,
                          onTap: () {
                            // Navigate to trip details for this truck
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TripDetailsScreen(truck: truck),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
