import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';

class MapMarker extends StatelessWidget {
  final EventPost event;
  final bool spiderfied;

  const MapMarker({
    super.key,
    required this.event,
    this.spiderfied = false,
  });

  static const double markerWidth = 42;
  static const double markerHeight = 56;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        context.read<EventSelectionBloc>().add(HoverEvent(event));
      },
      onExit: (_) {
        context.read<EventSelectionBloc>().add(ClearHoverEvent());
      },
      child: GestureDetector(
        onTap: () {
          context.read<EventSelectionBloc>().add(SelectEvent(event));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DurationBar(event: event),

            const SizedBox(height: 2),

            _buildIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (spiderfied) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }

    return const Icon(
      Icons.location_pin,
      size: 32,
      color: Colors.blue,
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

    final duration = end.difference(event.startDuration).inMinutes;
    final width = (duration / 60).clamp(0.3, 2.0);

    return Container(
      width: 18 * width,
      height: 4,
      margin: const EdgeInsets.only(bottom: 4),
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
