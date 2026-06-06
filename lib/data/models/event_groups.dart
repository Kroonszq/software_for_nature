
import 'package:flutter/cupertino.dart';
import 'package:software_for_nature/data/models/event_post.dart';

@immutable
class EventGroups {
  final List<EventPost> listOfEvents;

  const EventGroups({
    required this.listOfEvents
  });
}
