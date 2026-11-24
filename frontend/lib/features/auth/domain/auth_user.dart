class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.birthday,
    required this.gender,
    required this.barangay,
    this.sitio,
    this.civilStatus,
    this.isPhilhealthMember = false,
    this.isPwd = false,
  });

  final String id;
  final String email;
  final String fullName;
  final DateTime birthday;
  final String gender;
  final String barangay;
  final String? sitio;
  final String? civilStatus;
  final bool isPhilhealthMember;
  final bool isPwd;

  // Compatibility getters: old code that uses these names keeps working.
  DateTime get birthDate => birthday;
  String get genderStatus => gender;
  String get address =>
      '${sitio != null && sitio!.isNotEmpty ? '$sitio, ' : ''}Brgy. $barangay, Batangas City';

  /// Keys match the columns of public.users.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      birthday: DateTime.parse(json['birthday'] as String),
      gender: json['gender'] as String,
      barangay: json['barangay'] as String,
      sitio: json['sitio'] as String?,
      civilStatus: json['civil_status'] as String?,
      isPhilhealthMember: (json['is_philhealth_member'] as bool?) ?? false,
      isPwd: (json['is_pwd'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'birthday': birthday.toIso8601String().split('T').first,
      'gender': gender,
      'barangay': barangay,
      'sitio': sitio,
      'civil_status': civilStatus,
      'is_philhealth_member': isPhilhealthMember,
      'is_pwd': isPwd,
    };
  }
}