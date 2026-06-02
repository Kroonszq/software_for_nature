

import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_widget.dart';

class Timeline {
  final String title;
  final List<EventPost> events;

  bool active;
  TimelineWidget? timelineWidget;

  Timeline({
    required this.title,
    required this.active,
    required this.events,
    required this.timelineWidget
  });
}