import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';

void main() {
  group('AuthTemplate Widget Tests', () {
    testWidgets('should display title and subtitle correctly', (WidgetTester tester) async {
      const testTitle = 'Test Title';
      const testSubtitle = 'Test Subtitle';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTemplate(
              title: testTitle,
              subtitle: testSubtitle,
              child: Container(),
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('should display child widget', (WidgetTester tester) async {
      const testKey = Key('test_child');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTemplate(
              title: 'Title',
              subtitle: 'Subtitle',
              child: Container(key: testKey),
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTemplate(
              title: 'Title',
              subtitle: 'Subtitle',
              child: Container(height: 2000), // Very tall child
            ),
          ),
        ),
      );

      // Should not overflow
      expect(tester.takeException(), isNull);
      
      // Should be able to scroll
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();
      
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle empty title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTemplate(
              title: '',
              subtitle: '',
              child: Container(),
            ),
          ),
        ),
      );

      expect(find.text(''), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTemplate(
              title: 'Title',
              subtitle: 'Subtitle',
              child: Container(),
            ),
          ),
        ),
      );

      // Should contain a SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Should contain a Column or similar layout widget
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}