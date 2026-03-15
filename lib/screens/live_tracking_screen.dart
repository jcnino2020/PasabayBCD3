// ============================================================
// Screen 08: Live Tracking Screen (Core)
// Shows a real OpenStreetMaps map with driver route and ETA
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/truck.dart';
import '../models/booking.dart';
import 'main_screen.dart';
import 'rating_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({
    super.key,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  // --- Map and Location State ---
  final MapController _mapController = MapController();
  final Location _locationService = Location();

  final List<Marker> _markers = [];
  List<LatLng> _polylineCoordinates = [];
  LatLng? _truckPosition;
  double _truckRotation = 0.0;

  // --- Animation State ---
  late AnimationController _truckAnimController;

  // --- UI State ---
  double _initialEtaMinutes = 0;
  double _currentEtaMinutes = 0;
  bool _hasArrived = false;

  @override
  void initState() {
    super.initState();
    _truckAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        _updateTruckAndEta();
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // When animation finishes, update the UI to show arrival
          setState(() {
            _hasArrived = true;
          });
        }
      });

    _setupMapAndIcons();
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    // OSRM API endpoint for driving routes
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Extract the coordinates from the GeoJSON response
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        // Extract the duration from the response (in seconds)
        final durationInSeconds = data['routes'][0]['duration'] as num;
        final durationInMinutes = durationInSeconds / 60.0;

        // OSRM returns [longitude, latitude], so we need to map it to LatLng(latitude, longitude)
        final points = coordinates.map((c) => LatLng(c[1], c[0])).toList();
        setState(() {
          _polylineCoordinates = points;
          _initialEtaMinutes = durationInMinutes;
          _currentEtaMinutes = durationInMinutes;
        });
      } else {
        debugPrint('Failed to fetch route: ${response.statusCode}');
        // Fallback to a straight line if the API fails
        setState(() => _polylineCoordinates = [start, end]);
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      setState(() => _polylineCoordinates = [start, end]);
    }
  }

  LatLng _getStartPositionForRoute(String route) {
    final routeLowerCase = route.toLowerCase();
    if (routeLowerCase.contains('burgos')) {
      return const LatLng(10.6765, 122.9534); // Burgos Public Market
    } else if (routeLowerCase.contains('central market')) {
      return const LatLng(10.6633, 122.9503); // Bacolod Public Plaza / Central Market
    }
    // Default to Libertad Market
    return const LatLng(10.6675, 122.9461); // Libertad Market
  }

  void _setupMapAndIcons() async {
    final activeBooking = DataStore().activeBooking;
    if (activeBooking == null) return;

    // Find the truck associated with the active booking
    final activeTruck = sampleTrucks.firstWhere(
        (t) => t.id == activeBooking.truckId,
        orElse: () => sampleTrucks[0]);

    // Get start position based on the truck's route
    final LatLng startPosition = _getStartPositionForRoute(activeTruck.route);

    // Get user's current location as the destination
    try {
      final locationData = await _locationService.getLocation();
      final destinationPosition =
          LatLng(locationData.latitude!, locationData.longitude!);

      // Fetch the road-based route before setting state
      await _fetchRoute(startPosition, destinationPosition);

      setState(() {
        _truckPosition = startPosition;
        _markers.add(Marker(
          point: destinationPosition,
          width: 80,
          height: 80,
          child: Image.asset('assets/destination_pin.png'),
        ));
      });

      _animateCameraToRoute();
      // Start the animation with its fixed duration
      _truckAnimController.forward();
    } catch (e) {
      debugPrint("Could not get location: $e");
      // Handle location permission errors, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location. Please enable location services.')),
      );
    }
  }

  void _animateCameraToRoute() async {
    if (_polylineCoordinates.isEmpty) return;
    var bounds = LatLngBounds.fromPoints(_polylineCoordinates);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 120),
      ),
    );
  }

  void _updateTruckAndEta() {
    if (_polylineCoordinates.length < 2) return;

    final animationValue = _truckAnimController.value;

    // Calculate which segment of the multi-point polyline we are on
    final double totalSegments = (_polylineCoordinates.length - 1).toDouble();
    final double currentSegmentPos = totalSegments * animationValue;
    final int currentSegmentIndex = currentSegmentPos.floor();

    // Ensure we don't go out of bounds at the end of the animation
    if (currentSegmentIndex >= _polylineCoordinates.length - 1) {
      if (_truckPosition != _polylineCoordinates.last) {
        setState(() => _truckPosition = _polylineCoordinates.last);
      }
      return;
    }

    // Calculate how far along the current segment we are (0.0 to 1.0)
    final double segmentProgress = currentSegmentPos - currentSegmentIndex;

    final LatLng segmentStart = _polylineCoordinates[currentSegmentIndex];
    final LatLng segmentEnd = _polylineCoordinates[currentSegmentIndex + 1];

    // Interpolate between the start and end points of the current segment
    final lat = segmentStart.latitude + (segmentEnd.latitude - segmentStart.latitude) * segmentProgress;
    final lng = segmentStart.longitude + (segmentEnd.longitude - segmentStart.longitude) * segmentProgress;
    final newPosition = LatLng(lat, lng);

    double bearing = _calculateBearing(_truckPosition ?? segmentStart, newPosition);

    setState(() {
      _truckPosition = newPosition;
      // Only update rotation if it changes significantly to avoid jitter
      if ((bearing - _truckRotation).abs() > 1.0) {
        _truckRotation = bearing;
      }

      // Update ETA based on animation progress
      _currentEtaMinutes = _initialEtaMinutes * (1.0 - animationValue);
    });
  }

  double _calculateBearing(LatLng begin, LatLng end) {
    double lat1 = begin.latitude * pi / 180;
    double lon1 = begin.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360;
  }

  @override
  void dispose() {
    _truckAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve booking from args or DataStore
    final activeBooking = DataStore().activeBooking;
    
    // If no active booking, show empty state
    if (activeBooking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No active trips', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    // Resolve truck
    final activeTruck = sampleTrucks.firstWhere(
        (t) => t.id == activeBooking.truckId,
        orElse: () => sampleTrucks[0]);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Real OpenStreetMap, renamed for clarity
          _buildOpenStreetMap(),

          // Map controls (Zoom and Recenter)
          Positioned(
            bottom: 350, // Position above the bottom sheet
            right: 16,
            child: Column(
              children: [
                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'zoomInBtn',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111827),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'zoomOutBtn',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111827),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 16),
                // Recenter on Truck
                FloatingActionButton(
                  heroTag: 'recenterBtn',
                  backgroundColor: const Color(0xFF1A56DB),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    if (_truckPosition != null) {
                      // Animate the camera to the truck's position with a good zoom level
                      _mapController.move(_truckPosition!, 16.0);
                    }
                  },
                  child: const Icon(Icons.gps_fixed),
                ),
              ],
            ),
          ),

          // Status badge at top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // In Transit badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'In Transit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Booking ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      activeBooking.id.substring(0, 7),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ETA row
                  Row(
                    children: [
                      Icon(
                        _hasArrived ? Icons.check_circle : Icons.schedule,
                        color: _hasArrived ? const Color(0xFF10B981) : const Color(0xFF1A56DB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasArrived ? 'The truck has arrived' : 'Arriving in ${_currentEtaMinutes.ceil()} mins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      // Call driver button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${activeTruck.driverName}...')),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone,
                              color: Color(0xFF1A56DB), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${activeTruck.driverName} is transporting your shipment.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Driver info row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Driver's Profile Photo ---
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        // Use a cache-busting URL for the driver's photo
                        backgroundImage: activeTruck.profilePhotoUrl != null
                            ? NetworkImage(
                                '${activeTruck.profilePhotoUrl!}?v=${DateTime.now().millisecondsSinceEpoch}')
                            : null,
                        child: activeTruck.profilePhotoUrl == null
                            ? const Icon(Icons.person,
                                color: Colors.grey, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeTruck.driverName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${activeTruck.type} • ${activeTruck.plateNumber}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            activeTruck.rating.toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Complete Delivery Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark booking as complete in DataStore
                        DataStore().completeBooking();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cargo received! Transaction completed.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );

                        // Navigate to the rating screen so the user can review the driver
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingScreen(
                              driverName: activeTruck.driverName,
                              truckType: activeTruck.type,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('MARK AS RECEIVED', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStreetMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(10.6675, 122.9461), // Bacolod City center
        initialZoom: 14,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.pasabaybcd',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _polylineCoordinates,
              strokeWidth: 5.0,
              color: const Color(0xFF1A56DB),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            ..._markers,
            if (_truckPosition != null)
              Marker(
                point: _truckPosition!,
                width: 80,
                height: 80,
                child: Transform.rotate(
                  angle: _truckRotation * (pi / 180),
                  child: Image.asset('assets/truck_icon.png'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
