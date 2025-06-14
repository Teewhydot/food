import 'package:flutter/material.dart';
import 'package:food/food/features/tracking/domain/entities/chat_entity.dart';

@immutable
abstract class ChatsState {}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatEntity> chats;

  ChatsLoaded({required this.chats});
}

class ChatsError extends ChatsState {
  final String message;

  ChatsError({required this.message});
}
