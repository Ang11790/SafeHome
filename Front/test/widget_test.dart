import 'package:flutter_test/flutter_test.dart';
import 'package:safehome_front/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(SafeHomeApp());
    expect(find.text('SafeHome'), findsOneWidget);
  });
}
