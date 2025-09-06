import 'package:flutter/material.dart';

import 'lib/food/components/texts.dart';
import 'lib/food/core/theme/colors.dart';

/// Test file to verify FText refactoring works correctly
/// This demonstrates both old and new usage patterns
class FTextMigrationTest extends StatelessWidget {
  const FTextMigrationTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FText Migration Test')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test backward compatibility - old usage
            Text(
              '=== BACKWARD COMPATIBLE USAGE ===',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            FText(
              text: "Old style usage",
              fontSize: 18,
              color: kBlackColor,
              fontWeight: FontWeight.bold,
            ),

            FText.legacy(
              text: "Explicit legacy constructor",
              fontSize: 16,
              color: kPrimaryColor,
            ),

            SizedBox(height: 24),
            Text(
              '=== NEW MATERIAL DESIGN VARIANTS ===',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Test new factory constructors
            FText.displayLarge("Display Large Text"),
            FText.headlineLarge("Headline Large", color: kPrimaryColor),
            FText.titleLarge("Title Large"),
            FText.titleMedium("Title Medium"),
            FText.bodyLarge("Body Large Text"),
            FText.bodyMedium("Body Medium Text"),
            FText.bodySmall("Body Small Text"),
            FText.labelLarge("Label Large"),
            FText.labelMedium("Label Medium"),
            FText.labelSmall("Label Small"),

            SizedBox(height: 24),
            Text(
              '=== ENHANCED FEATURES ===',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Test enhanced features
            FText.centered(
              "Centered Text with padding",
              padding: EdgeInsets.all(8),
              color: Colors.blue,
            ),

            Container(
              color: Colors.grey[200],
              child: FText.titleMedium(
                "Text with margin",
                margin: EdgeInsets.all(16),
                color: Colors.green,
              ),
            ),

            FText.bodyMedium(
              "Clickable text with underline",
              color: kPrimaryColor,
              onTap: () => print("Text tapped!"),
            ),

            FText.bodyLarge(
              "Limited width text that will wrap",
              width: 200,
              maxLines: 2,
              wrap: TextWrap.ellipsis,
            ),

            SizedBox(height: 24),
            Text(
              '=== TEXT ARRANGEMENTS ===',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  FText(arrangement: TextArrangement.left, text: ''),
                  FText(arrangement: TextArrangement.center, text: ''),
                  FText(arrangement: TextArrangement.right, text: ''),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text(
              '=== SELECTABLE TEXT ===',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            FText.bodyMedium(
              "This text is selectable - try to select it!",
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
