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

  User({
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
  });
}
