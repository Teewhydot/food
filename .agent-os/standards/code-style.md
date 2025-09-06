# Code Style Guide

## Context

Global code style rules for Agent OS projects using Flutter (Dart), Go (Golang), and Firebase.

## Dart (Flutter) Style

- Use 2 spaces for indentation (never tabs)
- Follow the official Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use lowerCamelCase for variables, methods, and function names
- Use UpperCamelCase for class names and enums
- Use UPPER_SNAKE_CASE for constants
- Prefer `final` and `const` for immutable values
- Use single quotes for strings unless interpolation or escaping is needed
- Add documentation comments (`///`) for public APIs, classes, and methods
- Organize files by feature/module, not by type
- Keep widgets small and focused; use composition
- Use trailing commas for multi-line widget trees
- Avoid logic in UI code; use providers, blocs, or controllers for state management

## Go (Golang) Style

- Use tabs for indentation (default Go style)
- Follow the official Go style guide: https://golang.org/doc/effective_go.html
- Use mixedCaps or CapitalizedNames for variables and functions (no underscores)
- Use ALL_CAPS for constants
- Add comments for all exported (public) functions, types, and packages
- Keep functions short and focused
- Organize code into packages by domain or feature
- Use `gofmt` to format code automatically
- Handle errors explicitly; avoid silent failures
- Use context for request-scoped values and cancellation

## Firebase Usage

- Use Firestore document/collection names in lower_snake_case
- Store user-generated data in subcollections for scalability
- Validate all data before writing to Firestore
- Use Firebase Auth for authentication; never store passwords manually
- Secure data with Firestore Security Rules
- Use environment configs for API keys and secrets; never hardcode
- Keep Firebase Cloud Functions small and single-purpose
- Log errors and important events for monitoring

## General Best Practices

- Write clear, concise comments explaining non-obvious logic
- Keep code DRY (Don't Repeat Yourself)
- Before implementing code for screens using figma mcp, check the components/widgets  folder in project and use those in favour of creating new widgets
- Use meaningful names for variables, functions, and files
- Organize code by feature/module for maintainability
- Write unit and integration tests for critical logic
- Use environment-specific configuration files for secrets and endpoints
- After implementing a feature, run flutter analyze in folders or files that were created or modified related to that feature or bug fix
- Always Favor creating stateless and statefull widgets over private functions that return widgets
