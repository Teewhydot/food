import 'dart:convert';
import '../../domain/entities/ai_function.dart';

class AIFunctionRegistry {
  final Map<String, AIFunctionHandler> _functions = {};
  
  void registerFunction(String name, AIFunctionHandler handler) {
    _functions[name] = handler;
  }
  
  List<AIFunction> getAvailableFunctions() {
    return _functions.entries.map((entry) => 
      AIFunction(
        name: entry.key,
        description: entry.value.description,
        parameters: entry.value.parameters,
        metadata: entry.value.metadata,
      )
    ).toList();
  }
  
  Future<Map<String, dynamic>> executeFunction(
    String name, 
    String argumentsJson,
  ) async {
    final function = _functions[name];
    if (function == null) {
      throw Exception('Function $name not found');
    }
    
    try {
      final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
      return await function.execute(arguments);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  bool hasFunction(String name) => _functions.containsKey(name);
}

abstract class AIFunctionHandler {
  String get description;
  Map<String, dynamic> get parameters;
  Map<String, dynamic> get metadata;
  
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments);
}

// Example function implementations
class SearchRoomsFunctionHandler extends AIFunctionHandler {
  @override
  String get description => 'Search for available rooms based on dates and guest count';
  
  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'check_in': {
        'type': 'string',
        'format': 'date',
        'description': 'Check-in date in YYYY-MM-DD format',
      },
      'check_out': {
        'type': 'string',
        'format': 'date',
        'description': 'Check-out date in YYYY-MM-DD format',
      },
      'guests': {
        'type': 'integer',
        'description': 'Number of guests',
        'minimum': 1,
        'maximum': 10,
      },
    },
    'required': ['check_in', 'check_out', 'guests'],
  };
  
  @override
  Map<String, dynamic> get metadata => {
    'context': 'room_search',
    'user_intent': 'Find and book hotel rooms',
    'common_phrases': [
      'book a room',
      'find rooms',
      'search availability',
      'check rooms',
      'room booking'
    ]
  };
  
  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    // TODO: Implement actual room search logic
    // This would typically call a repository or service
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    return {
      'success': true,
      'widget_type': 'room_list',
      'data': {
        'rooms': [
          {
            'id': '101',
            'name': 'Deluxe Room',
            'category': 'Deluxe',
            'price': 25000.0,
            'max_guests': 2,
            'rating': 4.5,
            'amenities': ['WiFi', 'AC', 'TV'],
            'description': 'A comfortable deluxe room with modern amenities.',
            'image_url': 'https://example.com/room1.jpg',
          },
          {
            'id': '102',
            'name': 'Standard Room',
            'category': 'Standard',
            'price': 15000.0,
            'max_guests': 2,
            'rating': 4.0,
            'amenities': ['WiFi', 'AC'],
            'description': 'A cozy standard room perfect for budget travelers.',
            'image_url': 'https://example.com/room2.jpg',
          },
        ],
        'check_in': arguments['check_in'],
        'check_out': arguments['check_out'],
        'guests': arguments['guests'],
        'rooms_requested': 1,
      },
      'message': 'Found available rooms for your stay.',
      'actions': [
        {
          'id': 'book_room',
          'label': 'Book Room',
          'action': 'book_room',
          'icon': 'hotel',
          'is_primary': true,
        }
      ],
    };
  }
}

class GetHotelInfoFunctionHandler extends AIFunctionHandler {
  @override
  String get description => 'Get information about hotel amenities, services, and policies';
  
  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'info_type': {
        'type': 'string',
        'description': 'Type of information requested',
        'enum': ['amenities', 'services', 'policies', 'location', 'contact'],
      },
    },
    'required': ['info_type'],
  };
  
  @override
  Map<String, dynamic> get metadata => {
    'context': 'hotel_information',
    'user_intent': 'Get hotel details and information',
    'common_phrases': [
      'hotel amenities',
      'what services',
      'hotel policies',
      'where is hotel',
      'contact information'
    ]
  };
  
  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    final infoType = arguments['info_type'] as String;
    
    switch (infoType) {
      case 'amenities':
        return {
          'success': true,
          'data': {
            'amenities': [
              'Swimming Pool with time-slot bookings',
              'Fitness Center with daily/monthly memberships',
              'Room Booking Services',
              'Restaurant with room service',
              'Laundry Services (wash & fold, wash & iron, dry cleaning)',
              'Concierge Services',
              'Free WiFi',
              'Air Conditioning',
              'Cable TV',
              'Refrigerator in rooms',
            ],
          },
          'message': 'Here are our available amenities and facilities',
        };
        
      case 'services':
        return {
          'success': true,
          'data': {
            'services': [
              'Room Service - Full menu available with delivery to your room',
              'Housekeeping - Daily cleaning and maintenance',
              'Concierge - Local recommendations and assistance',
              'Laundry Service - Professional cleaning services',
              'Gym Access - Fitness center with modern equipment',
              'Pool Access - Swimming pool with scheduled sessions',
              'Spa Treatments - Relaxation and wellness services',
            ],
          },
          'message': 'Here are the services we offer to make your stay comfortable',
        };
        
      default:
        return {
          'success': false,
          'error': 'Unknown information type requested',
        };
    }
  }
}

class RequestSupportFunctionHandler extends AIFunctionHandler {
  @override
  String get description => 'Request human support and create a handover to customer service';
  
  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'reason': {
        'type': 'string',
        'description': 'Reason for requesting human support',
        'enum': ['complex_query', 'booking_issue', 'complaint', 'special_request', 'technical_issue', 'other'],
      },
      'priority': {
        'type': 'string',
        'description': 'Priority level of the request',
        'enum': ['low', 'medium', 'high', 'urgent'],
        'default': 'medium',
      },
      'description': {
        'type': 'string',
        'description': 'Additional details about the support request',
      },
    },
    'required': ['reason'],
  };
  
  @override
  Map<String, dynamic> get metadata => {
    'context': 'support_request',
    'user_intent': 'Get human assistance',
    'common_phrases': [
      'need help',
      'speak to human',
      'customer service',
      'have a problem',
      'need assistance'
    ]
  };
  
  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    final reason = arguments['reason'] as String;
    final priority = arguments['priority'] as String? ?? 'medium';
    final description = arguments['description'] as String?;
    
    // TODO: Implement actual handover logic
    
    return {
      'success': true,
      'data': {
        'handover_requested': true,
        'reason': reason,
        'priority': priority,
        'description': description,
        'estimated_wait_time': '5-10 minutes',
      },
      'message': 'I\'ve connected you with our customer support team. A human representative will join the conversation shortly to assist you.',
    };
  }
}