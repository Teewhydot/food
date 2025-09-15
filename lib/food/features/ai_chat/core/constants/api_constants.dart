class APIConstants {
  // AI Service URLs
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  
  // Default models
  static const String defaultOpenAIModel = 'gpt-4';
  static const String defaultClaudeModel = 'claude-3-sonnet-20240229';
  static const String defaultOpenRouterModel = 'openai/gpt-4';
  
  // API timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  
  // Cache keys
  static const String aiConfigCacheKey = 'ai_config';
  static const String chatMessagesCachePrefix = 'chat_messages_';
  static const String chatRoomsCachePrefix = 'chat_rooms_';
  
  // Firebase collections
  static const String chatRoomsCollection = 'chatRooms';
  static const String messagesSubcollection = 'messages';
  static const String usersCollection = 'users';
  
  // Widget types
  static const String roomListWidget = 'room_list';
  static const String bookingConfirmationWidget = 'booking_confirmation';
  static const String paymentResultWidget = 'payment_result';
  static const String quickActionsWidget = 'quick_actions';
  static const String textWidget = 'text';
  
  // Function names
  static const String searchRoomsFunction = 'search_available_rooms';
  static const String createBookingFunction = 'create_booking';
  static const String confirmBookingFunction = 'confirm_booking';
  static const String getHotelInfoFunction = 'get_hotel_info';
  static const String requestSupportFunction = 'request_support';
}

class AIModelConstants {
  // OpenAI Models
  static const List<String> openAIModels = [
    'gpt-4',
    'gpt-4-turbo-preview',
    'gpt-3.5-turbo',
    'gpt-3.5-turbo-16k',
  ];
  
  // Claude Models
  static const List<String> claudeModels = [
    'claude-3-opus-20240229',
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
  ];
  
  // OpenRouter Models
  static const List<String> openRouterModels = [
    'openai/gpt-4',
    'openai/gpt-3.5-turbo',
    'anthropic/claude-3-opus',
    'anthropic/claude-3-sonnet',
    'meta-llama/llama-2-70b-chat',
  ];
}

class ChatConstants {
  // Message types
  static const String textMessageType = 'text';
  static const String imageMessageType = 'image';
  static const String documentMessageType = 'document';
  static const String widgetMessageType = 'widget';
  
  // Sender types
  static const String userSenderType = 'user';
  static const String aiSenderType = 'ai';
  static const String adminSenderType = 'admin';
  
  // Room types
  static const String aiSupportRoomType = 'aiSupport';
  static const String humanSupportRoomType = 'humanSupport';
  static const String groupRoomType = 'group';
  static const String directRoomType = 'direct';
  
  // Default values
  static const int maxContextMessages = 10;
  static const int maxMessageLength = 4000;
  static const int aiResponseTimeout = 30; // seconds
  
  // UI constants
  static const double messageBubbleMaxWidth = 0.8;
  static const double widgetMaxWidth = 0.9;
  static const int animationDurationMs = 300;
}