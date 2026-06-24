import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';

void main()
{
  EventPost buildEvent() {
    return EventPost(
      id: '1',
      title: 'Test event',
      description: '',
      createdAt: DateTime(2026),
      startDuration: DateTime(2026),
      endDuration: DateTime(2026, 1, 2),
      categoryId: 'c1',
      userId: '1',
    );
  }

  final event = buildEvent();

  group('EventInteractionCubit', () {

    blocTest(
      'select opens the event and focuses it',
      build: () => EventInteractionCubit(),
      act: (cubit) => cubit.select(event),
      expect: () => [
        isA<EventInteractionState>()
          .having((s) => s.openEvents, 'openEvents', [event])
          .having((s) => s.selectedEvent, 'selectedEvent', event),
      ],
    );

    blocTest(
      'minimize moves the event to the minimized stack',
      build: () => EventInteractionCubit(),
      seed: () => EventInteractionState(openEvents: [event]),
      act: (cubit) => cubit.minimize(event),
      expect: () => [
        isA<EventInteractionState>()
          .having((s) => s.openEvents, 'openEvents', isEmpty)
          .having((s) => s.minimizedEvents, 'minimizedEvents', [event]),
      ],
    );

    blocTest(
      'dismiss removes the event again',
      build: () => EventInteractionCubit(),
      seed: () => EventInteractionState(openEvents: [event], selectedEvent: event),
      act: (cubit) => cubit.dismiss(event),
      expect: () => [
        isA<EventInteractionState>()
          .having((s) => s.openEvents, 'openEvents', isEmpty),
      ],
    );

  });
}
