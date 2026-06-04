import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/media.dart';

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
        coordinates: const Coordinates(
          lat: 52.0907,
          lng: 5.1214,
        ),
        media: [
          const ImageMedia(
            id: "1",
            title: "image 1",
            altText: "image 1 alt text",
            source: "/pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg",
          ),
          const VideoMedia(
            id: "2",
            title: "video 1",
            altText: "video 1 alt text",
            source: "/multimedia/avi/EMOV_20260322-150000.avi",
          ),
        ]
      ),
      EventPost(
        id: '2',
        title: 'Forest Walk',
        description: 'Nature observation walk.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        coordinates: const Coordinates(
          lat: 52.1000,
          lng: 5.1100,
        ),
      ),
      EventPost(
        id: '3',
        title: 'Research Note',
        description: 'Bird migration spotted.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        coordinates: null, // timeline-only event
      ),
      EventPost(
        id: '4',
        title: 'Event 4',
        description: '4444444444',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        coordinates: const Coordinates(
          lat: 52.2,
          lng: 5.2100,
        ),
      ),
    ];
  }
}