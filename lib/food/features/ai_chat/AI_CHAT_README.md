# AI Chat Feature - Clean Architecture Implementation

This is a complete clean architecture implementation of an AI-powered chat support system using BLoC pattern for state management.

## 📁 Folder Structure

```
lib/features/ai_chat/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   └── usecase/
│       └── usecase.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── chat_local_datasource.dart
│   │   └── remote/
│   │       ├── ai_service_remote_datasource.dart
│   │       └── chat_remote_datasource.dart
│   ├── models/
│   │   ├── ai_function_model.dart
│   │   ├── chat_message_model.dart
│   │   ├── chat_room_model.dart
│   │   └── widget_response_model.dart
│   └── repositories/
│       ├── ai_service_repository_impl.dart
│       └── chat_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── ai_function.dart
│   │   ├── chat_message.dart
│   │   ├── chat_room.dart
│   │   └── widget_response.dart
│   ├── repositories/
│   │   ├── ai_service_repository.dart
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── ai_config_usecases.dart
│       ├── chat_room_usecases.dart
│       ├── get_messages_usecase.dart
│       ├── send_ai_message_usecase.dart
│       └── send_message_usecase.dart
└── presentation/
    ├── manager/
    │   ├── chat_bloc/
    │   │   ├── chat_bloc.dart
    │   │   ├── chat_event.dart
    │   │   └── chat_state.dart
    │   └── chat_room_bloc/
    │       ├── chat_room_bloc.dart
    │       ├── chat_room_event.dart
    │       └── chat_room_state.dart
    ├── services/
    │   └── ai_function_registry.dart
    └── widgets/
        ├── chat_widgets/
        │   ├── base_chat_widget.dart
        │   ├── booking_confirmation_chat_widget.dart
        │   ├── payment_result_chat_widget.dart
        │   ├── quick_actions_chat_widget.dart
        │   ├── room_list_chat_widget.dart
        │   └── text_chat_widget.dart
        └── chat_widget_factory.dart
```

## 🏗 Architecture Overview

### **Data Layer**
- **Models**: Data models that extend domain entities
- **Data Sources**: 
  - Remote: Firebase Firestore, AI APIs (OpenAI, Claude, OpenRouter)
  - Local: SharedPreferences for caching and configuration
- **Repositories**: Implementation of domain repository contracts

### **Domain Layer**
- **Entities**: Business logic entities (ChatMessage, ChatRoom, AIFunction)
- **Repositories**: Abstract repository contracts
- **Use Cases**: Business logic operations

### **Presentation Layer**
- **BLoC**: State management using flutter_bloc
- **Widgets**: UI components with clean separation of concerns
- **Services**: Presentation-specific services like AI function registry

## 🚀 Key Features

### 1. **Multi-AI Provider Support**
- OpenAI GPT models
- Anthropic Claude
- OpenRouter
- Ollama (local)
- MockAI for development

### 2. **Interactive Widget System**
- Room list widgets with booking integration
- Payment result displays
- Booking confirmation widgets
- Quick action buttons
- Extensible widget factory pattern

### 3. **Function Calling**
- AI can execute predefined functions
- Hotel room search
- Booking creation and confirmation
- Information retrieval
- Support escalation

### 4. **Smart Context Management**
- Conversation history tracking
- Context-aware responses
- Multi-turn conversations

### 5. **Real-time AI Communication**
- Direct AI provider communication
- No local caching for real-time responses
- Network status awareness with connection requirements

## 📦 Dependencies Required

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4
  
  # Functional Programming
  dartz: ^0.10.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # HTTP & API
  http: ^1.1.0
  
  # Network
  connectivity_plus: ^5.0.2 # For NetworkInfo implementation

dev_dependencies:
  # Testing
  mockito: ^5.4.2
  flutter_test:
    sdk: flutter
```

## 🛠 Setup Instructions

### 1. **Initialize Dependency Injection**

```dart
// In your main.dart
import 'features/ai_chat/core/di/injection_container.dart' as ai_chat_di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AI Chat dependencies
  await ai_chat_di.AIChatInjectionContainer.init();
  
  runApp(MyApp());
}
```

### 2. **Provide BLoCs to Your Widget Tree**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ai_chat_di.sl<ChatRoomBloc>(),
        ),
        // Add other providers...
      ],
      child: MaterialApp(
        // Your app configuration
      ),
    );
  }
}
```

### 3. **Use in Your Screens**

```dart
class ChatScreen extends StatelessWidget {
  final String roomId;
  
  const ChatScreen({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ai_chat_di.sl<ChatBloc>()
        ..add(LoadMessages(roomId)),
      child: Scaffold(
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded) {
              return ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
```

## 🔧 Configuration

### AI Service Configuration

```dart
// Configure AI service in your app
final config = {
  'enabled': true,
  'provider': 'openai', // or 'claude', 'openrouter', 'ollama'
  'model': 'gpt-4',
  'apiKey': 'your_api_key_here',
  'baseUrl': 'https://api.openai.com/v1',
  'maxContextMessages': 10,
};

// Save configuration
final configUseCase = sl<SaveAIConfigUseCase>();
await configUseCase(SaveAIConfigParams(config: config));
```

### Function Registry Setup

The AI function registry is automatically configured with basic functions:
- `search_available_rooms`
- `get_hotel_info`  
- `request_support`

To add custom functions:

```dart
final registry = sl<AIFunctionRegistry>();
registry.registerFunction('custom_function', CustomFunctionHandler());
```

## 🧪 Testing

The clean architecture makes testing straightforward:

```dart
// Test use cases
void main() {
  group('SendMessageUseCase', () {
    late SendMessageUseCase useCase;
    late MockChatRepository mockRepository;

    setUp(() {
      mockRepository = MockChatRepository();
      useCase = SendMessageUseCase(mockRepository);
    });

    test('should send message successfully', () async {
      // Arrange
      when(mockRepository.sendMessage(any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(SendMessageParams(
        roomId: 'test_room',
        message: testMessage,
      ));

      // Assert
      expect(result, const Right(null));
    });
  });
}
```

## 🎯 Usage Examples

### Basic Chat Implementation

```dart
// Send a user message
context.read<ChatBloc>().add(SendMessage(
  roomId: roomId,
  content: 'Hello, I need help booking a room',
));

// Send AI message with function calling
context.read<ChatBloc>().add(SendAIMessage(
  roomId: roomId,
  content: userMessage,
  context: previousMessages,
  withFunctions: true,
));
```

### Handle Widget Interactions

```dart
// In your widget
ChatWidgetFactory.createWidget(
  widgetResponse: message.widgetData!,
  onInteraction: (action, parameters) {
    switch (action) {
      case 'select_room':
        _handleRoomSelection(parameters);
        break;
      case 'confirm_booking':
        _handleBookingConfirmation(parameters);
        break;
    }
  },
)
```

## 🔄 State Management Flow

1. **UI Event** → `ChatEvent` is dispatched
2. **BLoC** processes event using **Use Cases**
3. **Use Cases** interact with **Repositories**  
4. **Repositories** coordinate between **Remote** and **Local Data Sources**
5. **Data** flows back through the chain
6. **BLoC** emits new **ChatState**
7. **UI** rebuilds based on new state

## 🛡 Error Handling

The architecture includes comprehensive error handling:

- **Domain Layer**: `Failure` classes with specific error types
- **Data Layer**: `Exception` classes that map to failures
- **Presentation Layer**: Error states in BLoC with user-friendly messages

## 🎨 Customization

### Adding New Widget Types

1. Create widget data class in `domain/entities/widget_response.dart`
2. Add model implementation in `data/models/widget_response_model.dart`
3. Create widget component in `presentation/widgets/chat_widgets/`
4. Register in `ChatWidgetFactory`

### Adding New AI Functions

1. Create function handler extending `AIFunctionHandler`
2. Register in `AIFunctionRegistry` during DI setup
3. Handle function results in `ChatBloc`

This architecture provides a solid foundation for building scalable, maintainable AI chat systems with Flutter.