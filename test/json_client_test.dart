import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/data/data_sources/event_post_api_client.dart';
import 'package:software_for_nature/data/models/event_post.dart';

void main() {
  // Needed so rootBundle can load the declared JSON assets in tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventPostApiClient', () {
    late List<EventPost> posts;

    setUpAll(() async {
      posts = await EventPostApiClient().fetchEventPosts();
    });

    test('loads every event from event.json', () {
      expect(posts.length, 30);
    });

    test('event ids are unique', () {
      final ids = posts.map((e) => e.id).toSet();
      expect(ids.length, posts.length);
    });

    test('parses the scalar fields of an event', () {
      final first = posts.firstWhere((e) => e.id == '1');

      expect(first.title, 'River Cleanup');
      expect(first.description, 'Volunteers cleaning the river.');
      expect(first.timestamp, DateTime.parse('2026-06-15T12:00:00'));
      expect(first.startDuration, DateTime.parse('2026-06-15T07:00:00'));
      expect(first.endDuration, DateTime.parse('2026-06-15T09:00:00'));
    });

    test('parses coordinates', () {
      final first = posts.firstWhere((e) => e.id == '1');

      expect(first.coordinates, isNotNull);
      expect(first.coordinates!.lat, closeTo(52.0907, 1e-9));
      expect(first.coordinates!.lng, closeTo(5.1214, 1e-9));
    });

    test('resolves each event to its group via the join table', () {
      expect(posts.firstWhere((e) => e.id == '1').group.title, 'Group 1');
      expect(posts.firstWhere((e) => e.id == '11').group.title, 'Group 2');
      expect(posts.firstWhere((e) => e.id == '21').group.title, 'Group 3');
    });

    test('parses group colours from their hex strings', () {
      expect(
        posts.firstWhere((e) => e.id == '1').group.color,
        const Color(0xFFF44336),
      );
      expect(
        posts.firstWhere((e) => e.id == '11').group.color,
        const Color(0xFF4CAF50),
      );
      expect(
        posts.firstWhere((e) => e.id == '21').group.color,
        const Color(0xFF2196F3),
      );
    });

    test('every event resolves to a real group (no fallback)', () {
      for (final e in posts) {
        expect(e.group.title, isNot('Ungrouped'), reason: 'event ${e.id}');
      }
    });

    test('events start before they end', () {
      for (final e in posts) {
        expect(
          e.startDuration.isBefore(e.endDuration),
          isTrue,
          reason: 'event ${e.id} should start before it ends',
        );
      }
    });

    test('events default to empty attachments and charts', () {
      final first = posts.firstWhere((e) => e.id == '1');

      expect(first.attachments, isEmpty);
      expect(first.charts, isEmpty);
    });
  });
}
