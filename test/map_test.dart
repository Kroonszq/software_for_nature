import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/data/data_sources/interfaces/json_client_interface.dart';
import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';

/// A stand-in event store so the bloc can load without touching real files.
class _FakeEventClient implements JsonClientInterface<EventPost> {
  final List<EventPost> events;

  _FakeEventClient(this.events);

  @override
  Future<List<EventPost>?> readJson() async => events;

  @override
  Future<void> writeJson(List<EventPost> items) async {}
}

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
      coordinates: const Coordinates(lat: 52.09, lng: 5.12),
    );
  }

  MapBloc buildBloc() {
    final repository = EventPostRepository(
      jsonClient: _FakeEventClient([buildEvent()]),
    );
    return MapBloc(repository);
  }

  group('Map', () {

    blocTest(
      'loads the events onto the map',
      build: buildBloc,
      act: (bloc) => bloc.add(LoadMapEvents()),
      expect: () => [
        isA<MapLoading>(),
        isA<MapLoaded>().having(
          (s) => s.visiblePosts.length,
          'visiblePosts',
          1,
        ),
      ],
    );

  });
}
