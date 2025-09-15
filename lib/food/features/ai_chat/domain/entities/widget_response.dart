import 'package:equatable/equatable.dart';

/// Enum defining different types of chat widgets
enum ChatWidgetType {
  roomList('room_list'),
  bookingConfirmation('booking_confirmation'),
  serviceRequest('service_request'),
  quickActions('quick_actions'),
  infoCard('info_card'),
  calendar('calendar'),
  datePicker('date_picker'),
  guestSelector('guest_selector'),
  choiceSelector('choice_selector'),
  multiChoiceSelector('multi_choice_selector'),
  flexibleInputCollector('flexible_input_collector'),
  roomResults('room_results'),
  bookingResult('booking_result'),
  serviceResult('service_result'),
  paymentResult('payment_result'),
  text('text'); // Fallback for regular text

  const ChatWidgetType(this.value);
  final String value;

  static ChatWidgetType fromString(String value) {
    return ChatWidgetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChatWidgetType.text,
    );
  }
}

/// Base class for all chat widget data
abstract class ChatWidgetData extends Equatable {
  const ChatWidgetData();
  
  Map<String, dynamic> toJson();
}

/// Model for chat widget responses from AI
class ChatWidgetResponse extends Equatable {
  final ChatWidgetType widgetType;
  final ChatWidgetData data;
  final List<ChatWidgetAction> actions;
  final String? fallbackText;

  const ChatWidgetResponse({
    required this.widgetType,
    required this.data,
    this.actions = const [],
    this.fallbackText,
  });

  /// Creates a text-only response for fallback
  factory ChatWidgetResponse.textOnly(String text) {
    return ChatWidgetResponse(
      widgetType: ChatWidgetType.text,
      data: TextWidgetData(text: text),
      fallbackText: text,
    );
  }

  @override
  List<Object?> get props => [widgetType, data, actions, fallbackText];
}

/// Represents an action that can be performed from a widget
class ChatWidgetAction extends Equatable {
  final String id;
  final String label;
  final String action;
  final Map<String, dynamic> parameters;
  final String? icon;
  final bool isPrimary;

  const ChatWidgetAction({
    required this.id,
    required this.label,
    required this.action,
    this.parameters = const {},
    this.icon,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [id, label, action, parameters, icon, isPrimary];
}

/// Text widget data (fallback)
class TextWidgetData extends ChatWidgetData {
  final String text;

  const TextWidgetData({required this.text});

  @override
  Map<String, dynamic> toJson() {
    return {'text': text};
  }

  @override
  List<Object?> get props => [text];
}

/// Room list widget data
class RoomListWidgetData extends ChatWidgetData {
  final List<RoomWidgetData> rooms;
  final String checkIn;
  final String checkOut;
  final int guests;
  final String? title;
  final int roomsRequested;

  const RoomListWidgetData({
    required this.rooms,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.title,
    this.roomsRequested = 1,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'rooms': rooms.map((room) => room.toJson()).toList(),
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

/// Individual room data for room list widget
class RoomWidgetData extends Equatable {
  final String id;
  final String name;
  final String category;
  final double price;
  final int maxGuests;
  final double rating;
  final List<String> amenities;
  final String description;
  final String? imageUrl;

  const RoomWidgetData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.maxGuests,
    required this.rating,
    required this.amenities,
    required this.description,
    this.imageUrl,
  });

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
  List<Object?> get props => [
    id, name, category, price, maxGuests, rating, amenities, description, imageUrl
  ];
}

/// Individual room data for booking confirmation
class BookingRoomData extends Equatable {
  final String roomId;
  final String roomName;
  final String roomNumber;
  final String category;
  final double pricePerNight;
  final double totalPrice;
  final int maxGuests;

  const BookingRoomData({
    required this.roomId,
    required this.roomName,
    required this.roomNumber,
    required this.category,
    required this.pricePerNight,
    required this.totalPrice,
    required this.maxGuests,
  });

  @override
  List<Object?> get props => [
    roomId, roomName, roomNumber, category, pricePerNight, totalPrice, maxGuests
  ];
}

/// Booking confirmation widget data
class BookingConfirmationWidgetData extends ChatWidgetData {
  final String bookingId;
  final String roomName;
  final String roomNumber;
  final String checkIn;
  final String checkOut;
  final int guests;
  final double totalPrice;
  final String guestName;
  final String? guestEmail;
  final BookingStatus status;
  final List<BookingRoomData>? selectedRooms; // For multi-room bookings
  final int roomsCount; // Number of rooms booked

  const BookingConfirmationWidgetData({
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
      'selected_rooms': selectedRooms?.map((room) => room).toList(),
      'rooms_count': roomsCount,
    };
  }

  @override
  List<Object?> get props => [
    bookingId, roomName, roomNumber, checkIn, checkOut, guests, totalPrice,
    guestName, guestEmail, status, selectedRooms, roomsCount
  ];
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Service request widget data
class ServiceRequestWidgetData extends ChatWidgetData {
  final List<ServiceOption> services;
  final String? title;
  final String? description;

  const ServiceRequestWidgetData({
    required this.services,
    this.title,
    this.description,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'services': services.map((service) => service).toList(),
      'title': title,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [services, title, description];
}

class ServiceOption extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String serviceType;

  const ServiceOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [id, name, description, icon, serviceType];
}

/// Quick actions widget data
class QuickActionsWidgetData extends ChatWidgetData {
  final String title;
  final List<QuickAction> actions;

  const QuickActionsWidgetData({
    required this.title,
    required this.actions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'actions': actions.map((action) => action).toList(),
    };
  }

  @override
  List<Object?> get props => [title, actions];
}

class QuickAction extends Equatable {
  final String id;
  final String label;
  final String action;
  final String icon;
  final Map<String, dynamic> parameters;

  const QuickAction({
    required this.id,
    required this.label,
    required this.action,
    required this.icon,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [id, label, action, icon, parameters];
}

/// Info card widget data
class InfoCardWidgetData extends ChatWidgetData {
  final String title;
  final String content;
  final String? imageUrl;
  final List<String> features;

  const InfoCardWidgetData({
    required this.title,
    required this.content,
    this.imageUrl,
    this.features = const [],
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'features': features,
    };
  }

  @override
  List<Object?> get props => [title, content, imageUrl, features];
}

/// Calendar widget data
class CalendarWidgetData extends ChatWidgetData {
  final DateTime? selectedDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String purpose; // 'check_in', 'check_out', 'service_date'

  const CalendarWidgetData({
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.purpose = 'check_in',
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'selected_date': selectedDate?.toIso8601String(),
      'min_date': minDate?.toIso8601String(),
      'max_date': maxDate?.toIso8601String(),
      'purpose': purpose,
    };
  }

  @override
  List<Object?> get props => [selectedDate, minDate, maxDate, purpose];
}

/// Widget data for guest selector
class GuestSelectorWidgetData extends ChatWidgetData {
  final int currentGuests;
  final int maxGuests;
  final int minGuests;
  final String title;
  final String? subtitle;

  const GuestSelectorWidgetData({
    required this.currentGuests,
    this.maxGuests = 10,
    this.minGuests = 1,
    this.title = 'How many guests?',
    this.subtitle,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'current_guests': currentGuests,
      'max_guests': maxGuests,
      'min_guests': minGuests,
      'title': title,
      'subtitle': subtitle,
    };
  }

  @override
  List<Object?> get props => [currentGuests, maxGuests, minGuests, title, subtitle];
}

/// Widget data for choice selector
class ChoiceSelectorWidgetData extends ChatWidgetData {
  final String title;
  final String? subtitle;
  final List<ChoiceOption> choices;
  final String choiceType; // 'date', 'guests', 'amenities', etc.
  final bool allowMultiple;

  const ChoiceSelectorWidgetData({
    required this.title,
    this.subtitle,
    required this.choices,
    required this.choiceType,
    this.allowMultiple = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'choices': choices.map((choice) => choice).toList(),
      'choice_type': choiceType,
      'allow_multiple': allowMultiple,
    };
  }

  @override
  List<Object?> get props => [title, subtitle, choices, choiceType, allowMultiple];
}

/// Individual choice option
class ChoiceOption extends Equatable {
  final String id;
  final String label;
  final String? description;
  final String? icon;
  final Map<String, dynamic> data;

  const ChoiceOption({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.data = const {},
  });

  @override
  List<Object?> get props => [id, label, description, icon, data];
}

/// Widget data for multi-choice selector with multiple sections
class MultiChoiceSelectorWidgetData extends ChatWidgetData {
  final String title;
  final String? subtitle;
  final List<SelectorSection> selectors;

  const MultiChoiceSelectorWidgetData({
    required this.title,
    this.subtitle,
    required this.selectors,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'selectors': selectors.map((selector) => selector).toList(),
    };
  }

  @override
  List<Object?> get props => [title, subtitle, selectors];
}

/// Individual selector section within multi-choice selector
class SelectorSection extends Equatable {
  final String id;
  final String title;
  final String choiceType;
  final bool allowMultiple;
  final List<ChoiceOption> choices;

  const SelectorSection({
    required this.id,
    required this.title,
    required this.choiceType,
    this.allowMultiple = false,
    required this.choices,
  });

  @override
  List<Object?> get props => [id, title, choiceType, allowMultiple, choices];
}

/// Widget data for room search results
class RoomResultsWidgetData extends ChatWidgetData {
  final String title;
  final List<RoomWidgetData> rooms;
  final Map<String, dynamic> searchParams;
  final String? message;

  const RoomResultsWidgetData({
    required this.title,
    required this.rooms,
    required this.searchParams,
    this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rooms': rooms.map((room) => room.toJson()).toList(),
      'search_params': searchParams,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [title, rooms, searchParams, message];
}

/// Widget data for booking results
class BookingResultWidgetData extends ChatWidgetData {
  final String title;
  final String bookingId;
  final String roomName;
  final String roomNumber;
  final String checkIn;
  final String checkOut;
  final int guests;
  final double totalPrice;
  final String status; // pending_payment, confirmed, cancelled
  final String? message;
  final String? paymentUrl;

  const BookingResultWidgetData({
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

  @override
  Map<String, dynamic> toJson() {
    return {
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
  }

  @override
  List<Object?> get props => [
    title, bookingId, roomName, roomNumber, checkIn, checkOut,
    guests, totalPrice, status, message, paymentUrl
  ];
}

/// Widget data for service results  
class ServiceResultWidgetData extends ChatWidgetData {
  final String title;
  final String serviceType;
  final String status; // requested, confirmed, completed
  final String? requestId;
  final String? message;
  final String? estimatedTime;

  const ServiceResultWidgetData({
    required this.title,
    required this.serviceType,
    required this.status,
    this.requestId,
    this.message,
    this.estimatedTime,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'service_type': serviceType,
      'status': status,
      'request_id': requestId,
      'message': message,
      'estimated_time': estimatedTime,
    };
  }

  @override
  List<Object?> get props => [title, serviceType, status, requestId, message, estimatedTime];
}

/// Widget data for payment results
class PaymentResultWidgetData extends ChatWidgetData {
  final String title;
  final String bookingId;
  final String status; // pending, successful, failed
  final double amount;
  final String? transactionId;
  final String? message;
  final String? receiptUrl;

  const PaymentResultWidgetData({
    required this.title,
    required this.bookingId,
    required this.status,
    required this.amount,
    this.transactionId,
    this.message,
    this.receiptUrl,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'booking_id': bookingId,
      'status': status,
      'amount': amount,
      'transaction_id': transactionId,
      'message': message,
      'receipt_url': receiptUrl,
    };
  }

  @override
  List<Object?> get props => [title, bookingId, status, amount, transactionId, message, receiptUrl];
}

/// Widget data for flexible input collector
class FlexibleInputCollectorWidgetData extends ChatWidgetData {
  final String title;
  final String? subtitle;
  final String context; // Function context like 'room_search', 'booking_creation', 'support_request'
  final List<InputField> requiredFields;
  final List<InputField> optionalFields;
  final String inputPlaceholder;

  const FlexibleInputCollectorWidgetData({
    required this.title,
    this.subtitle,
    required this.context,
    required this.requiredFields,
    this.optionalFields = const [],
    required this.inputPlaceholder,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'context': context,
      'required_fields': requiredFields.map((field) => field).toList(),
      'optional_fields': optionalFields.map((field) => field).toList(),
      'input_placeholder': inputPlaceholder,
    };
  }

  @override
  List<Object?> get props => [title, subtitle, context, requiredFields, optionalFields, inputPlaceholder];
}

/// Individual input field within flexible input collector
class InputField extends Equatable {
  final String name;
  final String type; // 'date_range', 'number', 'text', 'enum'
  final String label;
  final List<String> examples;
  final String? description;
  final bool required;
  final Map<String, dynamic> constraints; // Min/max values, allowed values, etc.

  const InputField({
    required this.name,
    required this.type,
    required this.label,
    required this.examples,
    this.description,
    this.required = true,
    this.constraints = const {},
  });

  @override
  List<Object?> get props => [name, type, label, examples, description, required, constraints];
}