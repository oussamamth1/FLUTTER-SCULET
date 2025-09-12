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
      final box = Hive.box('authBox');
      final email = box.get('userEmail', defaultValue: '');
      final token = box.get('authToken');
      state = User(email: email, token: token);
    }
  }

  Future<void> login(String email, String password) async {
    final user = await repository.login(email, password);
    state = user; // UI can check if null for errors
    print("// UI Future<void> login( can check if null for errors");
  }

  Future<void> logout() async {
    await repository.logout();
    state = null;
  }

  bool get isLoggedIn => state != null;

  // 🔥 New: fetch full profile
  Future<void> fetchUserProfile() async {
    final profile = await repository.getUserProfile();
    if (profile != null) {
      state = profile;
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});
