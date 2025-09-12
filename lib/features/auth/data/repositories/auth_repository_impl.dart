import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyEmail = 'userEmail';
  static const _keyToken = 'authToken';
  static const _keyId = 'id';

  final Box _box = Hive.box('authBox');
  final Dio _dio = Dio();
  CookieJar? _cookieJar;

  AuthRepositoryImpl() {
    _dio.options.baseUrl = "https://api.staging.zenifytrip.com";
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // ✅ Use Cookie Manager only on mobile/desktop
    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // ✅ Attach token automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _box.get(_keyToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/api/auth/login",
        data: {"username": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        final userData = resData['data']; // ✅ extract the 'data' field

        // Save login details
        await _box.put(_keyLoggedIn, true);
        await _box.put(_keyEmail, userData['email']);
        await _box.put(_keyToken, resData['access_token']);
        await _box.put(_keyId, userData['id']); // Save userId

        print(resData.toString());

        return User.fromJson(userData);
      }
    } on DioException catch (e) {
      print("Login error: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("Unexpected error: $e");
    }
    return null;
  }

  @override
  Future<void> logout() async {
    if (!kIsWeb) {
      await _cookieJar?.deleteAll();
    }
    await _box.delete(_keyLoggedIn);
    await _box.delete(_keyEmail);
    await _box.delete(_keyToken);
    await _box.delete(_keyId);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _box.get(_keyLoggedIn, defaultValue: false);
  }

  // 🔥 New: Fetch user profile
  Future<User?> getUserProfile() async {
    try {
      final userId = _box.get(_keyId);
      if (userId == null) {
        print("No user ID stored, please login first.");
        return null;
      }

      final response = await _dio.get("/api/users/$userId");

      if (response.statusCode == 200) {
        final data = response.data;
print(data.toString());
        return User.fromJson(data); // Make sure User has fromJson
      }
    } on DioException catch (e) {
      print("Profile fetch error: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("Unexpected error: $e");
    }
    return null;
  }
}
