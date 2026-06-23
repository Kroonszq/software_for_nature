

import 'package:logger/logger.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';

final class EventService implements EventServiceInterface {
  final EventPostRepositoryInterface _eventRepository;
  final Logger _logger;
  
  const EventService({required this._eventRepository, required this._logger});

  @override
  Future<List<EventPost>> getAllEvents() async {
      return await _eventRepository.getAll() ?? const <EventPost>[];
  }

  @override
  Future<EventPost?> createEvent(EventPost event) async {
    var newEvent = await _eventRepository.create(event);
    if(newEvent == null){
      _logger.e("Something went wrong creating a new event");
      return null;
    }

    return newEvent;
  }

  @override
  Future<EventPost?> updateEvent(EventPost event) async {
    var updated = await _eventRepository.update(event);
    if (updated == null) {
      _logger.e("Something went wrong updating event ${event.id}");
      return null;
    }

    return updated;
  }

  @override
  Future<List<EventPost>> queryEvent(EventQuery query) async {
    final allEvents = await _eventRepository.getAll();

    if(allEvents == null){
      return const <EventPost>[];
    }

    String? normalizedSearch;
    if(query.search != null || query.search!.trim().isNotEmpty) {
        normalizedSearch = query.search!.toLowerCase();
    }

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

      if (normalizedSearch != null && !event.title.toLowerCase().contains(normalizedSearch) && !event.description.toLowerCase().contains(normalizedSearch)) {
        return false;
      }

      if (query.bounds != null) {
        final c = event.coordinates;
        if (c == null || !query.bounds!.contains(c)) {
          return false;
        }
      }

      // Duration overlap with the requested range
      if (query.timeRange != null && !(event.endDuration.isAfter(query.timeRange!.start) && event.startDuration.isBefore(query.timeRange!.end))) {
        return false;
      }

      if (query.tagLabels != null && query.tagLabels!.isNotEmpty) {
        if (event.tags.isNotEmpty && !event.tags.any((t) => query.tagLabels!.contains(t.label))) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}