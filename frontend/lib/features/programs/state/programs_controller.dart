import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart';

import '../data/program_repository.dart';
import '../domain/program.dart';

class ProgramsController extends ChangeNotifier {
  ProgramsController(this._repository);

  final ProgramRepository _repository;

  List<Program> _programs = const [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isOfflineError = false;

  List<Program> get programs => _programs;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOfflineError => _isOfflineError;

  /// Distinct governance levels, in the order they first appear.
  List<String> get levels => _programs.map((p) => p.level).toSet().toList();

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;
    _isOfflineError = false;
    notifyListeners();
    try {
      _programs = await _repository.fetchAll();
    } catch (e) {
      _hasError = true;
      final raw = e.toString().toLowerCase();
      _isOfflineError = raw.contains('socketexception') ||
          raw.contains('failed host lookup') ||
          raw.contains('network is unreachable') ||
          raw.contains('connection failed');
      debugPrint('Programs load failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Put this above MaterialApp, next to ProfileScope.
class ProgramsScope extends InheritedNotifier<ProgramsController> {
  const ProgramsScope({
    super.key,
    required ProgramsController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProgramsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgramsScope>();
    assert(scope != null, 'ProgramsScope not found above this context');
    return scope!.notifier!;
  }
}