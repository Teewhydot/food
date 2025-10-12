part of 'delete_account_bloc.dart';

@immutable
sealed class DeleteAccountEvent {}

class DeleteAccountInitialEvent extends DeleteAccountEvent {}

class DeleteAccountRequestEvent extends DeleteAccountEvent {
  final String email;
  final String token;

  DeleteAccountRequestEvent({required this.email, required this.token});
}
