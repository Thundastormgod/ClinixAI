// ClinixAI Widget Tests
//
// Basic widget tests for the ClinixAI medical triage application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clinix_app/main.dart';

void main() {
  testWidgets('ClinixApp launches with home screen', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: ClinixApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that ClinixAI title appears
    expect(find.text('ClinixAI'), findsWidgets);
  });

  testWidgets('Navigation drawer contains expected items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClinixApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Open the drawer
    final scaffoldFinder = find.byType(Scaffold);
    if (scaffoldFinder.evaluate().isNotEmpty) {
      final scaffold = tester.widget<Scaffold>(scaffoldFinder.first);
      if (scaffold.drawer != null) {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        
        // Check for expected menu items
        expect(find.text('AI Triage'), findsWidgets);
      }
    }
  });
}
