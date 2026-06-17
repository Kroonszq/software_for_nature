import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';

class MapMarker extends StatelessWidget {
  final EventPost event;

  const MapMarker({super.key, required this.event});

  static const double markerWidth = 40;
  static const double markerHeight = 52;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DurationBar(event: event),
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

  const _DurationBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final end = event.endDuration;
    if (end == null) return const SizedBox(height: 4);

    final durationMinutes =
        end.difference(event.startDuration).inMinutes;

    final width = (durationMinutes / 60).clamp(0.3, 2.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 18 * width,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.6,
        alignment: Alignment.centerLeft,
        child: Container(color: Colors.green),
      ),
    );
  }
}