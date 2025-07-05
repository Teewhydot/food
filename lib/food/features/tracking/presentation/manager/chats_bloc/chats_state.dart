import 'package:flutter/material.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/features/tracking/domain/entities/chat_entity.dart';

@immutable
abstract class ChatsState {}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatEntity> chats;

  ChatsLoaded({required this.chats});
}

class ChatsError extends ChatsState implements AppErrorState {
  @override
  final String errorMessage;

  ChatsError(this.errorMessage);
}
