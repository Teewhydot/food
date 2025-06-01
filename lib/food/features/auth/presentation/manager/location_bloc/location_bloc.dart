import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<LocationRequestedEvent>((event, emit) async {
      emit(LocationLoading());
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2), () {
        emit(LocationSuccess(message: "Location fetched successfully"));
      });
    });
  }
}
