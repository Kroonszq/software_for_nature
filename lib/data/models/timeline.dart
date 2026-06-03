

import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_column.dart';

class Timeline {
  final String title;
  final List<EventPost> events;

  bool active;
  TimelineColumn? timelineWidget;

  Timeline({
    required this.title,
    required this.active,
    required this.events,
    required this.timelineWidget
  });
}