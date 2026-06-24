import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';

import '../models/event_post.dart';

class EventPostRepository extends BaseRepository<EventPost> implements EventPostRepositoryInterface {

  EventPostRepository({required super.jsonClient});

  @override
  Future<List<EventPost>> queryEvents(EventQuery query) async {
    final allEvents = await getAll();

    final String? normalizedSearch =
        (query.search == null || query.search!.trim().isEmpty)
            ? null
            : query.search!.toLowerCase();

    return allEvents.where((event) {
      if (query.categoryIds != null &&
          query.categoryIds!.isNotEmpty &&
          !query.categoryIds!.contains(event.categoryId)) {
        return false;
      }

      if (query.startDate != null && event.occurredAt.isBefore(query.startDate!)) {
        return false;
      }
      if (query.endDate != null && event.occurredAt.isAfter(query.endDate!)) {
        return false;
      }

      if (normalizedSearch != null &&
          !event.title.toLowerCase().contains(normalizedSearch) &&
          !event.description.toLowerCase().contains(normalizedSearch)) {
        return false;
      }

      if (query.bounds != null) {
        final c = event.coordinates;
        if (c == null || !query.bounds!.contains(c)) {
          return false;
        }
      }

      if (query.timeRange != null &&
          !(event.endDuration.isAfter(query.timeRange!.start) &&
              event.startDuration.isBefore(query.timeRange!.end))) {
        return false;
      }
      if (query.tagLabels != null && query.tagLabels!.isNotEmpty) {
        if (event.tags.isNotEmpty &&
            !event.tags.any((t) => query.tagLabels!.contains(t.label))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<EventPost> getEarliestEvent() async {
    final allEvents = await getAll();
    if (allEvents.isEmpty) {
      throw StateError('No events available to determine the earliest event.');
    }
    return allEvents.reduce(
      (a, b) => a.startDuration.isBefore(b.startDuration) ? a : b,
    );
  }

  @override
  Future<EventPost> getLatestEvent() async {
    final allEvents = await getAll();
    if (allEvents.isEmpty) {
      throw StateError('No events available to determine the latest event.');
    }
    return allEvents.reduce(
      (a, b) => a.endDuration.isAfter(b.endDuration) ? a : b,
    );
  }
  
  @override
  Future<List<EventPost>?> getAllByCategoryId(String categoryId) async {
    var allEvents = await getAll();

    var filtered = allEvents.where((event) => event.categoryId == categoryId);
    return filtered.toList();
  }
}

