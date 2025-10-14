class User {
  final String? id;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? picture; // URL or base64
  final DateTime? birthday;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? bio;
  final String? token;
  final String? refreshToken;
  final String? role;

  User({
    this.id,
    this.email,
    this.password,
    this.refreshToken,
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

  /// ✅ Parse from JSON (handles APIs that wrap data in 'data')
  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return User(
      id: data['id']?.toString(),
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      phoneNumber: data['phone'] ?? data['phoneNumber'],
      role: data['role'],
      token: json['access_token'] ?? data['token'],
      picture: data['picture'],
      birthday:
          data['birthday'] != null ? DateTime.tryParse(data['birthday']) : null,
      gender: data['gender'],
      address: data['address'],
      city: data['city'],
      country: data['country'],
      zipCode: data['zipCode'],
      bio: data['bio'],
    );
  }

  /// ✅ Convert to JSON (for saving or API calls)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'picture': picture,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
      'zipCode': zipCode,
      'bio': bio,
      'token': token,
      'refreshToken': refreshToken,
      'role': role,
    };
  }

  /// ✅ Create a copy with updated values (for immutability)
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? phoneNumber,
    String? picture,
    DateTime? birthday,
    String? gender,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? country,
    String? zipCode,
    String? bio,
    String? token,
    String? refreshToken,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      picture: picture ?? this.picture,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      bio: bio ?? this.bio,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
    );
  }
}
