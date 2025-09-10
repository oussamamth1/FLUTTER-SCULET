import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as ge;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
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
Future<BitmapDescriptor> bitmapDescriptorFromUrl(String url, {int width = 100}) async {
  final http.Response response = await http.get(Uri.parse(url));
  final Uint8List bytes = response.bodyBytes;

  final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List resizedBytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(resizedBytes);
}
/// Fetch positions from API (or use hardcoded JSON) and add markers
Future<void> loadPositionsFromApi(String apiUrl, BuildContext context) async {
  try {
    // Replace with your API call
    final String jsonString = '''
    [
      { "lat": 35.83949598294137, "lng": 10.619222225870088, "name": "John Doe", "age": 29, "image": "https://img.freepik.com/vecteurs-libre/cercle-bleu-utilisateur-blanc_78370-4707.jpg" },
      { "lat": 35.83249598297137, "lng": 10.619222225270088, "name": "Jane Smith", "age": 34, "image": "https://cdn-icons-png.flaticon.com/512/219/219988.png" }
    ]
    ''';

    final List<dynamic> data = json.decode(jsonString);

    _marker?.clear();
    _apiPositions.clear();

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final LatLng position = LatLng(item['lat'], item['lng']);
      _apiPositions.add(position);

      final markerId = MarkerId('api_marker_$i');

      final BitmapDescriptor customIcon = await bitmapDescriptorFromUrl(
        item['image'], // Network image URL
        width: 100,    // Resize width for icon
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
                padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Age: ${item['age']}"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        createTrackingLine(position);
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
  LocationProvider() {
    _location = Location();
    _marker = <MarkerId, Marker>{};
  }

  Future<void> initialization() async {
    await getUserLocation();
    await setCustomMapPin();
  }

Future<void> getUserLocation() async {
  // Check if location services are enabled
  bool serviceEnabled = await ge.Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return;
  }

  // Check permissions
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

  // Get location
  ge.Position position = await ge.Geolocator.getCurrentPosition(
    desiredAccuracy: ge.LocationAccuracy.high,
  );

  _locationPosition = LatLng(position.latitude, position.longitude);
  print('Location: $_locationPosition');
}
  Future<void> setCustomMapPin() async {
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
       ImageConfiguration(devicePixelRatio: 2.5),
      'assets/location.png',
    );

    try {
      _destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/pin1.png',
      );
    } catch (e) {
      _destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      debugPrint('Using default destination marker: $e');
    }
  }

  void addDestinationMarker(LatLng position) {
    _destinationPosition = position;

    final Marker destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: position,
      icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      draggable: true,
      infoWindow: const InfoWindow(title: 'Destination'),
      onTap: () => debugPrint('Destination marker tapped'),
      onDragEnd: (LatLng newPosition) {
        _destinationPosition = newPosition;
        createTrackingLine(newPosition);
      },
    );

    _marker![destinationMarkerId] = destinationMarker;
   createTrackingLine(position); // create line immediately
    notifyListeners();
  }

  void createTrackingLine(LatLng destination) {
    if (_locationPosition == null) return;

    final Polyline polyline = Polyline(
      polylineId: const PolylineId('tracking_line'),
      color: Colors.blue,
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
          debugPrint("Tracking line tapped. Distance: $kmOrM");
        }
      },
    );

    _polylines.clear();
    _polylines.add(polyline);
    notifyListeners();
  }

  void clearTracking() {
    _polylines.clear();
    _destinationPosition = null;
    _marker!.remove(destinationMarkerId);
    notifyListeners();
  }

  /// ✅ Haversine formula
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters

    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLat = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLng = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // meters
  }

  /// ✅ Expose distance (null if no destination set)
  double? get currentToDestinationDistance {
    if (_locationPosition == null || _destinationPosition == null) return null;
    return calculateDistance(_locationPosition!, _destinationPosition!);
  }
}
