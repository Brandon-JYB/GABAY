import 'package:flutter_test/flutter_test.dart';
import 'package:gabay/main.dart';

void main() {
  testWidgets('app starts on the login screen', (tester) async {
    await tester.pumpWidget(const GabayApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to GABAY'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}