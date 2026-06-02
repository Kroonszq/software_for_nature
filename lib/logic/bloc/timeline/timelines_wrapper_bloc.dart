import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/timeline.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_widget.dart';

part 'timelines_wrapper_event.dart';
part 'timelines_wrapper_state.dart';

class TimeLinesWrapperBloc extends Bloc<TimeLinesWrapperEvent, TimeLinesWrapperState> {
  final EventPostRepository _eventPostRepository;

  TimeLinesWrapperBloc(this._eventPostRepository) : super(TimeLinesWrapperInitial()) {

    on<LoadTimelineEvents>((event, emit) async {
      var events = await _eventPostRepository.getEventPosts();


      // Group the event by there group property
      Map<int, Timeline> grouppedEvents = {};
      for (EventPost event in events) {
        final String groupName = event.group.title;

        if(!grouppedEvents.containsKey(groupName)){
          var timeline = Timeline(
            title: groupName,
            events: [],
            active: false,
            timelineWidget: null  
          );

          grouppedEvents[timeline.hashCode] = timeline;
        }

        final timelineEntry = grouppedEvents.entries.firstWhere(
          (entry) => entry.value.title == groupName, 
        );

        timelineEntry.value.events.add(event);
      }

      // Foreach group create a timeline
      for(final groupEntry in grouppedEvents.entries){
        final timeline = TimelineWidget(listOfEvents: groupEntry.value.events);

        grouppedEvents[groupEntry.key]!.timelineWidget = timeline;
      }

      emit(TimeLinesWrapperLoaded(timelines: grouppedEvents));
    });

    on<SetTimelineActive>((event, emit) {
        if (state is! TimeLinesWrapperLoaded) {
          return;
        }

        final current = state as TimeLinesWrapperLoaded;

        final timeline = current.timelines[event.timelineHash];

        if (timeline == null) {
          return;
        }

        if (timeline.active) {
          return;
        }

        final updatedTimelines = Map<int, Timeline>.from(current.timelines);

        timeline.active = true;
        updatedTimelines[event.timelineHash] = timeline;

        emit(
          current.copyWith(
            timelines: updatedTimelines,
          ),
        );
    });

    on<SetTimelineInActive>((event, emit) {
      if (state is! TimeLinesWrapperLoaded){
        return;
      }
      final current = state as TimeLinesWrapperLoaded;

        final timeline = current.timelines[event.timelineHash];

        if (timeline == null) {
          return;
        }

        if (!timeline.active) {
          return;
        }

        final updatedTimelines = Map<int, Timeline>.from(current.timelines);

        timeline.active = false;
        updatedTimelines[event.timelineHash] = timeline;

        emit(
          current.copyWith(
            timelines: updatedTimelines,
          ),
        );

    });

    add(LoadTimelineEvents());

  }
}
