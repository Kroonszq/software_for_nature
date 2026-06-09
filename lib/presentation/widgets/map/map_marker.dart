import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_state.dart';

class MapMarker extends StatelessWidget {
  final EventPost event;

  const MapMarker({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventSelectionBloc, EventSelectionState>(
      builder: (context, state) {
        final isSelected = state.selected.contains(event);
        final isHovered = state.hovered == event;

        return MouseRegion(
          onEnter: (_) => context
              .read<EventSelectionBloc>()
              .add(HoverEvent(event)),
          onExit: (_) => context
              .read<EventSelectionBloc>()
              .add(HoverEvent(null)),
          child: GestureDetector(
            onTap: () => context
                .read<EventSelectionBloc>()
                .add(SelectEvent(event)),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ───────── duration bar ─────────
                _DurationBar(event: event),

                // ───────── marker icon ─────────
                Icon(
                  Icons.location_pin,
                  size: 32,
                  color: isSelected
                      ? Colors.red
                      : isHovered
                          ? Colors.orange
                          : Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DurationBar extends StatelessWidget {
  final EventPost event;

  const _DurationBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startDuration;
    final end = event.endDuration;

    if (end == null) return const SizedBox();

    final durationMinutes =
        end.difference(start).inMinutes;

    final width = (durationMinutes / 60).clamp(0.2, 2.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 20 * width,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.6, // placeholder “selected window”
        alignment: Alignment.centerLeft,
        child: Container(
          color: Colors.green,
        ),
      ),
    );
  }
}