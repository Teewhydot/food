import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/core/utils/pretty_firebase_errors.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/tracking/domain/use_cases/notification_usecase.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'register_event.dart';
// part 'register_state.dart'; // Commented out - using BaseState now

/// Migrated RegisterBloc to use BaseState<UserProfileEntity> (converted to Cubit pattern)
class RegisterBloc extends BaseCubit<BaseState<UserProfileEntity>> {
  final _authUseCase = AuthUseCase();
  RegisterBloc() : super(const InitialState<UserProfileEntity>());

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
      emit(const LoadingState<UserProfileEntity>(message: 'Creating your account...'));
      
      final result = await _authUseCase.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      await result.fold(
        (failure) async {
          emit(
            ErrorState<UserProfileEntity>(
              errorMessage: getAuthErrorMessage(failure.failureMessage),
              errorCode: failure.failureMessage,
              isRetryable: true,
            ),
          );
        },
        (userProfile) async {
          // Send verification email after successful registration
          final verificationResult = await _authUseCase.sendEmailVerification(
            email,
          );

          await verificationResult.fold(
            (failure) async {
              emit(
                ErrorState<UserProfileEntity>(
                  errorMessage: getAuthErrorMessage(failure.failureMessage),
                  errorCode: failure.failureMessage,
                  isRetryable: true,
                ),
              );
            },
            (_) async {
              // First emit the loaded state with user data
              emit(
                LoadedState<UserProfileEntity>(
                  data: userProfile,
                  lastUpdated: DateTime.now(),
                ),
              );

              // Update FCM token for notifications
              try {
                final notificationUseCase = NotificationUseCase();
                final tokenResult = await notificationUseCase.getFCMToken();

                tokenResult.fold(
                  (failure) => Logger.logError('Failed to get FCM token: ${failure.failureMessage}'),
                  (token) async {
                    if (token != null && userProfile.id != null) {
                      final updateResult = await notificationUseCase.updateFCMToken(userProfile.id!, token);
                      updateResult.fold(
                        (failure) => Logger.logError('Failed to update FCM token: ${failure.failureMessage}'),
                        (_) => Logger.logSuccess('FCM token updated successfully after registration'),
                      );
                    }
                  },
                );
              } catch (e) {
                Logger.logError('Failed to update FCM token after registration: $e');
              }

              // Then emit success state for notification
              emit(
                const SuccessState<UserProfileEntity>(
                  successMessage:
                      'Registration successful. Please verify your email.',
                ),
              );
            },
          );
        },
      );
  }
}
