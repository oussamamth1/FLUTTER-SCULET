import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;

class MapScreenContent extends ConsumerStatefulWidget {
  const MapScreenContent({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends ConsumerState<MapScreenContent>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  bool _hasShownMap = false;
  bool _isCreatingRoute = false;
  MapType _currentMapType = MapType.normal;

  // Animation controllers
  late AnimationController _cardAnimationController;
  late Animation<Offset> _cardSlideAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  // Colors
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF4CAF50);
  late final LocationProvider locationProvider;
  // Custom map style
  String? _customMapStyle;
  String? pictureUrl;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //         final authState = ref.read(zenifyAuth.authProvider);
    //       pictureUrl = authState.user?.picture;
    //       print(pictureUrl);
    //       print("pictureUrl pictureUrl: pictureUrl");
    //    locationProvider   = context.read<LocationProvider>();
    //       locationProvider.setPictureUrl(
    //         "${AppEnvironment.baseApiUrl}/assets/uploads/traveller/$pictureUrl",
    //       );
    //       locationProvider.setCustomMapPin(
    //         "${AppEnvironment.baseApiUrl}/assets/uploads/traveller/$pictureUrl",
    //       );
    //     });
    //     Future.microtask(() {

    //     });
    _initializeAnimations();
    _loadMapStyle();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadMapStyle() async {
    _customMapStyle = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/map_style.json').catchError((error) {
      debugPrint('Could not load map style: $error');
      return '';
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("Auth Cookie: $authCookie");
    return Scaffold(
      backgroundColor: backgroundGrey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SearchWidget(
            onChanged: (query) {
              locationProvider.updateSearch(query, context);
            },
          ),
        ),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, model, child) {
          // Show loading only on first initialization or when explicitly loading
          if (model.locationPosition == null && !_hasShownMap) {
            return _buildLoadingScreen();
          }

          _hasShownMap = true;

          // Trigger card animation when route is created
          if (model.polylines.isNotEmpty) {
            _cardAnimationController.forward();
          } else {
            _cardAnimationController.reverse();
          }

          return Stack(
            children: [
              // Main Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: model.locationPosition!,
                  zoom: 16.0,
                ),
                mapType: _currentMapType,
                compassEnabled: true,
                trafficEnabled: true,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: Set<Marker>.of(model.marker!.values),
                polylines: model.polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng tappedPoint) {
                  _onMapTapped(tappedPoint, model);
                },
                style:
                    _currentMapType == MapType.normal ? _customMapStyle : null,
              ),

              // Route info card
              if (model.polylines.isNotEmpty)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: SlideTransition(
                    position: _cardSlideAnimation,
                    child: _buildRouteInfoCard(model),
                  ),
                ),

              // Loading overlay
              if (_isCreatingRoute) _buildLoadingOverlay(),

              // Instructions
              if (model.polylines.isEmpty && !_isCreatingRoute)
                _buildInstructionsCard(),

              // Control buttons
              _buildControlButtons(model),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: backgroundGrey,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your location...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard(LocationProvider model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.navigation,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      model.routeSummary,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _clearRoute(model),
                icon: const Icon(Icons.close, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (model.isTrackingEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Live tracking',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating route...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.touch_app, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tap on the map or select a person to create a route',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(LocationProvider model) {
    return Positioned(
      bottom: 30,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map type toggle
          ScaleTransition(
            scale: _buttonScaleAnimation,
            child: FloatingActionButton(
              heroTag: "map_type",
              onPressed: _toggleMapType,
              backgroundColor: surfaceColor,
              child: Icon(
                _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // My location button
          FloatingActionButton(
            heroTag: "my_location",
            onPressed: () => _goToCurrentLocation(model),
            backgroundColor: surfaceColor,
            child: const Icon(Icons.my_location, color: primaryColor),
          ),
          const SizedBox(height: 12),

          // Clear route button (if route exists)
          if (model.polylines.isNotEmpty)
            FloatingActionButton(
              heroTag: "clear_route",
              onPressed: () => _clearRoute(model),
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear, color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng tappedPoint, LocationProvider model) async {
    setState(() {
      _isCreatingRoute = true;
    });

    model.addDestinationMarker(tappedPoint);
    await model.createWorkingRoute(tappedPoint, primaryColor);

    setState(() {
      _isCreatingRoute = false;
    });
  }

  void _toggleMapType() {
    _buttonAnimationController.forward().then((_) {
      setState(() {
        _currentMapType =
            _currentMapType == MapType.normal
                ? MapType.satellite
                : MapType.normal;
      });
      _buttonAnimationController.reverse();
    });
  }

  Future<void> _goToCurrentLocation(LocationProvider model) async {
    if (model.locationPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(model.locationPosition!, 16.0),
      );
    }
  }

  void _clearRoute(LocationProvider model) {
    model.clearTracking();
    _cardAnimationController.reverse();
  }
}

// Search Widget Component
class SearchWidget extends StatefulWidget {
  final Function(String) onChanged;

  const SearchWidget({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search for people...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: widget.onChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              child: const Icon(Icons.clear, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
