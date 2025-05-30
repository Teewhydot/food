part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterInitialEvent extends RegisterEvent {}
