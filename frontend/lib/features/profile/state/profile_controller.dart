import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  UserProfile _profile = const UserProfile();
  bool _isLoading = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repository.fetch();
      debugPrint(
          'PROFILE LOADED: name="${_profile.name}" barangay="${_profile.barangay}" city="${_profile.city}"');
    } catch (e, st) {
      // Keep the empty profile; the user can still fill it in.
      debugPrint('PROFILE LOAD ERROR: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Throws if saving fails, so the screen can show an error.
  Future<void> save(UserProfile profile) async {
    await _repository.save(profile);
    _profile = profile;
    notifyListeners();
  }

  /// Call on logout so the next user doesn't see this profile.
  void clear() {
    _profile = const UserProfile();
    notifyListeners();
  }
}

/// Put this above MaterialApp, next to AuthScope.
class ProfileScope extends InheritedNotifier<ProfileController> {
  const ProfileScope({
    super.key,
    required ProfileController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProfileController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfileScope>();
    assert(scope != null, 'ProfileScope not found above this context');
    return scope!.notifier!;
  }
}