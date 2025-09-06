# Flutter Widget Style Guide

## Structure Rules
- Use 2 spaces for indentation (never tabs)
- Place each widget property on its own line for readability
- Nest child widgets with proper indentation
- Use trailing commas for multi-line widget trees
- Keep widget trees shallow by extracting sub-widgets

## Widget & Property Formatting
- Use lowerCamelCase for property names
- Use UpperCamelCase for widget and class names
- Prefer const constructors where possible
- Use single quotes for strings unless interpolation is needed
- Group related properties together (e.g., all padding/margin, then style, then children)

## Example Flutter Widget Structure

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices
- Extract reusable UI into separate widgets in the `components/` or `widgets/` folder
- Favor StatelessWidget unless state is required
- Use descriptive names for widgets and properties
- Avoid business logic in UI code; use providers, blocs, or controllers
- Add documentation comments (`///`) for public widgets
- Use Theme and MediaQuery for responsive and consistent design
- Run `flutter analyze` after changes to ensure code quality
