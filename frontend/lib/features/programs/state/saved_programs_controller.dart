import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../domain/program.dart';

/// How a program is remembered. If Program has a unique `id`, return that
/// instead of the name so saves survive a rename.
String programKey(Program p) => p.name;

/// Saved programs and recently viewed programs, kept per account on this
/// device. Newest first.
class SavedProgramsController extends ChangeNotifier {
  static const _maxRecent = 10;

  List<String> _saved = const [];
  List<String> _recent = const [];
  String? _uid;

  List<String> get savedKeys => _saved;
  List<String> get recentKeys => _recent;

  bool isSaved(Program p) => _saved.contains(programKey(p));

  /// Call after login. Safe to call more than once.
  Future<void> load() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    _uid = uid;
    final prefs = await SharedPreferences.getInstance();
    _saved = prefs.getStringList('saved_programs_$uid') ?? const [];
    _recent = prefs.getStringList('recent_programs_$uid') ?? const [];
    notifyListeners();
  }

  void toggleSaved(Program p) {
    final key = programKey(p);
    final list = [..._saved];
    if (!list.remove(key)) list.insert(0, key);
    _saved = list;
    notifyListeners();
    _persist();
  }

  void markViewed(Program p) {
    final key = programKey(p);
    if (_recent.isNotEmpty && _recent.first == key) return;
    final list = [..._recent]..remove(key);
    list.insert(0, key);
    if (list.length > _maxRecent) list.length = _maxRecent;
    _recent = list;
    notifyListeners();
    _persist();
  }

  /// Removes the given programs from "Recently viewed".
  void removeRecent(List<String> keys) {
    if (keys.isEmpty) return;
    _recent = [
      for (final k in _recent)
        if (!keys.contains(k)) k,
    ];
    notifyListeners();
    _persist();
  }

  void clearRecent() {
    if (_recent.isEmpty) return;
    _recent = const [];
    notifyListeners();
    _persist();
  }

  /// Call on logout so the next user doesn't see this list.
  void clear() {
    _saved = const [];
    _recent = const [];
    _uid = null;
    notifyListeners();
  }

  Future<void> _persist() async {
    _uid ??= Supabase.instance.client.auth.currentUser?.id;
    final uid = _uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_programs_$uid', _saved);
    await prefs.setStringList('recent_programs_$uid', _recent);
  }
}

/// Put this above MaterialApp, next to ProgramsScope.
class SavedProgramsScope extends InheritedNotifier<SavedProgramsController> {
  const SavedProgramsScope({
    super.key,
    required SavedProgramsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SavedProgramsController of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<SavedProgramsScope>();
    assert(scope != null, 'SavedProgramsScope not found above this context');
    return scope!.notifier!;
  }
}