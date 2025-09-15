import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/widgets/search_widget.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Completer<GoogleMapController> _controller = Completer();
  late LocationProvider locationProvider;
  bool _loadingPositions = true;
  bool _isCreatingRoute = false; // Loading state for route creation

  @override
  void initState() {
    super.initState();
    locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Initialize location + custom pins
    locationProvider.initialization().then((_) {
      // Load API positions after initialization
      locationProvider.loadPositionsFromApi("https://your-api.com/positions", context
      ).then((_) {
        setState(() {
          _loadingPositions = false;
        });
      });
    });
  }

  void _onMapTapped(LatLng tappedPoint, LocationProvider model) async {
    print('Map tapped at: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
    
    // Show loading state
    setState(() {
      _isCreatingRoute = true;
    });

    // Add destination marker
    model.addDestinationMarker(tappedPoint);
    
    // Create routing line (this now uses Google Directions API)
    await model.createRoutingLine(tappedPoint, Colors.red);

    // Hide loading state
    setState(() {
      _isCreatingRoute = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Route created to: ${tappedPoint.latitude.toStringAsFixed(4)}, ${tappedPoint.longitude.toStringAsFixed(4)}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Clear',
            textColor: Colors.white,
            onPressed: () {
              model.clearTracking();
            },
          ),
        ),
      );
    }
  }

  // Helper method to get route distance from polyline
  String _getRouteDistanceText(LocationProvider model) {
    if (model.polylines.isEmpty) return "";
    
    final polyline = model.polylines.first;
    if (polyline.points.length < 2) return "";
    
    // Calculate route distance by summing all segments
    double totalDistance = 0.0;
    for (int i = 0; i < polyline.points.length - 1; i++) {
      totalDistance += model.calculateDistance(polyline.points[i], polyline.points[i + 1]);
    }
    
    return totalDistance > 1000
        ? "${(totalDistance / 1000).toStringAsFixed(2)} km"
        : "${totalDistance.toStringAsFixed(0)} m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: SearchWidget(
          onChanged: (query) {
            Provider.of<LocationProvider>(context, listen: false).updateSearch(query, context);
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Route info button
          Consumer<LocationProvider>(
            builder: (context, model, child) {
              if (model.polylines.isEmpty) return const SizedBox.shrink();
              
              final routeDistance = _getRouteDistanceText(model);
              if (routeDistance.isEmpty) return const SizedBox.shrink();
              
              return FloatingActionButton.extended(
                heroTag: "route_info",
                onPressed: () {
                  // Show route details
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.route, size: 40, color: Colors.blue),
                          const SizedBox(height: 10),
                          const Text(
                            'Route Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Total Distance: $routeDistance',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Route Points: ${model.polylines.first.points.length}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              model.clearTracking();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Clear Route'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                label: Text(routeDistance),
                icon: const Icon(Icons.route),
                backgroundColor: Colors.blue,
              );
            },
          ),
          const SizedBox(height: 8),
          // Clear button
          FloatingActionButton(
            heroTag: "clear_route",
            onPressed: () {
              locationProvider.clearTracking();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Route cleared'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Icon(Icons.clear),
            tooltip: 'Clear route',
            backgroundColor: Colors.red,
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, model, child) {
          if (model.locationPosition == null || _loadingPositions) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your location...'),
                ],
              ),
            );
          }

          // Get route distance for display
          final routeDistance = _getRouteDistanceText(model);

          return Stack(
            children: [
              // Main Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: model.locationPosition!,
                  zoom: 18,
                ),
                mapType: MapType.normal,
                compassEnabled: true,
                trafficEnabled: true,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(model.marker!.values),
                polylines: model.polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng tappedPoint) {
                  _onMapTapped(tappedPoint, model);
                },
              ),
              
              // Route distance info card (top of map)
              if (routeDistance.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Route Distance: $routeDistance",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          "${model.polylines.first.points.length} points",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Loading overlay when creating route
              if (_isCreatingRoute)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Creating route...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Instructions overlay (bottom)
              if (model.polylines.isEmpty && !_isCreatingRoute)
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.touch_app, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap anywhere on the map to create a route',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}