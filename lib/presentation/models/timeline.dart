import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';

class Timeline {
  final String title;
  final Color color;
  final List<EventPost> events;

  bool active;
  bool fullscreen;
  TimelineContent? timelineWidget;

  Timeline({
    required this.title,
    required this.color,
    required this.active,
    required this.fullscreen,
    required this.events,
    required this.timelineWidget,
  });
}
