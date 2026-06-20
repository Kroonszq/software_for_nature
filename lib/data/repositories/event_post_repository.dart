import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';

import '../models/event_post.dart';

class EventPostRepository extends BaseRepository<EventPost> implements EventPostRepositoryInterface {

  EventPostRepository({required super.jsonClient});
  
  @override
  Future<List<EventPost>?> getAllByGroupId(String id) async {
    var allEvents = await getAll();

    var filtered = allEvents.where((event) => event.groupId == id);
    return filtered.toList();
  }

 
  @override
  Future<List<EventPost>> queryEvents(EventQuery query) async {
    final allEvents = await getAll();

    final String? normalizedSearch =
        (query.search == null || query.search!.trim().isEmpty)
            ? null
            : query.search!.toLowerCase();

    return allEvents.where((event) {
      // Group filter
      if (query.groupIds != null &&
          query.groupIds!.isNotEmpty &&
          !query.groupIds!.contains(event.groupId)) {
        return false;
      }

      // Timestamp window
      if (query.startDate != null && event.timestamp.isBefore(query.startDate!)) {
        return false;
      }
      if (query.endDate != null && event.timestamp.isAfter(query.endDate!)) {
        return false;
      }

      // text search across title and description
      if (normalizedSearch != null &&
          !event.title.toLowerCase().contains(normalizedSearch) &&
          !event.description.toLowerCase().contains(normalizedSearch)) {
        return false;
      }

      // Geographic bounds
      if (query.bounds != null) {
        final c = event.coordinates;
        if (c == null || !query.bounds!.contains(c)) {
          return false;
        }
      }

      // Duration overlap with the requested range
      if (query.timeRange != null &&
          !(event.endDuration.isAfter(query.timeRange!.start) &&
              event.startDuration.isBefore(query.timeRange!.end))) {
        return false;
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
}

