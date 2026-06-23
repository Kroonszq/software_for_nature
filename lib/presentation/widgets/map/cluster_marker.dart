import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/time_window.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final List<EventPost> events;
  final TimeWindow timeWindow;

  const ClusterMarker({
    required this.count,
    required this.events,
    required this.timeWindow,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _Circle(count: count);
    }

    final starts = events.map((e) => e.startDuration);
    final ends = events
        .where((e) => e.endDuration != null)
        .map((e) => e.endDuration!);

    final earliest =
        starts.reduce((a, b) => a.isBefore(b) ? a : b);

    final latest =
        ends.reduce((a, b) => a.isAfter(b) ? a : b);

    final visibleStart = earliest.isBefore(timeWindow.start)
        ? timeWindow.start
        : earliest;

    final visibleEnd = latest.isAfter(timeWindow.end)
        ? timeWindow.end
        : latest;

    final totalMs = timeWindow.duration.inMilliseconds;

    final leftFraction =
        visibleStart.difference(timeWindow.start).inMilliseconds /
            totalMs;

    final widthFraction =
        visibleEnd.difference(visibleStart).inMilliseconds /
            totalMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ClusterBar(
          leftFraction: leftFraction.clamp(0.0, 1.0),
          widthFraction: widthFraction.clamp(0.0, 1.0),
        ),
        _Circle(count: count),
      ],
    );
  }
}

class _ClusterBar extends StatelessWidget {
  final double leftFraction;
  final double widthFraction;

  const _ClusterBar({
    required this.leftFraction,
    required this.widthFraction,
  });

  @override
  Widget build(BuildContext context) {
    const width = 44.0;

    return Container(
      width: width,
      height: 4,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: width * leftFraction,
            width: width * widthFraction,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final int count;

  const _Circle({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}