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

  @override
  void initState() {
    super.initState();
    locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Initialize location + custom pins
    locationProvider.initialization().then((_) {
      // Load API positions after initialization
      locationProvider.loadPositionsFromApi("https://your-api.com/positions",context
      ).then((_) {
        setState(() {
          _loadingPositions = false;
        });
      });
    });
  }

  void _onMapTapped(LatLng tappedPoint, LocationProvider model) {
    print('Map tapped at: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
    model.addDestinationMarker(tappedPoint);
    model.createTrackingLine(tappedPoint,Colors.red);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Destination set at: ${tappedPoint.latitude.toStringAsFixed(4)}, ${tappedPoint.longitude.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          locationProvider.clearTracking();
        },
        child: const Icon(Icons.clear),
        tooltip: 'Clear tracking line',
      ),
      body: Consumer<LocationProvider>(
        builder: (context, model, child) {
          if (model.locationPosition == null || _loadingPositions) {
            return const Center(child: CircularProgressIndicator());
          }

          final distance = model.currentToDestinationDistance;
          String distanceText = "";
          if (distance != null) {
            distanceText = distance > 1000
                ? "${(distance / 1000).toStringAsFixed(2)} km"
                : "${distance.toStringAsFixed(0)} m";
          }

          return Column(
            children: [
              if (distance != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
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
                  child: Text(
                    "Distance to destination: $distanceText",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              Expanded(
                child: GoogleMap(
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
              ),
            ],
          );
        },
      ),
    );
  }
}
