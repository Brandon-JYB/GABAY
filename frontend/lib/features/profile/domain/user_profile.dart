/// The applicant's profile. All fields are optional until the user fills them in.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.birthday,
    this.gender,
    this.civilStatus,
    this.sitio = '',
    this.barangay = '',
    this.city = '',
    this.province = '',
    this.isPhilhealth,
    this.isPwd,
  });

  final String name;
  final DateTime? birthday;

  /// 'male' or 'female'
  final String? gender;

  /// 'single', 'married', 'widowed' or 'separated'
  final String? civilStatus;

  final String sitio;
  final String barangay;
  final String city;
  final String province;

  /// PhilHealth member or beneficiary? null = not answered yet.
  final bool? isPhilhealth;

  /// Person with disability? null = not answered yet.
  final bool? isPwd;

  /// True when every field matches [other]. Used to detect unsaved changes.
  bool isSameAs(UserProfile other) =>
      name == other.name &&
          birthday == other.birthday &&
          gender == other.gender &&
          civilStatus == other.civilStatus &&
          sitio == other.sitio &&
          barangay == other.barangay &&
          city == other.city &&
          province == other.province &&
          isPhilhealth == other.isPhilhealth &&
          isPwd == other.isPwd;

  /// Computed from the birthday, so it never goes out of date.
  int? get age {
    final b = birthday;
    if (b == null) return null;
    final now = DateTime.now();
    var years = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) {
      years--;
    }
    return years;
  }

  /// Automatic: 60 years old and above.
  bool get isSenior => (age ?? 0) >= 60;
}