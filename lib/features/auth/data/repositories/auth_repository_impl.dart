import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyEmail = 'userEmail';
  final Box _box = Hive.box('authBox');

  @override
  Future<User?> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      await _box.put(_keyLoggedIn, true);
      await _box.put(_keyEmail, email);
      return User(email: email);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _box.delete(_keyLoggedIn);
    await _box.delete(_keyEmail);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _box.get(_keyLoggedIn, defaultValue: false);
  }
}
