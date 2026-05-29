import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safehome_front/upload_evidence.dart';

void main() {
  testWidgets('Upload evidence screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UploadEvidenceScreen()));
    expect(find.text('Wizard de subida de evidencia'), findsOneWidget);
  });
}
