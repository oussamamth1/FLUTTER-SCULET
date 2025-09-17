// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:zenifytrip_guide/provider/location_provider.dart';
// import 'package:zenifytrip_guide/widgets/search_widget.dart';

// class ExplorePage extends StatefulWidget {
//   const ExplorePage({Key? key}) : super(key: key);

//   @override
//   _ExplorePageState createState() => _ExplorePageState();
// }

// class _ExplorePageState extends State<ExplorePage>
//     with TickerProviderStateMixin {
//   final Completer<GoogleMapController> _controller = Completer();
//   late LocationProvider locationProvider;
//   late AnimationController _fabAnimationController;
//   late AnimationController _cardAnimationController;
//   late Animation<double> _fabAnimation;
//   late Animation<Offset> _cardSlideAnimation;

//   bool _loadingPositions = true;
//   bool _isCreatingRoute = false;
//   bool _showRouteOptions = false;
//   MapType _currentMapType = MapType.normal;

//   // Professional color scheme
//   static const Color primaryBlue = Color(0xFF1E88E5);
//   static const Color primaryDark = Color(0xFF1565C0);
//   static const Color accentColor = Color(0xFF00BCD4);
//   static const Color successGreen = Color(0xFF4CAF50);
//   static const Color warningOrange = Color(0xFFFF9800);
//   static const Color errorRed = Color(0xFFE53935);
//   static const Color surfaceColor = Color(0xFFFFFFFF);
//   static const Color backgroundGrey = Color(0xFFF8F9FA);

//   @override
//   void initState() {
//     super.initState();
//     locationProvider = Provider.of<LocationProvider>(context, listen: false);

//     // Initialize animations
//     _fabAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _cardAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
//     );

//     _cardSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _cardAnimationController,
//         curve: Curves.elasticOut,
//       ),
//     );

//     //_initializeLocation();
//   }

//   // Future<void> _initializeLocation() async {
//   //   try {
//   //     await locationProvider.initialization();
//   //     await locationProvider.loadPositionsFromApi(
//   //       "https://your-api.com/positions",
//   //       context,
//   //     );
//   //     setState(() {
//   //       _loadingPositions = false;
//   //     });
//   //     _fabAnimationController.forward();
//   //   } catch (e) {
//   //     _showErrorSnackBar('Failed to load location data');
//   //     setState(() {
//   //       _loadingPositions = false;
//   //     });
//   //   }
//   // }

//   // void _onMapTapped(LatLng tappedPoint, LocationProvider model) async {
//   //   HapticFeedback.lightImpact();

//   //   setState(() {
//   //     _isCreatingRoute = true;
//   //   });

//   //   try {
//   //     model.addDestinationMarker(tappedPoint);
//   //     await model.createWorkingRoute(tappedPoint, primaryBlue);

//   //     _cardAnimationController.forward();
//   //     _showSuccessSnackBar(
//   //       'Route created successfully',
//   //       action: SnackBarAction(
//   //         label: 'Clear',
//   //         textColor: surfaceColor,
//   //         onPressed: () => _clearRoute(model),
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     _showErrorSnackBar('Failed to create route');
//   //   } finally {
//   //     setState(() {
//   //       _isCreatingRoute = false;
//   //     });
//   //   }
//   // }

//   void _clearRoute(LocationProvider model) {
//     HapticFeedback.selectionClick();
//     model.clearTracking();
//     _cardAnimationController.reverse();
//     _showInfoSnackBar('Route cleared');
//   }

//   void _toggleMapType() {
//     HapticFeedback.selectionClick();
//     setState(() {
//       _currentMapType =
//           _currentMapType == MapType.normal
//               ? MapType.satellite
//               : MapType.normal;
//     });
//   }

//   void _centerOnUserLocation() async {
//     HapticFeedback.lightImpact();
//     if (locationProvider.locationPosition != null) {
//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: locationProvider.locationPosition!,
//             zoom: 16.0,
//           ),
//         ),
//       );
//     }
//   }

//   void _showRouteDetails(LocationProvider model) {
//     if (model.polylines.isEmpty) return;

//     final routeDistance = _getRouteDistanceText(model);
//     final estimatedTime = _getEstimatedTime(model);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) =>
//               _buildRouteDetailsSheet(routeDistance, estimatedTime, model),
//     );
//   }

//   Widget _buildRouteDetailsSheet(
//     String distance,
//     String time,
//     LocationProvider model,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: primaryBlue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.route,
//                         color: primaryBlue,
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Expanded(
//                       child: Text(
//                         'Route Information',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Route stats
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         icon: Icons.straighten,
//                         label: 'Distance',
//                         value: distance,
//                         color: primaryBlue,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildStatCard(
//                         icon: Icons.access_time,
//                         label: 'Est. Time',
//                         value: time,
//                         color: successGreen,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 _buildStatCard(
//                   icon: Icons.timeline,
//                   label: 'Route Points',
//                   value: '${model.polylines.first.points.length}',
//                   color: accentColor,
//                   fullWidth: true,
//                 ),

//                 const SizedBox(height: 12),

//                 // Action buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _clearRoute(model);
//                         },
//                         icon: const Icon(Icons.clear),
//                         label: const Text('Clear Route'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: errorRed,
//                           foregroundColor: surfaceColor,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.done),
//                         label: const Text('Got It'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryBlue,
//                           foregroundColor: surfaceColor,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     bool fullWidth = false,
//   }) {
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getRouteDistanceText(LocationProvider model) {
//     if (model.polylines.isEmpty) return "0 m";

//     final polyline = model.polylines.first;
//     if (polyline.points.length < 2) return "0 m";

//     double totalDistance = 0.0;
//     for (int i = 0; i < polyline.points.length - 1; i++) {
//       totalDistance += model.calculateDistance(
//         polyline.points[i],
//         polyline.points[i + 1],
//       );
//     }

//     return totalDistance > 1000
//         ? "${(totalDistance / 1000).toStringAsFixed(1)} km"
//         : "${totalDistance.toStringAsFixed(0)} m";
//   }

//   String _getEstimatedTime(LocationProvider model) {
//     if (model.polylines.isEmpty) return "0 min";

//     final routeDistance = _getRouteDistanceText(model);
//     final distanceValue =
//         double.tryParse(routeDistance.replaceAll(RegExp(r'[^0-9.]'), '')) ??
//         0.0;

//     final isKm = routeDistance.contains('km');
//     final distanceInKm = isKm ? distanceValue : distanceValue / 1000;

//     // Estimate based on average urban speed (30 km/h)
//     final estimatedMinutes = (distanceInKm / 30 * 60).round();

//     return estimatedMinutes < 60
//         ? "$estimatedMinutes min"
//         : "${(estimatedMinutes / 60).floor()}h ${estimatedMinutes % 60}m";
//   }

//   void _showSuccessSnackBar(String message, {SnackBarAction? action}) {
//     _showCustomSnackBar(
//       message,
//       successGreen,
//       Icons.check_circle,
//       action: action,
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     _showCustomSnackBar(message, errorRed, Icons.error);
//   }

//   void _showInfoSnackBar(String message) {
//     _showCustomSnackBar(message, warningOrange, Icons.info);
//   }

//   void _showCustomSnackBar(
//     String message,
//     Color color,
//     IconData icon, {
//     SnackBarAction? action,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: surfaceColor),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//         action: action,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fabAnimationController.dispose();
//     _cardAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundGrey,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         title: Container(
//           decoration: BoxDecoration(
//             color: surfaceColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: SearchWidget(
//             onChanged: (query) {
//               locationProvider.updateSearch(query, context);
//             },
//           ),
//         ),
//       ),
//       body: Consumer<LocationProvider>(
//         builder: (context, model, child) {
//           if (model.locationPosition == null || _loadingPositions) {
//             return _buildLoadingScreen();
//           }

//           return Stack(
//             children: [
//               // Main Google Map
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: model.locationPosition!,
//                   zoom: 16.0,
//                 ),
//                 mapType: _currentMapType,
//                 compassEnabled: true,
//                 trafficEnabled: true,
//                 zoomControlsEnabled: false,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 markers: Set<Marker>.of(model.marker!.values),
//                 polylines: model.polylines,
//                 onMapCreated: (GoogleMapController controller) {
//                   _controller.complete(controller);
//                 },
//                 onTap: (LatLng tappedPoint) {
//                 //  _onMapTapped(tappedPoint, model);
//                 },
//                 style:
//                     _currentMapType == MapType.normal ? _customMapStyle : null,
//               ),

//               // Route info card
//               if (model.polylines.isNotEmpty)
//                 Positioned(
//                   top: 100,
//                   left: 16,
//                   right: 16,
//                   child: SlideTransition(
//                     position: _cardSlideAnimation,
//                     child: _buildRouteInfoCard(model),
//                   ),
//                 ),

//               // Loading overlay
//               if (_isCreatingRoute) _buildLoadingOverlay(),

//               // Instructions
//               if (model.polylines.isEmpty && !_isCreatingRoute)
//                 _buildInstructionsCard(),

//               // Control buttons
//               _buildControlButtons(model),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingScreen() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [primaryBlue, primaryDark],
//         ),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: surfaceColor),
//             SizedBox(height: 24),
//             Text(
//               'Discovering your world...',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: surfaceColor,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Loading locations and preparing your map',
//               style: TextStyle(fontSize: 14, color: Colors.white70),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRouteInfoCard(LocationProvider model) {
//     final routeDistance = _getRouteDistanceText(model);
//     final estimatedTime = _getEstimatedTime(model);

//     return GestureDetector(
//       onTap: () => _showRouteDetails(model),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: surfaceColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: primaryBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.directions_car, color: primaryBlue),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     routeDistance,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     'Est. $estimatedTime • Tap for details',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right, color: Colors.grey[400]),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black54,
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: surfaceColor,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(color: primaryBlue),
//               SizedBox(height: 16),
//               Text(
//                 'Creating your route...',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'This may take a moment',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionsCard() {
//     return Positioned(
//       bottom: 160,
//       left: 16,
//       right: 16,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: surfaceColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: primaryBlue.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: primaryBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.touch_app, color: primaryBlue),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 'Tap anywhere on the map to create a route',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButtons(LocationProvider model) {
//     return Positioned(
//       bottom: 16,
//       right: 16,
//       child: ScaleTransition(
//         scale: _fabAnimation,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Route details button
//             if (model.polylines.isNotEmpty)
//               FloatingActionButton(
//                 heroTag: "route_details",
//                 onPressed: () => _showRouteDetails(model),
//                 backgroundColor: primaryBlue,
//                 child: const Icon(Icons.info_outline, color: surfaceColor),
//               ),

//             if (model.polylines.isNotEmpty) const SizedBox(height: 8),

//             // Clear route button
//             if (model.polylines.isNotEmpty)
//               FloatingActionButton(
//                 heroTag: "clear_route",
//                 onPressed: () => _clearRoute(model),
//                 backgroundColor: errorRed,
//                 child: const Icon(Icons.clear, color: surfaceColor),
//               ),

//             if (model.polylines.isNotEmpty) const SizedBox(height: 8),

//             // Map type toggle
//             FloatingActionButton(
//               heroTag: "map_type",
//               onPressed: _toggleMapType,
//               backgroundColor: accentColor,
//               child: Icon(
//                 _currentMapType == MapType.normal
//                     ? Icons.satellite_alt
//                     : Icons.map,
//                 color: surfaceColor,
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Center on user location
//             FloatingActionButton(
//               heroTag: "center_location",
//               onPressed: _centerOnUserLocation,
//               backgroundColor: successGreen,
//               child: const Icon(Icons.my_location, color: surfaceColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static const String _customMapStyle = '''
//     [
//       {
//         "featureType": "poi",
//         "elementType": "labels.text",
//         "stylers": [{"visibility": "off"}]
//       },
//       {
//         "featureType": "poi.business",
//         "stylers": [{"visibility": "off"}]
//       },
//       {
//         "featureType": "road",
//         "elementType": "labels.icon",
//         "stylers": [{"visibility": "off"}]
//       }
//     ]
//   ''';
// }
