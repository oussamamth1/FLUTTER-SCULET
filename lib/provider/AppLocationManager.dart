// // Add this to your main.dart or a dedicated app manager file

// import 'package:zenifytrip_guide/provider/location_provider.dart';

// class AppLocationManager {
//   static LocationProvider? _instance;
//   static bool _isInitialized = false;

//   static Future<LocationProvider> getInstance() async {
//     if (_instance == null || !_isInitialized) {
//       _instance = LocationProvider();
//       await _instance!.initialization(startTracking: false);
//       _isInitialized = true;
//     }
//     return _instance!;
//   }

//   static LocationProvider? get instanceSync => _instance;

//   static bool get isInitialized => _isInitialized;

//   static void dispose() {
//     _instance?.dispose();
//     _instance = null;
//     _isInitialized = false;
//   }
// }
