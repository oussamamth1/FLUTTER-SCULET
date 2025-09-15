import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as ge;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:zenifytrip_guide/pages/profile_page.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_const.dart';

class LocationProvider with ChangeNotifier {
  BitmapDescriptor? _pinLocationIcon;
  BitmapDescriptor? get pinLocationIcon => _pinLocationIcon;

  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? get destinationIcon => _destinationIcon;

  Map<MarkerId, Marker>? _marker;
  Map<MarkerId, Marker>? get marker => _marker;

  Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines;

  final MarkerId markerId = const MarkerId("current_location");
  final MarkerId destinationMarkerId = const MarkerId("destination");

  Location? _location;
  Location? get location => _location;

  LatLng? _locationPosition;
  LatLng? get locationPosition => _locationPosition;

  LatLng? _destinationPosition;
  LatLng? get destinationPosition => _destinationPosition;

  bool locationServiceActive = true;

  List<LatLng> _apiPositions = [];
  List<LatLng> get apiPositions => _apiPositions;

  List<Map<String, dynamic>> _allPeople = [];

  String _searchQuery = "";

  // 🗺️ Initialize PolylinePoints with your Google Maps API key
  late PolylinePoints polylinePoints;
  
  // Replace with your actual Google Maps API key
  static const String _googleMapsApiKey = "AIzaSyBiE7onmrq11reD-hX0aNi4ouxNKzue_WQ";

  // 🔎 Update search query and re-apply filter
  void updateSearch(String query, BuildContext context) {
    _searchQuery = query.toLowerCase();
    _applyFilter(context);
  }

  // 🔎 Apply search filter and show markers
  Future<void> _applyFilter(BuildContext context) async {
    if (_marker == null) return;

    _marker!.clear();
    _apiPositions.clear();

    final filtered = _allPeople.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item['jobtype'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    for (int i = 0; i < filtered.length; i++) {
      final item = filtered[i];
      final LatLng position = LatLng(item['lat'], item['lng']);
      _apiPositions.add(position);

      final markerId = MarkerId('api_marker_$i');

      final BitmapDescriptor customIcon = await bitmapDescriptorFromUrl(
        item['image'],
        width: 50,
      );

      _marker![markerId] = Marker(
        markerId: markerId,
        position: position,
        icon: customIcon,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Container(
                padding: const EdgeInsets.only(
                    top: 40, left: 45, right: 45, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(item['image']),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Age: ${item['age']}"),
                    const SizedBox(height: 12),
                    Text("Job : ${item['jobtype']}"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await createRoutingLine(position, Colors.green);
                        _destinationPosition = position;
                        _marker!.remove(destinationMarkerId);
                      },
                      child: const Text("Track Position"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    notifyListeners();
  }

  // 🖼 Convert network image to BitmapDescriptor for map markers
  Future<BitmapDescriptor> bitmapDescriptorFromUrl(String url,
      {int width = 100}) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec =
        await ui.instantiateImageCodec(bytes, targetWidth: width, targetHeight: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  /// 📍 Fetch positions (hardcoded JSON for now)
  Future<void> loadPositionsFromApi(String apiUrl, BuildContext context) async {
    try {
      final String jsonString = '''
      [
        { "lat": 35.83949598294137, "lng": 10.619222225870088, "name": "John Doe", "age": 29, "image": "https://img.freepik.com/vecteurs-libre/cercle-bleu-utilisateur-blanc_78370-4707.jpg", "jobtype": "athlete" },
        { "lat": 35.83249598297137, "lng": 10.619222225270088, "name": "Jane Smith", "age": 34, "image": "https://cdn-icons-png.flaticon.com/512/219/219988.png", "jobtype": "coach" },
        { "lat": 35.84949598297137, "lng": 10.619222225270088, "name": "CR Ronaldo", "age": 34, "image": "https://www.leparisien.fr/resizer/8GIayCCfM898eKrdPzNkydZtt28=/1400x0/arc-anglerfish-eu-central-1-prod-leparisien.s3.amazonaws.com/public/C2QHZLIS5NHYLGLWHB5JOWP72I.jpg", "jobtype": "coach" },
        { "lat": 35.83359598294137, "lng": 10.619222225270088, "name": "L Messi", "age": 32, "image": "https://upload.wikimedia.org/wikipedia/commons/3/3d/Lionel_Messi_NE_Revolution_Inter_Miami_7.9.25-055.jpg", "jobtype": "doctor" },
        { "lat": 35.85249598297137, "lng": 10.619222225270088, "name": "Z Ibrahim", "age": 25, "image": "https://img.a.transfermarkt.technology/portrait/big/3455-1579506060.jpg?lm=1", "jobtype": "engineer" },
        { "lat": 35.84249598297137, "lng": 10.619222225270088, "name": "Bolbol Monji", "age": 34, "image": "https://k9vomhismerh.com/wp-content/uploads/2024/09/Ace-600x400-1.jpg", "jobtype": "cleanair" }
      ]
      ''';

      final List<dynamic> data = json.decode(jsonString);
      _allPeople = List<Map<String, dynamic>>.from(data);

      _marker?.clear();
      _apiPositions.clear();

      for (int i = 0; i < _allPeople.length; i++) {
        final item = _allPeople[i];
        final LatLng position = LatLng(item['lat'], item['lng']);
        _apiPositions.add(position);

        final markerId = MarkerId('api_marker_$i');

        final BitmapDescriptor customIcon = await bitmapDescriptorFromUrl(
          item['image'],
          width: 50,
        );

        _marker![markerId] = Marker(
          markerId: markerId,
          position: position,
          icon: customIcon,
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return Container(
                  padding: const EdgeInsets.only(
                      top: 40, left: 45, right: 45, bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(onTap: () {
                        Navigator.pop(context);
                         context.push('/profile'); // if you just want the page
    // or with parameters:
    // context.push('/profile', extra: item);
  //              GoRoute(
  // name: AppRouteConst.profile,
  // path: 'profile',
  // builder: (context, state) {
  //   final item = state.extra as Map<String, dynamic>?; // optional
  //   return ProfilePage( ); // make sure ProfilePage accepts this
  // },
// );
                      },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(item['image']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Age: ${item['age']}"),
                      const SizedBox(height: 12),
                      Text("Job : ${item['jobtype']}"),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await createRoutingLine(position, Colors.green);
                          _destinationPosition = position;
                          _marker!.remove(destinationMarkerId);
                        },
                        child: const Text("Track Position"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading API positions: $e');
    }
  }

  // 🏗 Constructor
  LocationProvider() {
    _location = Location();
    _marker = <MarkerId, Marker>{};
    // Initialize PolylinePoints with your Google Maps API key
    polylinePoints = PolylinePoints(apiKey: "AIzaSyBiE7onmrq11reD-hX0aNi4ouxNKzue_WQ",defaultTimeout: Duration(seconds: 60));
  }

  // ⚡ Initialize
  Future<void> initialization() async {
    await getUserLocation();
    await setCustomMapPin();
  }

  // 📍 Get current location
  Future<void> getUserLocation() async {
    bool serviceEnabled = await ge.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    ge.LocationPermission permission = await ge.Geolocator.checkPermission();
    if (permission == ge.LocationPermission.denied) {
      permission = await ge.Geolocator.requestPermission();
      if (permission == ge.LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == ge.LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    ge.Position position = await ge.Geolocator.getCurrentPosition(
      desiredAccuracy: ge.LocationAccuracy.high,
    );

    _locationPosition = LatLng(position.latitude, position.longitude);
    print('Location: $_locationPosition');
  }

  // 📌 Custom map pins
  Future<void> setCustomMapPin() async {
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/location.png',
    );

    try {
      _destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/pin1.png',
      );
    } catch (e) {
      _destinationIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      debugPrint('Using default destination marker: $e');
    }
  }

  // 📍 Add a draggable destination marker
  void addDestinationMarker(LatLng position) {
    _destinationPosition = position;

    final Marker destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: position,
      icon: _destinationIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      draggable: true,
      infoWindow: const InfoWindow(title: 'Destination'),
      onTap: () => debugPrint('Destination marker tapped'),
      onDragEnd: (LatLng newPosition) async {
        _destinationPosition = newPosition;
        await createRoutingLine(newPosition, Colors.yellowAccent);
      },
    );

    _marker![destinationMarkerId] = destinationMarker;
    createRoutingLine(position, Colors.black54);
    notifyListeners();
  }

  // 🗺️ Create actual route polyline using Google Directions API
  Future<void> createRoutingLine(LatLng destination, Color color) async {
    if (_locationPosition == null) return;

    try {
      // Get route using flutter_polyline_points
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_locationPosition!.latitude, _locationPosition!.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving, // You can change this to walking, transit, etc.
        ),
      );

      if (result.points.isNotEmpty) {
        // Convert to LatLng for Google Maps
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        final Polyline polyline = Polyline(
          polylineId: const PolylineId('route_line'),
          color: color,
          width: 5,
          points: polylineCoordinates,
          consumeTapEvents: true,
          onTap: () {
            final distance = _calculateRouteDistance(polylineCoordinates);
            final kmOrM = distance > 1000
                ? "${(distance / 1000).toStringAsFixed(2)} km"
                : "${distance.toStringAsFixed(0)} m";
            debugPrint("Route tapped. Approximate distance: $kmOrM");
          },
        );

        _polylines.clear();
        _polylines.add(polyline);
        notifyListeners();
      } else {
        // Fallback to straight line if route not found
        debugPrint('No route found, using straight line');
        _createStraightLine(destination, color);
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
      // Fallback to straight line on error
      _createStraightLine(destination, color);
    }
  }

  // ➖ Fallback method: Create straight line polyline (original method)
  void _createStraightLine(LatLng destination, Color color) {
    if (_locationPosition == null) return;

    final Polyline polyline = Polyline(
      polylineId: const PolylineId('tracking_line'),
      color: color,
      width: 3,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      points: [_locationPosition!, destination],
      consumeTapEvents: true,
      onTap: () {
        final distance = currentToDestinationDistance;
        if (distance != null) {
          final kmOrM = distance > 1000
              ? "${(distance / 1000).toStringAsFixed(2)} km"
              : "${distance.toStringAsFixed(0)} m";
          debugPrint("Straight line tapped. Distance: $kmOrM");
        }
      },
    );

    _polylines.clear();
    _polylines.add(polyline);
    notifyListeners();
  }

  // 📏 Calculate total route distance from polyline points
  double _calculateRouteDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(points[i], points[i + 1]);
    }
    return totalDistance;
  }

  // 🧹 Clear polyline and destination marker
  void clearTracking() {
    _polylines.clear();
    _destinationPosition = null;
    _marker!.remove(destinationMarkerId);
    notifyListeners();
  }

  // 📏 Calculate haversine distance
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;

    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLat = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLng = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // 📏 Expose current-to-destination distance (straight line)
  double? get currentToDestinationDistance {
    if (_locationPosition == null || _destinationPosition == null) return null;
    return calculateDistance(_locationPosition!, _destinationPosition!);
  }

  // 🗺️ Check if route exists
  bool get hasActiveRoute => _polylines.isNotEmpty;

  // 🗺️ Get current route information
  Map<String, dynamic>? get currentRouteInfo {
    if (!hasActiveRoute) return null;
    
    final polyline = _polylines.first;
    final routePoints = polyline.points;
    
    if (routePoints.length < 2) return null;
    
    final routeDistance = _calculateRouteDistance(routePoints);
    final estimatedTime = _estimateRouteTime(routeDistance);
    
    return {
      'distance': routeDistance,
      'distanceText': routeDistance > 1000
          ? "${(routeDistance / 1000).toStringAsFixed(2)} km"
          : "${routeDistance.toStringAsFixed(0)} m",
      'estimatedTimeMinutes': estimatedTime,
      'estimatedTimeText': _formatTime(estimatedTime),
      'pointsCount': routePoints.length,
      'origin': _locationPosition,
      'destination': _destinationPosition,
      'routePoints': routePoints,
      'polylineColor': polyline.color,
    };
  }

  // 🕐 Estimate route time based on distance (rough estimation)
  double _estimateRouteTime(double distanceInMeters) {
    // Assume average speed of 30 km/h in city traffic
    const double averageSpeedKmh = 30.0;
    const double averageSpeedMs = averageSpeedKmh * 1000 / 3600; // Convert to m/s
    
    final double timeInSeconds = distanceInMeters / averageSpeedMs;
    return timeInSeconds / 60; // Return in minutes
  }

  // 📝 Format time in readable format
  String _formatTime(double minutes) {
    if (minutes < 60) {
      return "${minutes.toStringAsFixed(0)} min";
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).toStringAsFixed(0);
      return "${hours}h ${remainingMinutes}min";
    }
  }

  // 🗺️ Get route summary text
  String get routeSummary {
    final routeInfo = currentRouteInfo;
    if (routeInfo == null) return "No active route";
    
    return "${routeInfo['distanceText']} • ${routeInfo['estimatedTimeText']}";
  }

  // 🗺️ Show route details (for debugging or info display)
  void showRouteDetails() {
    final routeInfo = currentRouteInfo;
    if (routeInfo == null) {
      debugPrint("No active route to show");
      return;
    }
    
    debugPrint("=== CURRENT ROUTE DETAILS ===");
    debugPrint("Distance: ${routeInfo['distanceText']}");
    debugPrint("Estimated Time: ${routeInfo['estimatedTimeText']}");
    debugPrint("Route Points: ${routeInfo['pointsCount']}");
    debugPrint("Origin: ${routeInfo['origin']}");
    debugPrint("Destination: ${routeInfo['destination']}");
    debugPrint("============================");
  }

  // 🗺️ Get route coordinates for external use
  List<LatLng>? get currentRouteCoordinates {
    if (!hasActiveRoute) return null;
    return _polylines.first.points;
  } }