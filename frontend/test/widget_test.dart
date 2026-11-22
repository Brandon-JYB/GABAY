import 'package:flutter_test/flutter_test.dart';

// Use the name: from frontend/pubspec.yaml (default for a folder called frontend).
import 'package:frontend/main.dart';

void main() {
  testWidgets('app starts on the login screen', (tester) async {
    await tester.pumpWidget(const GabayApp());

    expect(find.text('Welcome to GABAY'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}