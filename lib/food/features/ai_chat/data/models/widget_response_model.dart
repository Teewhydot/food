import '../../domain/entities/widget_response.dart';

/// Model implementation of ChatWidgetResponse for data layer
class ChatWidgetResponseModel extends ChatWidgetResponse {
  const ChatWidgetResponseModel({
    required super.widgetType,
    required super.data,
    super.actions = const [],
    super.fallbackText,
  });

  factory ChatWidgetResponseModel.fromJson(Map<String, dynamic> json) {
    final widgetType = ChatWidgetType.fromString(json['widget_type'] ?? 'text');
    final data = ChatWidgetDataModel.fromJson(widgetType, json['data'] ?? {});
    final actions = (json['actions'] as List<dynamic>?)
        ?.map((action) => ChatWidgetActionModel.fromJson(action))
        .toList() ?? [];

    return ChatWidgetResponseModel(
      widgetType: widgetType,
      data: data,
      actions: actions,
      fallbackText: json['fallback_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'widget_type': widgetType.value,
      'data': (data as ChatWidgetDataModel).toJson(),
      'actions': actions.map((action) => (action as ChatWidgetActionModel).toJson()).toList(),
      'fallback_text': fallbackText,
    };
  }

  factory ChatWidgetResponseModel.fromEntity(ChatWidgetResponse entity) {
    return ChatWidgetResponseModel(
      widgetType: entity.widgetType,
      data: entity.data,
      actions: entity.actions,
      fallbackText: entity.fallbackText,
    );
  }

  /// Creates a text-only response for fallback
  factory ChatWidgetResponseModel.textOnly(String text) {
    return ChatWidgetResponseModel(
      widgetType: ChatWidgetType.text,
      data: TextWidgetDataModel(text: text),
      fallbackText: text,
    );
  }
}

/// Model implementation of ChatWidgetAction
class ChatWidgetActionModel extends ChatWidgetAction {
  const ChatWidgetActionModel({
    required super.id,
    required super.label,
    required super.action,
    super.parameters = const {},
    super.icon,
    super.isPrimary = false,
  });

  factory ChatWidgetActionModel.fromJson(Map<String, dynamic> json) {
    return ChatWidgetActionModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      action: json['action'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      icon: json['icon'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'action': action,
      'parameters': parameters,
      'icon': icon,
      'is_primary': isPrimary,
    };
  }
}

/// Base class for widget data models
abstract class ChatWidgetDataModel extends ChatWidgetData {
  const ChatWidgetDataModel();
  
  factory ChatWidgetDataModel.fromJson(ChatWidgetType type, Map<String, dynamic> json) {
    switch (type) {
      case ChatWidgetType.roomList:
        return RoomListWidgetDataModel.fromJson(json);
      case ChatWidgetType.bookingConfirmation:
        return BookingConfirmationWidgetDataModel.fromJson(json);
      case ChatWidgetType.serviceRequest:
        return ServiceRequestWidgetDataModel.fromJson(json);
      case ChatWidgetType.quickActions:
        return QuickActionsWidgetDataModel.fromJson(json);
      case ChatWidgetType.infoCard:
        return InfoCardWidgetDataModel.fromJson(json);
      case ChatWidgetType.calendar:
        return CalendarWidgetDataModel.fromJson(json);
      case ChatWidgetType.datePicker:
        return CalendarWidgetDataModel.fromJson(json); // Same data structure
      case ChatWidgetType.guestSelector:
        return GuestSelectorWidgetDataModel.fromJson(json);
      case ChatWidgetType.choiceSelector:
        return ChoiceSelectorWidgetDataModel.fromJson(json);
      case ChatWidgetType.multiChoiceSelector:
        return MultiChoiceSelectorWidgetDataModel.fromJson(json);
      case ChatWidgetType.flexibleInputCollector:
        return FlexibleInputCollectorWidgetDataModel.fromJson(json);
      case ChatWidgetType.roomResults:
        return RoomResultsWidgetDataModel.fromJson(json);
      case ChatWidgetType.bookingResult:
        return BookingResultWidgetDataModel.fromJson(json);
      case ChatWidgetType.serviceResult:
        return ServiceResultWidgetDataModel.fromJson(json);
      case ChatWidgetType.paymentResult:
        return PaymentResultWidgetDataModel.fromJson(json);
      case ChatWidgetType.text:
        return TextWidgetDataModel.fromJson(json);
    }
  }
}

/// Text widget data model
class TextWidgetDataModel extends ChatWidgetDataModel implements TextWidgetData {
  @override
  final String text;

  const TextWidgetDataModel({required this.text});

  factory TextWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return TextWidgetDataModel(text: json['text'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'text': text};
  }

  @override
  List<Object?> get props => [text];
}

/// Room list widget data model
class RoomListWidgetDataModel extends ChatWidgetDataModel implements RoomListWidgetData {
  @override
  final List<RoomWidgetData> rooms;
  @override
  final String checkIn;
  @override
  final String checkOut;
  @override
  final int guests;
  @override
  final String? title;
  @override
  final int roomsRequested;

  const RoomListWidgetDataModel({
    required this.rooms,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.title,
    this.roomsRequested = 1,
  });

  factory RoomListWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return RoomListWidgetDataModel(
      rooms: (json['rooms'] as List<dynamic>?)
          ?.map((room) => RoomWidgetDataModel.fromJson(room))
          .toList() ?? [],
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      guests: json['guests'] ?? 2,
      title: json['title'],
      roomsRequested: json['rooms_requested'] ?? json['rooms_needed'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'rooms': rooms.map((room) => (room as RoomWidgetDataModel).toJson()).toList(),
      'check_in': checkIn,
      'check_out': checkOut,
      'guests': guests,
      'title': title,
      'rooms_requested': roomsRequested,
    };
  }

  @override
  List<Object?> get props => [rooms, checkIn, checkOut, guests, title, roomsRequested];
}

/// Individual room data model for room list widget
class RoomWidgetDataModel extends RoomWidgetData {
  const RoomWidgetDataModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.maxGuests,
    required super.rating,
    required super.amenities,
    required super.description,
    super.imageUrl,
  });

  factory RoomWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return RoomWidgetDataModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      maxGuests: json['max_guests'] ?? json['capacity'] ?? 2,
      rating: (json['rating'] ?? 0.0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'max_guests': maxGuests,
      'rating': rating,
      'amenities': amenities,
      'description': description,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, category, price, maxGuests, rating, amenities, description, imageUrl];
}

// Add placeholder implementations for other widget data models
class BookingConfirmationWidgetDataModel extends ChatWidgetDataModel implements BookingConfirmationWidgetData {
  @override
  final String bookingId;
  @override
  final String roomName;
  @override
  final String roomNumber;
  @override
  final String checkIn;
  @override
  final String checkOut;
  @override
  final int guests;
  @override
  final double totalPrice;
  @override
  final String guestName;
  @override
  final String? guestEmail;
  @override
  final BookingStatus status;
  @override
  final List<BookingRoomData>? selectedRooms;
  @override
  final int roomsCount;

  const BookingConfirmationWidgetDataModel({
    required this.bookingId,
    required this.roomName,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.guestName,
    this.guestEmail,
    this.status = BookingStatus.pending,
    this.selectedRooms,
    this.roomsCount = 1,
  });

  factory BookingConfirmationWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return BookingConfirmationWidgetDataModel(
      bookingId: json['booking_id'] ?? '',
      roomName: json['room_name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      guests: json['guests'] ?? 2,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'],
      status: BookingStatus.fromString(json['status'] ?? 'pending'),
      roomsCount: json['rooms_count'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'room_name': roomName,
      'room_number': roomNumber,
      'check_in': checkIn,
      'check_out': checkOut,
      'guests': guests,
      'total_price': totalPrice,
      'guest_name': guestName,
      'guest_email': guestEmail,
      'status': status.value,
      'rooms_count': roomsCount,
    };
  }

  @override
  List<Object?> get props => [bookingId, roomName, roomNumber, checkIn, checkOut, guests, totalPrice, guestName, guestEmail, status, selectedRooms, roomsCount];
}

// Placeholder implementations for other widget data models
class ServiceRequestWidgetDataModel extends ChatWidgetDataModel implements ServiceRequestWidgetData {
  @override
  final List<ServiceOption> services;
  @override
  final String? title;
  @override
  final String? description;

  const ServiceRequestWidgetDataModel({
    required this.services,
    this.title,
    this.description,
  });

  factory ServiceRequestWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestWidgetDataModel(
      services: [],
      title: json['title'],
      description: json['description'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {'services': [], 'title': title, 'description': description};

  @override
  List<Object?> get props => [services, title, description];
}

class QuickActionsWidgetDataModel extends ChatWidgetDataModel implements QuickActionsWidgetData {
  @override
  final String title;
  @override
  final List<QuickAction> actions;

  const QuickActionsWidgetDataModel({required this.title, required this.actions});

  factory QuickActionsWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return QuickActionsWidgetDataModel(title: json['title'] ?? '', actions: []);
  }

  @override
  Map<String, dynamic> toJson() => {'title': title, 'actions': []};

  @override
  List<Object?> get props => [title, actions];
}

class InfoCardWidgetDataModel extends ChatWidgetDataModel implements InfoCardWidgetData {
  @override
  final String title;
  @override
  final String content;
  @override
  final String? imageUrl;
  @override
  final List<String> features;

  const InfoCardWidgetDataModel({
    required this.title,
    required this.content,
    this.imageUrl,
    this.features = const [],
  });

  factory InfoCardWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return InfoCardWidgetDataModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      features: List<String>.from(json['features'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'features': features,
  };

  @override
  List<Object?> get props => [title, content, imageUrl, features];
}

class CalendarWidgetDataModel extends ChatWidgetDataModel implements CalendarWidgetData {
  @override
  final DateTime? selectedDate;
  @override
  final DateTime? minDate;
  @override
  final DateTime? maxDate;
  @override
  final String purpose;

  const CalendarWidgetDataModel({
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.purpose = 'check_in',
  });

  factory CalendarWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return CalendarWidgetDataModel(
      selectedDate: json['selected_date'] != null 
          ? DateTime.tryParse(json['selected_date'])
          : null,
      minDate: json['min_date'] != null 
          ? DateTime.tryParse(json['min_date'])
          : null,
      maxDate: json['max_date'] != null 
          ? DateTime.tryParse(json['max_date'])
          : null,
      purpose: json['purpose'] ?? 'check_in',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'selected_date': selectedDate?.toIso8601String(),
    'min_date': minDate?.toIso8601String(),
    'max_date': maxDate?.toIso8601String(),
    'purpose': purpose,
  };

  @override
  List<Object?> get props => [selectedDate, minDate, maxDate, purpose];
}

class GuestSelectorWidgetDataModel extends ChatWidgetDataModel implements GuestSelectorWidgetData {
  @override
  final int currentGuests;
  @override
  final int maxGuests;
  @override
  final int minGuests;
  @override
  final String title;
  @override
  final String? subtitle;

  const GuestSelectorWidgetDataModel({
    required this.currentGuests,
    this.maxGuests = 10,
    this.minGuests = 1,
    this.title = 'How many guests?',
    this.subtitle,
  });

  factory GuestSelectorWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return GuestSelectorWidgetDataModel(
      currentGuests: json['current_guests'] ?? 2,
      maxGuests: json['max_guests'] ?? 10,
      minGuests: json['min_guests'] ?? 1,
      title: json['title'] ?? 'How many guests?',
      subtitle: json['subtitle'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'current_guests': currentGuests,
    'max_guests': maxGuests,
    'min_guests': minGuests,
    'title': title,
    'subtitle': subtitle,
  };

  @override
  List<Object?> get props => [currentGuests, maxGuests, minGuests, title, subtitle];
}

class ChoiceSelectorWidgetDataModel extends ChatWidgetDataModel implements ChoiceSelectorWidgetData {
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final List<ChoiceOption> choices;
  @override
  final String choiceType;
  @override
  final bool allowMultiple;

  const ChoiceSelectorWidgetDataModel({
    required this.title,
    this.subtitle,
    required this.choices,
    required this.choiceType,
    this.allowMultiple = false,
  });

  factory ChoiceSelectorWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return ChoiceSelectorWidgetDataModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      choices: [],
      choiceType: json['choice_type'] ?? 'generic',
      allowMultiple: json['allow_multiple'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'choices': [],
    'choice_type': choiceType,
    'allow_multiple': allowMultiple,
  };

  @override
  List<Object?> get props => [title, subtitle, choices, choiceType, allowMultiple];
}

class MultiChoiceSelectorWidgetDataModel extends ChatWidgetDataModel implements MultiChoiceSelectorWidgetData {
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final List<SelectorSection> selectors;

  const MultiChoiceSelectorWidgetDataModel({
    required this.title,
    this.subtitle,
    required this.selectors,
  });

  factory MultiChoiceSelectorWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return MultiChoiceSelectorWidgetDataModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      selectors: [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'selectors': [],
  };

  @override
  List<Object?> get props => [title, subtitle, selectors];
}

class FlexibleInputCollectorWidgetDataModel extends ChatWidgetDataModel implements FlexibleInputCollectorWidgetData {
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String context;
  @override
  final List<InputField> requiredFields;
  @override
  final List<InputField> optionalFields;
  @override
  final String inputPlaceholder;

  const FlexibleInputCollectorWidgetDataModel({
    required this.title,
    this.subtitle,
    required this.context,
    required this.requiredFields,
    this.optionalFields = const [],
    required this.inputPlaceholder,
  });

  factory FlexibleInputCollectorWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return FlexibleInputCollectorWidgetDataModel(
      title: json['title'] ?? 'Please provide information',
      subtitle: json['subtitle'],
      context: json['context'] ?? 'generic',
      requiredFields: [],
      optionalFields: [],
      inputPlaceholder: json['input_placeholder'] ?? 'Please provide the requested information',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'context': context,
    'required_fields': [],
    'optional_fields': [],
    'input_placeholder': inputPlaceholder,
  };

  @override
  List<Object?> get props => [title, subtitle, context, requiredFields, optionalFields, inputPlaceholder];
}

class RoomResultsWidgetDataModel extends ChatWidgetDataModel implements RoomResultsWidgetData {
  @override
  final String title;
  @override
  final List<RoomWidgetData> rooms;
  @override
  final Map<String, dynamic> searchParams;
  @override
  final String? message;

  const RoomResultsWidgetDataModel({
    required this.title,
    required this.rooms,
    required this.searchParams,
    this.message,
  });

  factory RoomResultsWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return RoomResultsWidgetDataModel(
      title: json['title'] ?? 'Available Rooms',
      rooms: [],
      searchParams: Map<String, dynamic>.from(json['search_params'] ?? {}),
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'rooms': [],
    'search_params': searchParams,
    'message': message,
  };

  @override
  List<Object?> get props => [title, rooms, searchParams, message];
}

class BookingResultWidgetDataModel extends ChatWidgetDataModel implements BookingResultWidgetData {
  @override
  final String title;
  @override
  final String bookingId;
  @override
  final String roomName;
  @override
  final String roomNumber;
  @override
  final String checkIn;
  @override
  final String checkOut;
  @override
  final int guests;
  @override
  final double totalPrice;
  @override
  final String status;
  @override
  final String? message;
  @override
  final String? paymentUrl;

  const BookingResultWidgetDataModel({
    required this.title,
    required this.bookingId,
    required this.roomName,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    this.message,
    this.paymentUrl,
  });

  factory BookingResultWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return BookingResultWidgetDataModel(
      title: json['title'] ?? 'Booking Details',
      bookingId: json['booking_id'] ?? '',
      roomName: json['room_name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      guests: json['guests'] ?? 2,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      message: json['message'],
      paymentUrl: json['payment_url'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'booking_id': bookingId,
    'room_name': roomName,
    'room_number': roomNumber,
    'check_in': checkIn,
    'check_out': checkOut,
    'guests': guests,
    'total_price': totalPrice,
    'status': status,
    'message': message,
    'payment_url': paymentUrl,
  };

  @override
  List<Object?> get props => [title, bookingId, roomName, roomNumber, checkIn, checkOut, guests, totalPrice, status, message, paymentUrl];
}

class ServiceResultWidgetDataModel extends ChatWidgetDataModel implements ServiceResultWidgetData {
  @override
  final String title;
  @override
  final String serviceType;
  @override
  final String status;
  @override
  final String? requestId;
  @override
  final String? message;
  @override
  final String? estimatedTime;

  const ServiceResultWidgetDataModel({
    required this.title,
    required this.serviceType,
    required this.status,
    this.requestId,
    this.message,
    this.estimatedTime,
  });

  factory ServiceResultWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return ServiceResultWidgetDataModel(
      title: json['title'] ?? 'Service Request',
      serviceType: json['service_type'] ?? '',
      status: json['status'] ?? 'requested',
      requestId: json['request_id'],
      message: json['message'],
      estimatedTime: json['estimated_time'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'service_type': serviceType,
    'status': status,
    'request_id': requestId,
    'message': message,
    'estimated_time': estimatedTime,
  };

  @override
  List<Object?> get props => [title, serviceType, status, requestId, message, estimatedTime];
}

class PaymentResultWidgetDataModel extends ChatWidgetDataModel implements PaymentResultWidgetData {
  @override
  final String title;
  @override
  final String bookingId;
  @override
  final String status;
  @override
  final double amount;
  @override
  final String? transactionId;
  @override
  final String? message;
  @override
  final String? receiptUrl;

  const PaymentResultWidgetDataModel({
    required this.title,
    required this.bookingId,
    required this.status,
    required this.amount,
    this.transactionId,
    this.message,
    this.receiptUrl,
  });

  factory PaymentResultWidgetDataModel.fromJson(Map<String, dynamic> json) {
    return PaymentResultWidgetDataModel(
      title: json['title'] ?? 'Payment Status',
      bookingId: json['booking_id'] ?? '',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionId: json['transaction_id'],
      message: json['message'],
      receiptUrl: json['receipt_url'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'booking_id': bookingId,
    'status': status,
    'amount': amount,
    'transaction_id': transactionId,
    'message': message,
    'receipt_url': receiptUrl,
  };

  @override
  List<Object?> get props => [title, bookingId, status, amount, transactionId, message, receiptUrl];
}