import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'timelines_wrapper_event.dart';
part 'timelines_wrapper_state.dart';

class TimeLinesWrapperBloc extends Bloc<TimeLinesWrapperEvent, TimeLinesWrapperState> {
  TimeLinesWrapperBloc() : super(TimeLinesWrapperInitial()) {
    on<TimeLinesWrapperEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
