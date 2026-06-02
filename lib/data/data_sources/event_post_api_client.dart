import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/group.dart';

import '../models/event_post.dart';

class EventPostApiClient {
  Future<List<EventPost>> fetchEventPosts() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
     EventPost(
        id: '1',
        title: 'River Cleanup',
        description: 'Volunteers cleaning the river.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        startDuration: DateTime.now().subtract(const Duration(hours: 2)),
        endDuration: DateTime.now().subtract(const Duration(hours: 1)),
        coordinates: const Coordinates(
          lat: 52.0907,
          lng: 5.1214,
        ),
        group: Group(title: "Group 1"),
      ),
      EventPost(
        id: '2',
        title: 'Forest Walk',
        description: 'Nature observation walk.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        startDuration: DateTime.now().subtract(const Duration(days: 1)),
        endDuration: DateTime.now().subtract(const Duration(hours: 22)),
        coordinates: const Coordinates(
          lat: 52.1000,
          lng: 5.1100,
        ),
        group: Group(title: "Group 1"),
      ),
      EventPost(
        id: '3',
        title: 'Research Note',
        description: 'Bird migration spotted.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        startDuration: DateTime.now().subtract(const Duration(hours: 5)),
        endDuration: DateTime.now().subtract(const Duration(hours: 4)),
        coordinates: null,
        group: Group(title: "Group 2"),
      ),
    ];
  }
}