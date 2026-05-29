import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safehome_front/emergency_contacts.dart';

void main() {
  testWidgets('Emergency contacts screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: EmergencyContactsScreen()));
    expect(find.text('Lista de contactos de emergencia'), findsOneWidget);
  });
}
