// ============================================================
// Screen 04: Trip Matching Screen (Core)
// Shows available trucks near the user's market
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String _sortBy = 'Rating';

  late Future<List<Truck>> _trucksFuture;
  final String _apiBaseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api/trucks.php';

  @override
  void initState() {
    super.initState();
    _trucksFuture = _fetchTrucks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _trucksFuture = _fetchTrucks();
    });
  }

  Future<List<Truck>> _fetchTrucks() async {
    final params = {
      'location': _selectedLocation,
      'vehicle_type': _selectedVehicleType,
      'sort_by': _sortBy,
      'q': _searchController.text,
    };

    final uri = Uri.parse(_apiBaseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Truck.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trucks. Status code: ${response.statusCode}');
    }
  }

  Future<void> _refreshTrucks() async {
    setState(() {
      _trucksFuture = _fetchTrucks();
    });
    await _trucksFuture;
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
              Navigator.pop(ctx);
              setState(() {
                _selectedLocation = loc;
                _trucksFuture = _fetchTrucks();
              });
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
                        setModalState(() {
                           _selectedVehicleType = type;
                        });
                        
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
                    setModalState(() {
                      _sortBy = val.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Lowest Price'),
                  value: 'Price',
                  groupValue: _sortBy,
                  activeColor: const Color(0xFF1A56DB),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setModalState(() {
                      _sortBy = val.toString();
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _trucksFuture = _fetchTrucks());
                    },
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
              child: RefreshIndicator(
                onRefresh: _refreshTrucks,
                child: FutureBuilder<List<Truck>>(
                  future: _trucksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // Also wrap the error state in a scrollable view to allow pull-to-refresh
                      return LayoutBuilder(builder: (ctx, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                    const SizedBox(height: 16),
                                    Text('Failed to load trucks: ${snapshot.error}', textAlign: TextAlign.center),
                                    const SizedBox(height: 16),
                                    const Text('Pull down to try again.', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Wrap empty state in a scrollable view to allow pull-to-refresh
                      return LayoutBuilder(builder: (ctx, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'No trucks available\nfor this route.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                ),
                              ],
                            )),
                          ),
                        );
                      });
                    }

                    final trucks = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: trucks.length,
                      itemBuilder: (context, index) {
                        final truck = trucks[index];
                        return TruckCard(
                          truck: truck,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(truck: truck)));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
