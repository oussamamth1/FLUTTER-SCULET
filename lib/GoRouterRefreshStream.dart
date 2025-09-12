import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zenify_auth/zenify_auth.dart';

/// Wrap a Stream or StateNotifier into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {

      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
