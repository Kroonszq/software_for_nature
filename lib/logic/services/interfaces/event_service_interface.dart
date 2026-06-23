

import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';

abstract interface class EventServiceInterface {
  Future<EventPost?> createEvent(EventPost event);

  Future<EventPost?> updateEvent(EventPost event);

  Future<List<EventPost>> getAllEvents();

  Future<List<EventPost>> queryEvent(EventQuery query);
}