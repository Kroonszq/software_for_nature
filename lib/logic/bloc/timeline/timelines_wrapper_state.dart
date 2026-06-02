part of 'timelines_wrapper_bloc.dart';

@immutable
sealed class TimeLinesWrapperState {}

final class TimeLinesWrapperInitial extends TimeLinesWrapperState {}

final class TimeLinesWrapperLoaded extends TimeLinesWrapperState {
  final Map<int, Timeline> timelines;

  TimeLinesWrapperLoaded({
    required this.timelines,
  });

  TimeLinesWrapperLoaded copyWith({
    Map<int, Timeline>? timelines,
  }) {
    return TimeLinesWrapperLoaded(
      timelines: timelines ?? this.timelines,
    );
  }
}