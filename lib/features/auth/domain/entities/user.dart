import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String? email;

  @HiveField(1)
  final String? password;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final String? picture; // URL or base64

  @HiveField(4)
  final DateTime? birthday;

  @HiveField(5)
  final String? gender;

  @HiveField(6)
  final String? firstName;

  @HiveField(7)
  final String? lastName;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final String? city;

  @HiveField(10)
  final String? country;

  @HiveField(11)
  final String? zipCode;

  @HiveField(12)
  final String? bio;

  @HiveField(13)
  final String? token;

  @HiveField(14)
  final String? id;

  @HiveField(15)
  final String? role;

  User({
    this.id,
    this.email,
    this.password,
    this.phoneNumber,
    this.picture,
    this.birthday,
    this.gender,
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.bio,
    this.token,
    this.role,
  });

  // ✅ fromJson for API responses (extract nested 'data' if needed)
  factory User.fromJson(Map<String, dynamic> json) {
    // If the API returns a top-level 'data' object
    final data = json['data'] ?? json;

    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      phoneNumber: data['phone'] ?? '',
      role: data['role'],
      token: json['access_token'] ?? '', // token is outside 'data'
      // Other fields can be mapped here if returned by API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phoneNumber,
      'role': role,
      'token': token,
    };
  }
}
