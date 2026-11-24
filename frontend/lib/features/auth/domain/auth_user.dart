class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.genderStatus,
    required this.address,
    required this.email,
  });

  final String id;
  final String fullName;
  final DateTime birthDate;
  final String genderStatus;
  final String address;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      genderStatus: json['gender_status'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender_status': genderStatus,
      'address': address,
      'email': email,
    };
  }
}
