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
  String? _errorDetail;

  List<Program> get programs => _programs;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// The raw error text. Only shown in debug builds, to find out why loading failed.
  String? get errorDetail => _errorDetail;

  /// Distinct governance levels, in the order they first appear.
  List<String> get levels => _programs.map((p) => p.level).toSet().toList();

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;
    _errorDetail = null;
    notifyListeners();
    try {
      _programs = await _repository.fetchAll();
    } catch (e) {
      _hasError = true;
      _errorDetail = e.toString();
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