// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';

// import 'package:zenifytrip_guide/provider/location_provider.dart';
// import 'package:zenifytrip_guide/provider/mapSecreen..dart';

// // Import your LocationProvider
// // import 'your_location_provider.dart';

// class MapScreen extends StatelessWidget {
//   final LocationProvider? locationProvider;
  
//   const MapScreen({Key? key, this.locationProvider}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {

//     return ChangeNotifierProvider.value(
//       value: locationProvider ?? _getOrCreateLocationProvider(context),
//       child: const MapScreenContent(),
//     );
//   }

//   LocationProvider _getOrCreateLocationProvider(BuildContext context) {
//     // Try to get existing provider from higher up in the widget tree
//     try {
//       return Provider.of<LocationProvider>(context, listen: false);
//     } catch (e) {
//       // If not found, create new one
//       final provider = LocationProvider();
//       // Only initialize if not already initialized
//       if (provider.locationPosition == null) {
//         provider.initialization(startTracking: true);
//         provider.loadPositionsFromApi('', context);
//       }
//       return provider;
//     }
//   }
// }
