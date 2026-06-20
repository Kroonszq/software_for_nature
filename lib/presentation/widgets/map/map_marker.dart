import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/time_window.dart';

class MapMarker extends StatelessWidget {
  final EventPost event;
  final TimeWindow timeWindow;

  const MapMarker({
    super.key,
    required this.event,
    required this.timeWindow,
  });

  static const double markerWidth = 40;
  static const double markerHeight = 52;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DurationBar(
          event: event,
          timeWindow: timeWindow,
        ),
        const Icon(
          Icons.location_pin,
          size: 32,
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _DurationBar extends StatelessWidget {
  final EventPost event;
  final TimeWindow timeWindow;

  const _DurationBar({
    required this.event,
    required this.timeWindow,
  });

  @override
  Widget build(BuildContext context) {
    final end = event.endDuration;
    if (end == null) return const SizedBox(height: 4);

    final eventMinutes =
        end.difference(event.startDuration).inMinutes;

    final windowMinutes =
        timeWindow.duration.inMinutes;

    final fraction =
        (eventMinutes / windowMinutes).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 36, // <-- fixed width
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: fraction, // <-- variable width
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}