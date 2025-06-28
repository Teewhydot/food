part of 'delete_account_bloc.dart';

@immutable
sealed class DeleteAccountEvent {}

class DeleteAccountInitialEvent extends DeleteAccountEvent {}

class DeleteAccountRequestEvent extends DeleteAccountEvent {}
