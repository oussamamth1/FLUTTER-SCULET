import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// StateNotifier for auth
class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository repository;
  AuthNotifier(this.repository) : super(null) {
    checkLogin();
  }

  Future<void> checkLogin() async {
    final loggedIn = await repository.isLoggedIn();
    if (loggedIn) {
      final email = Hive.box('authBox').get('userEmail', defaultValue: 'user@example.com');
      state = User(email: email);
    }
  }

  Future<void> login(String email, String password) async {
    final user = await repository.login(email, password);
    state = user;
  }

  Future<void> logout() async {
    await repository.logout();
    state = null;
  }

  bool get isLoggedIn => state != null;
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});
