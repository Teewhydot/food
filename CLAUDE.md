# Claude Instructions for Food App

## Project Architecture Guidelines

### Always Follow Existing Structure
Before implementing any new feature:

1. **Analyze existing codebase** - Use search tools to understand current patterns and conventions
2. **Check existing packages** - Review `pubspec.yaml` and existing implementations before adding new dependencies
3. **Use established patterns** - Follow the same architectural patterns, naming conventions, and code organization

### Data Persistence
- **Primary storage**: Floor database (already implemented)
- **Location**: `lib/food/core/services/floor_db_service/`
- **Pattern**: Entity → DAO → DatabaseService
- **Usage**: Always check existing entities/tables before creating new ones
- **DO NOT use**: SharedPreferences, Hive, or other storage solutions unless Floor is insufficient

### State Management
- **Primary**: BLoC pattern with Cubit for simple state, BLoC for complex flows
- **Location**: Feature-specific managers in `lib/food/features/[feature]/manager/` or `presentation/manager/`
- **Pattern**: Follow existing BLoC structure with events, states, and proper naming

### Project Structure
```
lib/food/
├── core/              # Shared utilities, services, constants
├── components/        # Reusable UI components
├── features/         # Feature-based modules
│   └── [feature]/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── dependency_injection/
```

### API Integration
- **Service**: Use existing `api_service` in `core/services/`
- **Pattern**: DataSource → Repository → UseCase → BLoC
- **Error handling**: Use established exception handling patterns

### UI Components
- **Location**: `lib/food/components/`
- **Existing**: buttons, textfields, texts, image, scaffold
- **Pattern**: Extend existing components rather than creating new ones

### Dependencies
- **Check first**: Always review `pubspec.yaml` and existing usage
- **Common packages already included**: 
  - floor (database)
  - bloc/flutter_bloc (state management)
  - get_it (dependency injection)
  - firebase services
  - permission_handler

### Before Adding New Features
1. Search existing implementations with similar functionality
2. Check if required services/utilities already exist
3. Review existing entity models for reusable structures
4. Follow established naming conventions and file organization
5. Use existing theme, colors, and styling patterns

### Code Style
- Follow existing Dart/Flutter conventions in the codebase
- Use established import organization
- Follow existing error handling patterns
- Maintain consistency with existing widget structures