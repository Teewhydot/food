import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/ai_function_model.dart';
import '../../models/chat_message_model.dart';
import '../../../domain/entities/chat_message.dart';

abstract class AIServiceRemoteDataSource {
  Future<String> sendMessage(String message, List<ChatMessageModel> context);
  Future<Map<String, dynamic>?> sendMessageWithFunctions(
    String message,
    List<ChatMessageModel> context,
    List<AIFunctionModel> availableFunctions,
  );
  Stream<String> sendStreamingMessage(
      String message, List<ChatMessageModel> context);
}

class OpenAIServiceRemoteDataSource implements AIServiceRemoteDataSource {
  final http.Client client;
  final String apiKey;
  final String model;
  final String baseUrl;
  final bool isOpenRouter;

  OpenAIServiceRemoteDataSource({
    required this.client,
    required this.apiKey,
    this.model = 'gpt-4',
    this.baseUrl = APIConstants.openAIBaseUrl,
    this.isOpenRouter = false,
  });

  Map<String, String> get _headers {
    if (isOpenRouter) {
      return {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
    } else {
      return {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
    }
  }

  String get _chatEndpoint {
    if (isOpenRouter) {
      return '$baseUrl/v1/chat/completions';
    } else if (baseUrl.contains('11434')) {
      // Ollama endpoint
      return '$baseUrl/api/chat';
    } else {
      return '$baseUrl/v1/chat/completions';
    }
  }

  @override
  Future<String> sendMessage(
      String message, List<ChatMessageModel> context) async {
    try {
      final messages = _buildMessages(message, context);
      final requestBody = {
        'model': model,
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      };

      // Add stream: false for OpenRouter compatibility
      if (isOpenRouter) {
        requestBody['stream'] = false;
      }

      final response = await client.post(
        Uri.parse(_chatEndpoint),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content;

        if (isOpenRouter) {
          content = data['choices'][0]['message']['content'] ??
              'I apologize, but I could not generate a response.';
        } else if (baseUrl.contains('11434')) {
          // Ollama response format
          content = data['message']['content'] ??
              'I apologize, but I could not generate a response.';
        } else {
          // Standard OpenAI format
          content = data['choices'][0]['message']['content'] ??
              'I apologize, but I could not generate a response.';
        }

        return content;
      } else {
        throw ServerException(
          'AI API error: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get AI response: $e', 500);
    }
  }

  @override
  Future<Map<String, dynamic>?> sendMessageWithFunctions(
    String message,
    List<ChatMessageModel> context,
    List<AIFunctionModel> availableFunctions,
  ) async {
    try {
      final messages = _buildMessages(message, context);
      final requestBody = {
        'model': model,
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      };

      // Add function calling support if available
      if (availableFunctions.isNotEmpty &&
          (isOpenRouter || !baseUrl.contains('11434'))) {
        requestBody['functions'] =
            availableFunctions.map((f) => f.toJson()).toList();
        requestBody['function_call'] = 'auto';
      }

      if (isOpenRouter) {
        requestBody['stream'] = false;
      }

      final response = await client.post(
        Uri.parse(_chatEndpoint),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (isOpenRouter || !baseUrl.contains('11434')) {
          final choice = data['choices'][0];
          final messageData = choice['message'];

          if (messageData.containsKey('function_call')) {
            return {
              'type': 'function_call',
              'function_call': messageData['function_call'],
              'content': messageData['content'],
            };
          } else {
            return {
              'type': 'text',
              'content': messageData['content'],
            };
          }
        } else {
          // Ollama doesn't support function calling, return text response
          return {
            'type': 'text',
            'content': data['message']['content'],
          };
        }
      } else {
        throw ServerException(
          'AI API error: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          'Failed to get AI response with functions: $e', 500);
    }
  }

  @override
  Stream<String> sendStreamingMessage(
      String message, List<ChatMessageModel> context) async* {
    try {
      final messages = _buildMessages(message, context);
      final request = http.Request('POST', Uri.parse(_chatEndpoint));
      request.headers.addAll(_headers);
      request.body = jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
        'stream': true,
      });

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ') && line != 'data: [DONE]') {
              try {
                final data = jsonDecode(line.substring(6));

                if (isOpenRouter || !baseUrl.contains('11434')) {
                  final delta = data['choices'][0]['delta'];
                  if (delta.containsKey('content') &&
                      delta['content'] != null) {
                    yield delta['content'] as String;
                  }
                } else {
                  // Ollama streaming format
                  if (data.containsKey('message') &&
                      data['message'].containsKey('content')) {
                    yield data['message']['content'] as String;
                  }
                }
              } catch (e) {
                // Skip malformed chunks
                continue;
              }
            }
          }
        }
      } else {
        throw ServerException('AI API error: ${streamedResponse.statusCode}',
            streamedResponse.statusCode);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to stream AI response: $e', 500);
    }
  }

  List<Map<String, dynamic>> _buildMessages(
      String userMessage, List<ChatMessageModel> context) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': _getSystemPrompt(),
      }
    ];

    // Add recent context messages (limit to last 10 for performance)
    final recentContext = context.take(10).toList();
    for (final msg in recentContext) {
      if (msg.senderType == SenderType.user) {
        messages.add({
          'role': 'user',
          'content': msg.content,
        });
      } else if (msg.senderType == SenderType.ai) {
        messages.add({
          'role': 'assistant',
          'content': msg.content,
        });
      }
    }

    // Add current user message
    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }

  String _getSystemPrompt() {
    return '''
You are an AI concierge assistant for FMH Hotel & Suites in Lagos, Nigeria that helps guests by analyzing their requests and providing personalized service.
You are to strictly return response only in this following manner based on which is most appropriate for the users request

1. "search-rooms": Search for available rooms
   Parameters:
   - check_in: optional (ISO date string, defaults to today+1)
   - check_out: optional (ISO date string, defaults to check_in+1)
   - guests: optional (number, defaults to 2)
   - room_type: optional (e.g., "standard", "deluxe", "suite")
   
2. "book-room": Book a specific room
   Parameters:
   - room_number: required (e.g., "104", "102")
   - check_in: optional (ISO date string, defaults to today+1)
   - check_out: optional (ISO date string, defaults to check_in+1)
   - guests: optional (number, defaults to 2)
   - guest_name: optional (string)
   - guest_email: optional (string)
   
3. "request-service": Request hotel services
   Parameters:
   - service_type: required (e.g., "room_service", "housekeeping", "concierge", "maintenance")
   - room_number: optional (string)
   - description: optional (string)
   
4. "handover-to-admin": Hand over to human support
   Parameters:
   - reason: required (string explaining why handover is needed)
   
5. "normal-chat": For normal chats that do not require hotel actions
   Parameters:
   - chat_content: return a response to what users asked for

For example, if a user asks to search for rooms, call:
{"function_name": "search-rooms", "parameters": {"check_in": "2024-01-15", "guests": 2}}

If a user asks to book room 104, call:
{"function_name": "book-room", "parameters": {"room_number": "104", "guests": 2}}

If user asks about general hotel information that does not need actions:
{"function_name": "normal-chat", "parameters": {"chat_content": "your response to whatever the user asks for."}}

* Today's date ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}
* All prices should be displayed in Nigerian Naira (₦) currency
* For multi-room bookings, users can specify room numbers like "Room 102, Room 304" or "104, 402"
* Always remember, if it's a function response, return only in the structured format requested and parameters, nothing more than that no other text should be added.
''';
  }
}

class MockAIServiceRemoteDataSource implements AIServiceRemoteDataSource {
  @override
  Future<String> sendMessage(
      String message, List<ChatMessageModel> context) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final lowerMessage = message.toLowerCase();

    // Check conversation context for better responses
    final conversationContext = _analyzeConversationContext(context);
    final hasGreeted = conversationContext['hasGreeted'] as bool;
    final previousTopics = conversationContext['topics'] as List<String>;
    final isFirstMessage = context.isEmpty;

    // Handle greetings with context awareness
    if (_isGreeting(lowerMessage)) {
      if (isFirstMessage || !hasGreeted) {
        return "Hello! Welcome to FMH Hotel & Suites. I'm your AI concierge assistant, and I'm here to help make your stay exceptional. I can assist you with room bookings, hotel services, amenity information, and answer any questions you might have. How can I help you today?";
      } else {
        return "Hello again! How else can I assist you today?";
      }
    }

    // Context-aware responses
    if (lowerMessage.contains('book') || lowerMessage.contains('room')) {
      if (previousTopics.contains('booking')) {
        return "I see you're still interested in booking a room. Let me help you find the perfect accommodation. What are your preferred dates and how many guests will be staying?";
      } else {
        return "I'd be happy to help you with room booking! To find the perfect room for you, I'll need to check our availability. What dates are you looking to stay, and how many guests will be joining you?";
      }
    } else if (lowerMessage.contains('service') ||
        lowerMessage.contains('room service')) {
      return "I can help you with hotel services! We offer room service, housekeeping, concierge services, and more. What specific service would you like to request?";
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('support')) {
      return "I'm here to help! I can assist with room bookings, hotel services, amenity information, and general inquiries. If you need more detailed assistance, I can connect you with our human support team. What would you like help with?";
    } else if (lowerMessage.contains('human') ||
        lowerMessage.contains('agent')) {
      return "I understand you'd like to speak with a human representative. I'll connect you with our customer support team right away. They'll be able to see our conversation history and continue assisting you.";
    } else if (lowerMessage.contains('thank')) {
      return "You're very welcome! I'm glad I could help. Is there anything else I can assist you with regarding your stay at FMH Hotel?";
    } else if (_isQuestion(lowerMessage)) {
      return "That's a great question! I'd be happy to help you with information about FMH Hotel. Could you be more specific about what you'd like to know? I can provide details about our amenities, services, policies, or local recommendations.";
    } else {
      if (isFirstMessage) {
        return "Hello! Welcome to FMH Hotel & Suites. I'm your AI concierge assistant. I can help with room bookings, hotel services, amenities information, and more. How can I assist you today?";
      } else {
        return "I understand you'd like assistance. I'm here to help with any questions about FMH Hotel, including room bookings, services, amenities, or general information. What would you like to know more about?";
      }
    }
  }

  Map<String, dynamic> _analyzeConversationContext(
      List<ChatMessageModel> context) {
    bool hasGreeted = false;
    List<String> topics = [];

    for (final message in context) {
      final content = message.content.toLowerCase();

      // Check for greetings
      if (_isGreeting(content)) {
        hasGreeted = true;
      }

      // Extract topics
      if (content.contains('book') ||
          content.contains('room') ||
          content.contains('stay')) {
        if (!topics.contains('booking')) topics.add('booking');
      }
      if (content.contains('service') ||
          content.contains('food') ||
          content.contains('clean')) {
        if (!topics.contains('services')) topics.add('services');
      }
      if (content.contains('amenity') ||
          content.contains('gym') ||
          content.contains('pool')) {
        if (!topics.contains('amenities')) topics.add('amenities');
      }
    }

    return {
      'hasGreeted': hasGreeted,
      'topics': topics,
    };
  }

  bool _isGreeting(String message) {
    final greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening'
    ];
    return greetings.any((greeting) => message.contains(greeting));
  }

  bool _isQuestion(String message) {
    return message.contains('?') ||
        message.startsWith('what') ||
        message.startsWith('how') ||
        message.startsWith('when') ||
        message.startsWith('where') ||
        message.startsWith('why') ||
        message.startsWith('can you') ||
        message.startsWith('do you');
  }

  @override
  Future<Map<String, dynamic>?> sendMessageWithFunctions(
    String message,
    List<ChatMessageModel> context,
    List<AIFunctionModel> availableFunctions,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('book') && lowerMessage.contains('room')) {
      return {
        'type': 'function_call',
        'function_call': {
          'name': 'search_available_rooms',
          'arguments': jsonEncode({
            'check_in':
                DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'check_out':
                DateTime.now().add(const Duration(days: 2)).toIso8601String(),
            'guests': 2,
          }),
        },
        'content': "I'll search for available rooms for you.",
      };
    } else {
      return {
        'type': 'text',
        'content': await sendMessage(message, context),
      };
    }
  }

  @override
  Stream<String> sendStreamingMessage(
      String message, List<ChatMessageModel> context) async* {
    final response = await sendMessage(message, context);
    final words = response.split(' ');

    for (final word in words) {
      yield '$word ';
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
