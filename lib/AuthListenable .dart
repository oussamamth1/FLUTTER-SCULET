import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:zenify_auth/zenify_auth.dart' as auth;

class AuthListenable extends ChangeNotifier {
  AuthListenable(WidgetRef ref) {
    ref.listen<auth.AuthState<auth.User>>(
      auth.authProvider, (_, __) => notifyListeners());
  }
}
