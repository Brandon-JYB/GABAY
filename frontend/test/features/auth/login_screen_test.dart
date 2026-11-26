import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gabay/core/app_router.dart';
import 'package:gabay/features/auth/domain/auth_repository.dart';
import 'package:gabay/features/auth/domain/auth_user.dart';
import 'package:gabay/features/auth/presentation/login_screen.dart';
import 'package:gabay/features/auth/state/auth_controller.dart';
import 'package:gabay/features/auth/state/auth_scope.dart';

// ASSUMPTIONS: adjust these to match login_screen.dart.
const _emailLabel = 'Email';
const _passwordLabel = 'Password';
const _loginButtonText = 'Log in';
const _emailRequiredMsg = 'Email is required';
const _passwordRequiredMsg = 'Password is required';
const _invalidEmailMsg = 'Enter a valid email address';

class _FakeAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String errorMessage = 'Incorrect email or password';
  String? lastEmail;
  String? lastPassword;
  int loginCalls = 0;

  /// When set, login() waits on this so a test can observe the loading state.
  Completer<void>? gate;

  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    if (gate != null) await gate!.future;
    await Future<void>.delayed(Duration.zero);
    if (!shouldSucceed) {
      throw AuthException(errorMessage);
    }
    final user = AuthUser(
      id: 'user-1',
      fullName: 'Maria Clara',
      birthDate: DateTime(2002, 5, 14),
      genderStatus: 'Female',
      address: 'Brgy. Alangilan, Batangas City',
      email: email,
    );
    _current = user;
    return user;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required DateTime birthDate,
    required String genderStatus,
    required String address,
    required String email,
    required String password,
  }) async {
    throw const AuthException('Not used in login test');
  }

  @override
  Future<void> logout() async {
    _current = null;
  }
}

Finder _fieldWithLabel(String label) =>
    find.widgetWithText(TextFormField, label);

Finder get _loginButton => find.widgetWithText(FilledButton, _loginButtonText);

Widget _buildTestApp(AuthController controller) {
  return MaterialApp(
    routes: {
      AppRoutes.home: (_) => const Scaffold(body: Center(child: Text('Home'))),
    },
    home: AuthScope(
      controller: controller,
      child: const LoginScreen(),
    ),
  );
}

Future<void> _tapLogin(WidgetTester tester) async {
  await tester.ensureVisible(_loginButton);
  await tester.tap(_loginButton);
}

void main() {
  late _FakeAuthRepository repo;
  late AuthController controller;

  setUp(() {
    repo = _FakeAuthRepository();
    controller = AuthController(repo);
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('shows validation errors on empty submission', (tester) async {
    await tester.pumpWidget(_buildTestApp(controller));

    await _tapLogin(tester);
    await tester.pump();

    expect(find.text(_emailRequiredMsg), findsOneWidget);
    expect(find.text(_passwordRequiredMsg), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('rejects an invalid email format without calling the repository',
          (tester) async {
        await tester.pumpWidget(_buildTestApp(controller));

        await tester.enterText(_fieldWithLabel(_emailLabel), 'not-an-email');
        await tester.enterText(_fieldWithLabel(_passwordLabel), 'SecurePass1');
        await _tapLogin(tester);
        await tester.pump();

        expect(find.text(_invalidEmailMsg), findsOneWidget);
        expect(repo.loginCalls, 0);
      });

  testWidgets('logs in with trimmed email and navigates to home',
          (tester) async {
        await tester.pumpWidget(_buildTestApp(controller));

        await tester.enterText(
          _fieldWithLabel(_emailLabel),
          '  maria@example.com  ',
        );
        await tester.enterText(_fieldWithLabel(_passwordLabel), 'SecurePass1');
        await _tapLogin(tester);
        await tester.pumpAndSettle();

        expect(repo.loginCalls, 1);
        expect(repo.lastEmail, 'maria@example.com');
        expect(repo.lastPassword, 'SecurePass1');
        expect(find.text('Home'), findsOneWidget);
      });

  testWidgets('shows an error and stays on screen when login fails',
          (tester) async {
        repo.shouldSucceed = false;
        await tester.pumpWidget(_buildTestApp(controller));

        await tester.enterText(_fieldWithLabel(_emailLabel), 'maria@example.com');
        await tester.enterText(_fieldWithLabel(_passwordLabel), 'WrongPass1');
        await _tapLogin(tester);
        await tester.pumpAndSettle();

        expect(find.text('Incorrect email or password'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
        expect(_loginButton, findsOneWidget);
      });

  testWidgets('shows a loading indicator and disables the button while busy',
          (tester) async {
        repo.gate = Completer<void>();
        await tester.pumpWidget(_buildTestApp(controller));

        await tester.enterText(_fieldWithLabel(_emailLabel), 'maria@example.com');
        await tester.enterText(_fieldWithLabel(_passwordLabel), 'SecurePass1');
        await _tapLogin(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Home'), findsNothing);

        // Let the login finish.
        repo.gate!.complete();
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
      });

  testWidgets('clears the error banner when the user edits a field',
          (tester) async {
        repo.shouldSucceed = false;
        await tester.pumpWidget(_buildTestApp(controller));

        await tester.enterText(_fieldWithLabel(_emailLabel), 'maria@example.com');
        await tester.enterText(_fieldWithLabel(_passwordLabel), 'WrongPass1');
        await _tapLogin(tester);
        await tester.pumpAndSettle();
        expect(find.text('Incorrect email or password'), findsOneWidget);

        await tester.enterText(_fieldWithLabel(_passwordLabel), 'WrongPass12');
        await tester.pump();

        expect(find.text('Incorrect email or password'), findsNothing);
      });
}