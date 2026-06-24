import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';

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

  Widget buildSubject(List<EventPost> events) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => TimelineBloc(),
        child: Scaffold(
          body: TimelineContent(listOfEvents: events),
        ),
      ),
    );
  }

  group('Timeline', () {

    testWidgets('shows the empty state when there are no events', (tester) async {
      await tester.pumpWidget(buildSubject(const []));

      expect(find.text('No events found'), findsOneWidget);
    });

    blocTest(
      'selects the tapped event',
      build: () => TimelineBloc(),
      act: (bloc) => bloc.add(SelectTimelineEvent(buildEvent())),
      expect: () => [
        isA<TimelineInitial>().having(
          (s) => s.selectedPost?.id,
          'selectedPost',
          '1',
        ),
      ],
    );

  });
}
