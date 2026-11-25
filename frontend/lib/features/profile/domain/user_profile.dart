/// The parts of the profile that count toward "finish setting up your account".
enum SetupStep { personal, address, assistance }

class SetupProgress {
  const SetupProgress(this.pending);

  /// Steps that are still incomplete, in the order the user should do them.
  final List<SetupStep> pending;

  static const int total = 3;

  int get completed => total - pending.length;
  bool get isComplete => pending.isEmpty;
  SetupStep? get next => pending.isEmpty ? null : pending.first;
}

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

  /// Which setup steps are still missing. Sitio is optional, so it is ignored.
  SetupProgress get setupProgress {
    final pending = <SetupStep>[];
    if (name.trim().isEmpty ||
        birthday == null ||
        gender == null ||
        civilStatus == null) {
      pending.add(SetupStep.personal);
    }
    if (barangay.trim().isEmpty ||
        city.trim().isEmpty ||
        province.trim().isEmpty) {
      pending.add(SetupStep.address);
    }
    if (isPhilhealth == null || isPwd == null) {
      pending.add(SetupStep.assistance);
    }
    return SetupProgress(pending);
  }
}