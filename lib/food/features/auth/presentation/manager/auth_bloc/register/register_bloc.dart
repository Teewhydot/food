import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterInitialEvent>((event, emit) async {
      emit(RegisterLoading());
      // Simulate a network call

      await Future.delayed(const Duration(seconds: 1), () {
        emit(RegisterSuccess(successMessage: "Registration successful"));
      });
    });
  }
}
