import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';

import '../../../data/models/event_post.dart';

sealed class EventPostEvent {}

class LoadEventPosts extends EventPostEvent {}

class SelectEventPost extends EventPostEvent {
  final EventPost post;

  SelectEventPost(this.post);
}

class SetMapBounds extends EventPostEvent {
  final GeoBounds bounds;
  SetMapBounds(this.bounds);
}

class SetTimeRange extends EventPostEvent {
  final DateTimeRange range;
  SetTimeRange(this.range);
}