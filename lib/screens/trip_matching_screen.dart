// ============================================================
// Screen 04: Trip Matching Screen (Core)
// Shows available trucks near the user's market
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/booking.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../models/truck.dart';
import '../widgets/truck_card.dart';
import 'trip_details_screen.dart';

// Simple model to hold weather data
class WeatherInfo {
  final double temperature;
  final String description;
  final IconData icon;

  WeatherInfo(
      {required this.temperature, required this.description, required this.icon});
}

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

  final Location _locationService = Location();
  late Future<List<Truck>> _trucksFuture;
  late Future<WeatherInfo> _weatherFuture;
  final String _apiBaseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api/trucks.php';

  @override
  void initState() {
    super.initState();
    _trucksFuture = _fetchTrucks();
    _weatherFuture = _fetchWeather();
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

  Future<WeatherInfo> _fetchWeather() async {
    try {
      // Get user location
      final locationData = await _locationService.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('Location data not available.');
      }

      // Call Open-Meteo API (free, no API key needed)
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentWeather = data['current_weather'];
        final temp = currentWeather['temperature'] as num;
        final weatherCode = currentWeather['weathercode'] as int;

        return _mapWeatherCodeToInfo(weatherCode, temp.toDouble());
      } else {
        throw Exception('Failed to load weather data.');
      }
    } catch (e) {
      debugPrint("Weather fetch error: $e");
      // Return a default/error state
      return WeatherInfo(
          temperature: 0, description: 'N/A', icon: Icons.error_outline);
    }
  }

  // Maps WMO weather codes from the API to a description and icon
  WeatherInfo _mapWeatherCodeToInfo(int code, double temp) {
    String description;
    IconData icon;
    switch (code) {
      case 0:
        description = 'Clear Sky';
        icon = Icons.wb_sunny_outlined;
        break;
      case 1:
      case 2:
      case 3:
        description = 'Cloudy';
        icon = Icons.cloud_outlined;
        break;
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        description = 'Rainy';
        icon = Icons.grain;
        break;
      case 95:
      case 96:
      case 99:
        description = 'Thunderstorm';
        icon = Icons.thunderstorm_outlined;
        break;
      default:
        description = 'Cloudy';
        icon = Icons.cloud_outlined;
    }
    return WeatherInfo(temperature: temp, description: description, icon: icon);
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
            child: Text('Select Market Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                const Text('Filter & Sort', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                const Text('VEHICLE TYPE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
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

                const Text('SORT BY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  height: 54,
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
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.discount, color: Color(0xFF1A56DB), size: 22)),
                    title: Text('Welcome Discount', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Get ₱50 off your first booking!'),
                    trailing: Text('Just now', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  Divider(),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.info, color: Color(0xFF1A56DB), size: 22)),
                    title: Text('System Update', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Maintenance scheduled for tonight.'),
                    trailing: Text('1d ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Widget _buildHeader(DataStore dataStore) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  Text(
                    dataStore.merchantName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
                onPressed: _showNotifications,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dashboard Cards
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildWeatherCard(),
                const SizedBox(width: 12),
                _buildWalletCard(dataStore),
                const SizedBox(width: 12),
                _buildActiveTripCard(dataStore),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by destination or driver...',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return FutureBuilder<WeatherInfo>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }

          // Error or no data state
          if (!snapshot.hasData || snapshot.hasError) {
            return Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
            );
          }

          // Success state
          final weather = snapshot.data!;
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(weather.icon, color: const Color(0xFFF59E0B), size: 34),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${weather.temperature.toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(weather.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14), overflow: TextOverflow.ellipsis),
                  ],
                )
              ],
            ),
          );
        });
  }

  Widget _buildWalletCard(DataStore dataStore) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'BALANCE',
            style: TextStyle(fontSize: 12, color: Color(0xFF1A56DB), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '₱${dataStore.balance.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A56DB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripCard(DataStore dataStore) {
    bool hasActiveTrip = dataStore.activeBooking != null;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasActiveTrip ? const Color(0xFFECFDF5) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveTrip ? Icons.local_shipping : Icons.watch_later_outlined,
            color: hasActiveTrip ? const Color(0xFF065F46) : Colors.grey.shade500,
            size: 26,
          ),
          const Spacer(),
          Text(
            hasActiveTrip ? '1 Active Trip' : 'No Active Trips',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: hasActiveTrip ? const Color(0xFF065F46) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New redesigned header
            _buildHeader(dataStore),

            // Section header with filter button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showLocationPicker,
                    child: Row(
                      children: [
                        const Text(
                          'TRUCKS FROM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedLocation.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A56DB),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                      ],
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
                          Icon(Icons.tune, size: 14, color: _selectedVehicleType != 'All' ? Colors.white : const Color(0xFF1A56DB)),
                          const SizedBox(width: 4),
                          Text(
                        'FILTER',
                        style: TextStyle(
                          fontSize: 12,
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
                                    const Icon(Icons.error_outline, color: Colors.red, size: 52),
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
                                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'No trucks available\nfor this route.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
