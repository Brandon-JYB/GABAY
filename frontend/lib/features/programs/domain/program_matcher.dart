
import '../../profile/domain/user_profile.dart';
import 'program.dart';

enum LevelGroup {
  city('levelCity'),
  district('levelDistrict'),
  provincial('levelProvincial'),
  national('levelNational');

  const LevelGroup(this.labelKey);

  final String labelKey;
}

LevelGroup? levelGroupOf(String level) {
  final l = level.toLowerCase();
  if (l.contains('5th congressional')) return LevelGroup.district;
  if (l.contains('city lgu')) return LevelGroup.city;
  if (l.contains('provincial')) return LevelGroup.provincial;
  if (l.contains('national')) return LevelGroup.national;
  return null;
}

class ProgramMatcher {
  const ProgramMatcher(this.profile);

  final UserProfile profile;

  bool get isProfileEmpty => profile.isPhilhealth == null;

  bool matches(Program p) {
    final level = p.level.toLowerCase();
    final name = p.name.toLowerCase();
    final who = p.whoCanAvail.toLowerCase();

    // PhilHealth enrollment for the uninsured.
    if (name.contains('point-of-care') || who.contains('uninsured')) {
      return profile.isPhilhealth != true;
    }

    // PhilHealth benefit programs.
    if (level.contains('philhealth')) {
      return profile.isPhilhealth != false;
    }

    // City LGU, 5th District, and provincial programs.
    // Location filtering has been removed.
    return true;
  }
}
