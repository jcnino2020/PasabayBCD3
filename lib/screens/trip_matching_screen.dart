// ============================================================
// Screen 04: Trip Matching Screen (Core)
// Shows available trucks near the user's market
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/truck.dart';
import '../widgets/truck_card.dart';
import 'trip_details_screen.dart';
import 'booking_history_screen.dart';
import 'notifications_screen.dart';

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
  String _userName = '';

  // Quick stats (loaded from stored userData)
  int _totalBookings = 0;
  double _totalSavings = 0.0;

  // Promo banner state
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();

  late Future<List<Truck>> _trucksFuture;
  final String _apiBaseUrl = 'http://ov3.238.mytemp.website/pasabaybcd/api/trucks.php';

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'First Booking?',
      'subtitle': 'Enjoy discounted rates on your first cargo trip!',
      'color': const Color(0xFF1A56DB),
      'icon': Icons.local_offer_outlined,
    },
    {
      'title': 'Share the Load',
      'subtitle': 'Split shipping costs with other vendors going the same route.',
      'color': const Color(0xFF047857),
      'icon': Icons.people_alt_outlined,
    },
    {
      'title': 'Track in Real Time',
      'subtitle': 'Know exactly where your cargo is at any moment.',
      'color': const Color(0xFF7C3AED),
      'icon': Icons.gps_fixed,
    },
  ];

  @override
  void initState() {
    super.initState();
    _trucksFuture = _fetchTrucks();
    _searchController.addListener(_onSearchChanged);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      final userData = json.decode(userJson);
      final fullName = (userData['full_name'] ?? userData['name'] ?? '') as String;
      setState(() {
        _userName = fullName.split(' ').first;
        _totalBookings = (userData['total_bookings'] ?? 0) as int;
        _totalSavings = double.tryParse(userData['total_savings']?.toString() ?? '0') ?? 0.0;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _bannerController.dispose();
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
      final trucks = data.map((json) => Truck.fromJson(json)).toList();
      // Randomize order on every fetch so the listing feels fresh
      trucks.shuffle(Random());
      return trucks;
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
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row with notification bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_userName.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, color: Color(0xFF111827)),
                    children: [
                      TextSpan(text: '${_getGreeting()}, ', style: const TextStyle(fontWeight: FontWeight.w400)),
                      TextSpan(text: '$_userName!', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                )
              else
                const Text(
                  'Find a Truck',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
              // Notification bell shortcut
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Color(0xFF1A56DB), size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location pin row
          GestureDetector(
            onTap: _showLocationPicker,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF1A56DB), size: 18),
                const SizedBox(width: 4),
                Text(
                  _selectedLocation.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                hintText: 'Where is cargo going?',
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

  // Quick Stats Row
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long_outlined,
              label: 'Total Bookings',
              value: '$_totalBookings',
              color: const Color(0xFF1A56DB),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.savings_outlined,
              label: 'Total Savings',
              value: '\u20b1${_totalSavings.toStringAsFixed(0)}',
              color: const Color(0xFF047857),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Promo Banner Carousel
  Widget _buildPromoBanner() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _promoBanners.length,
            onPageChanged: (i) => setState(() => _activeBannerIndex = i),
            itemBuilder: (context, index) {
              final banner = _promoBanners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (banner['color'] as Color).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(banner['icon'] as IconData, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promoBanners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activeBannerIndex == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _activeBannerIndex == i
                    ? const Color(0xFF1A56DB)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Quick Action Buttons
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.history,
        'label': 'History',
        'screen': const BookingHistoryScreen(),
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Alerts',
        'screen': const NotificationsScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => action['screen'] as Widget),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(action['icon'] as IconData, size: 16, color: const Color(0xFF1A56DB)),
                    const SizedBox(width: 6),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
            _buildHeader(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshTrucks,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Quick Stats
                    SliverToBoxAdapter(child: _buildQuickStats()),

                    // Promo Banners
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(child: _buildPromoBanner()),

                    // Quick Action Buttons
                    SliverToBoxAdapter(child: _buildQuickActions()),

                    // Section header with filter button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AVAILABLE TRUCKS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFilterSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedVehicleType != 'All'
                                      ? const Color(0xFF1A56DB)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF1A56DB)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      size: 14,
                                      color: _selectedVehicleType != 'All'
                                          ? Colors.white
                                          : const Color(0xFF1A56DB),
                                    ),
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
                    ),

                    // Truck list
                    FutureBuilder<List<Truck>>(
                      future: _trucksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SliverToBoxAdapter(
                            child: Center(child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            )),
                          );
                        } else if (snapshot.hasError) {
                          return SliverToBoxAdapter(
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
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No trucks available\nfor this route.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final trucks = snapshot.data!;
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final truck = trucks[index];
                              return TruckCard(
                                truck: truck,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // Pass _selectedLocation to TripDetailsScreen
                                      builder: (_) => TripDetailsScreen(
                                        truck: truck,
                                        selectedLocation: _selectedLocation,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: trucks.length,
                          ),
                        );
                      },
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================
// Private helper widget: Stat Card
// ====================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
