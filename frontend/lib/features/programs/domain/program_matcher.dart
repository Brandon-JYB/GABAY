import '../../profile/domain/user_profile.dart';
import 'program.dart';

/// The four filter groups. Several database levels fold into one group.
enum LevelGroup {
  city('levelCity'),
  district('levelDistrict'),
  provincial('levelProvincial'),
  national('levelNational');

  const LevelGroup(this.labelKey);

  /// Key for `context.tr(...)`.
  final String labelKey;
}

/// Maps a program's level text to its group, e.g.
/// "5th Congressional District / DOH" -> district,
/// "National / PhilHealth" and "National (DSWD / PCSO)" -> national.
LevelGroup? levelGroupOf(String level) {
  final l = level.toLowerCase();
  if (l.contains('5th congressional')) return LevelGroup.district;
  if (l.contains('city lgu')) return LevelGroup.city;
  if (l.contains('provincial')) return LevelGroup.provincial;
  if (l.contains('national')) return LevelGroup.national;
  return null;
}

/// Decides whether a program fits a person's saved profile.
///
/// Rules (a missing/blank profile field never hides a program):
///  - City LGU + 5th District programs  -> must live in Batangas City
///  - Provincial programs               -> must live in Batangas (province or city)
///  - PhilHealth programs               -> must be a PhilHealth member
///  - Point-of-Care enrollment (uninsured) -> must NOT be a PhilHealth member
///  - National / DOH / DSWD / PCSO / tertiary care -> open to everyone
class ProgramMatcher {
  const ProgramMatcher(this.profile);

  final UserProfile profile;

  /// True when the profile has nothing the matcher can use yet.
  bool get isProfileEmpty =>
      _blank(profile.city) &&
          _blank(profile.province) &&
          profile.isPhilhealth == null;

  bool matches(Program p) {
    final level = p.level.toLowerCase();
    final name = p.name.toLowerCase();
    final who = p.whoCanAvail.toLowerCase();

    // PhilHealth enrollment for the uninsured: only if NOT a member.
    if (name.contains('point-of-care') || who.contains('uninsured')) {
      return profile.isPhilhealth != true && _livesInBatangas;
    }

    // PhilHealth benefit programs: only for members.
    if (level.contains('philhealth')) {
      return profile.isPhilhealth != false;
    }

    // City LGU and 5th District (but not the DOH tertiary-care row).
    if (level.contains('city lgu') ||
        (level.contains('5th congressional') && !level.contains('doh'))) {
      return _livesInBatangasCity;
    }

    // Provincial programs.
    if (level.contains('provincial')) {
      return _livesInBatangas;
    }

    // National / DOH / DSWD / PCSO / tertiary: open to all.
    return true;
  }

  bool get _livesInBatangasCity =>
      _blank(profile.city) || _has(profile.city, 'batangas');

  bool get _livesInBatangas =>
      (_blank(profile.city) && _blank(profile.province)) ||
          _has(profile.province, 'batangas') ||
          _has(profile.city, 'batangas');

  static bool _blank(String? s) => s == null || s.trim().isEmpty;
  static bool _has(String? s, String needle) =>
      s != null && s.toLowerCase().contains(needle);
}