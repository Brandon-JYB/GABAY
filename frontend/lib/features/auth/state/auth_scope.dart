import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// Makes AuthController available to the whole widget tree without
/// adding a package. Replace with Provider/Riverpod/Bloc later if you like.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Use inside build(): rebuilds when auth state changes.
  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found above this context');
    return scope!.notifier!;
  }

  /// Use inside callbacks: does not subscribe to changes.
  static AuthController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found above this context');
    return scope!.notifier!;
  }
}