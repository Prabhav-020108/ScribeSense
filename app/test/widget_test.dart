import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scribesense_app/main.dart';

void main() {
  testWidgets('RootNav renders navigation destinations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RootNav(),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('AI Coach'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
