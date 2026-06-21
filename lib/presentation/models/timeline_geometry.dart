
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';

class TimelineGeometry{
  final DateTime earliest;
  final DateTime latest;
  final double totalHeight;
  
  const TimelineGeometry({required this.earliest, required this.latest, required this.totalHeight});

  factory TimelineGeometry.fromEvents(List<EventPost> events, {DateTime? earliest}) {
    final start = earliest ?? events.map((e) => e.startDuration).reduce((a, b) => a.isBefore(b) ? a : b);
    final end = events.map((e) => e.endDuration).reduce((a, b) => a.isAfter(b) ? a : b);
    final minutes = end.difference(start).inMinutes;
    return TimelineGeometry(earliest: start, latest: end, totalHeight: minutes * TimelineConstants.pixelsPerMinute);
  }
}