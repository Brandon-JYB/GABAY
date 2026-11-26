import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gabay/core/app_router.dart';
import 'package:gabay/features/auth/domain/auth_repository.dart';
import 'package:gabay/features/auth/domain/auth_user.dart';
import 'package:gabay/features/auth/presentation/register_screen.dart';
import 'package:gabay/features/auth/state/auth_controller.dart';
import 'package:gabay/features/auth/state/auth_scope.dart';

const _streetLabel = 'Sitio / House no. / Street / Purok (optional)';

class _FakeAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String? lastFullName;
  String? lastAddress;
  String? lastEmail;
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> register({
    required String fullName,
    required DateTime birthDate,
    required String genderStatus,
    required String address,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (!shouldSucceed) {
      throw const AuthException('Email already in use');
    }
    lastFullName = fullName;
    lastAddress = address;
    lastEmail = email;
    final user = AuthUser(
      id: 'user-1',
      fullName: fullName,
      birthDate: birthDate,
      genderStatus: genderStatus,
      address: address,
      email: email,
    );
    _current = user;
    return user;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    throw const AuthException('Not used in register test');
  }

  @override
  Future<void> logout() async {
    _current = null;
  }
}

Finder _textFormFieldWithLabel(String labelText) {
  return find.widgetWithText(TextFormField, labelText);
}

Finder _genderDropdownWithLabel(String labelText) {
  return find.widgetWithText(DropdownButtonFormField<String>, labelText);
}

Future<void> _dismissAutocompleteOverlay(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

Widget _buildTestApp(AuthController controller) {
  return MaterialApp(
    routes: {
      AppRoutes.home: (_) => const Scaffold(body: Center(child: Text('Home'))),
    },
    home: AuthScope(
      controller: controller,
      child: const RegisterScreen(),
    ),
  );
}

/// Fills every field with valid data. Pass [street] to fill the optional
/// street field, or leave it null to skip it.
Future<void> _fillValidForm(WidgetTester tester, {String? street}) async {
  // 1. Full name
  await tester.enterText(
    _textFormFieldWithLabel('Full name'),
    '  Maria Clara  ',
  );

  // 2. Birthdate via date picker dialog
  await tester.tap(_textFormFieldWithLabel('Birthdate'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // 3. Gender dropdown
  await tester.tap(_genderDropdownWithLabel('Gender'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Female').last);
  await tester.pumpAndSettle();

  // 4. Street (optional)
  if (street != null) {
    await tester.enterText(_textFormFieldWithLabel(_streetLabel), street);
  }

  // 5. Barangay autocomplete
  await tester.enterText(_textFormFieldWithLabel('Barangay'), 'Alangilan');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Alangilan').last);
  await tester.pumpAndSettle();

  // 6. Email & passwords
  await tester.enterText(
    _textFormFieldWithLabel('Email'),
    '  maria@example.com  ',
  );
  await tester.enterText(
    _textFormFieldWithLabel('Password'),
    'SecurePass1',
  );
  await tester.enterText(
    _textFormFieldWithLabel('Confirm password'),
    'SecurePass1',
  );
}

Future<void> _submit(WidgetTester tester) async {
  final submitBtn = find.widgetWithText(FilledButton, 'Create account');
  await tester.ensureVisible(submitBtn);
  await tester.tap(submitBtn);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows validation errors on empty submission', (tester) async {
    final repo = _FakeAuthRepository();
    final controller = AuthController(repo);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_buildTestApp(controller));

    final submitBtn = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Birthdate is required'), findsOneWidget);
    expect(find.text('Gender status is required'), findsOneWidget);
    expect(find.text('Barangay is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('does not require the street field', (tester) async {
    final repo = _FakeAuthRepository();
    final controller = AuthController(repo);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_buildTestApp(controller));

    final submitBtn = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();

    // Other required fields show errors, but the optional street field must not.
    expect(find.text('Full name is required'), findsOneWidget);

    final streetState = tester.state<FormFieldState<String>>(
      _textFormFieldWithLabel(_streetLabel),
    );
    expect(streetState.hasError, isFalse);
  });

  testWidgets('shows helper text under City/Municipality', (tester) async {
    final repo = _FakeAuthRepository();
    final controller = AuthController(repo);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_buildTestApp(controller));

    expect(find.text('Will be updated in the future'), findsOneWidget);
  });

  testWidgets('strips unrelated characters and rejects invalid barangay',
          (tester) async {
        final repo = _FakeAuthRepository();
        final controller = AuthController(repo);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_buildTestApp(controller));

        // Numbers & symbols in full name are stripped by inputFormatter
        await tester.enterText(
          _textFormFieldWithLabel('Full name'),
          'Alex123@#!',
        );
        expect(find.text('Alex'), findsOneWidget);

        // Unrelated symbols in street detail are stripped
        await tester.enterText(
          _textFormFieldWithLabel(_streetLabel),
          'Purok 1 @\$%',
        );
        expect(find.text('Purok 1 '), findsOneWidget);

        // Unrelated symbols in barangay are stripped, leaving non-existent barangay
        await tester.enterText(
          _textFormFieldWithLabel('Barangay'),
          'NotABarangay@#!',
        );
        expect(find.text('NotABarangay'), findsOneWidget);
        await _dismissAutocompleteOverlay(tester);

        final submitBtn = find.widgetWithText(FilledButton, 'Create account');
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pump();

        expect(
          find.text('Select or enter a valid barangay within Batangas City'),
          findsOneWidget,
        );
      });

  testWidgets('submits valid inputs and navigates to home route',
          (tester) async {
        final repo = _FakeAuthRepository();
        final controller = AuthController(repo);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_buildTestApp(controller));

        await _fillValidForm(tester, street: 'Purok 1');
        await _submit(tester);

        expect(repo.lastFullName, 'Maria Clara');
        expect(repo.lastEmail, 'maria@example.com');
        expect(
          repo.lastAddress,
          'Purok 1, Brgy. Alangilan, Batangas City',
        );
        expect(find.text('Home'), findsOneWidget);
      });

  testWidgets('submits without street and builds address from barangay only',
          (tester) async {
        final repo = _FakeAuthRepository();
        final controller = AuthController(repo);
        addTearDown(controller.dispose);

        await tester.pumpWidget(_buildTestApp(controller));

        await _fillValidForm(tester); // street left empty
        await _submit(tester);

        expect(repo.lastAddress, 'Brgy. Alangilan, Batangas City');
        expect(find.text('Home'), findsOneWidget);
      });
}