import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';


class HybridMapMarker extends StatefulWidget {
  final EventPost event;
  final bool isSelected;

  const HybridMapMarker({
    super.key,
    required this.event,
    required this.isSelected,
  });

  /// Total size of the marker box. The pin sits at the bottom-center while the
  /// remaining space above is reserved for the hover details box.
  static const double width = 200;
  static const double height = 132;

  @override
  State<HybridMapMarker> createState() => _HybridMapMarkerState();
}

class _HybridMapMarkerState extends State<HybridMapMarker> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Details box floats in the space above the pin. It never captures the
        // pointer so it can't keep itself visible.
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _hovered ? 1 : 0,
                child: _EventDetailsBox(event: event),
              ),
            ),
          ),
        ),
        // Only the pin reacts to hover/tap, so the box appears only when the
        // pointer is directly over the marker.
        MouseRegion(
          cursor: SystemMouseCursors.click,
          // Hovering a pin highlights the matching card in the timeline, scrolls
          // it into view, and reveals the details box above the pin.
          onEnter: (_) {
            setState(() => _hovered = true);
            context.read<TimelineBloc>().add(FocusTimelineEvent(event));
          },
          onExit: (_) {
            setState(() => _hovered = false);
            context.read<TimelineBloc>().add(UnSelectTimelineEvent());
          },
          child: GestureDetector(
            // Clicking a pin opens the event in the drawer and selects it.
            onTap: () {
              context.read<HybridBloc>().add(HybridEventSelected(event));
              context.read<EventInteractionCubit>().select(event);
              Scaffold.of(context).openDrawer();
            },
            // Highlight this pin with a dark overlay behind it whenever the
            // matching event is hovered in the timeline.
            child: BlocBuilder<TimelineBloc, TimelineState>(
              builder: (context, state) {
                final highlighted = state is TimelineInitial &&
                    state.selectedPost?.id == event.id;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: highlighted ? 1 : 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_pin,
                      color: widget.isSelected ? Colors.red : Colors.blue,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EventDetailsBox extends StatelessWidget {
  final EventPost event;

  const _EventDetailsBox({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Category: ${event.category?.name ?? 'Uncategorized'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
          ),
          Text(
            'Start: ${TimeUtils.formatDateTime(event.startDuration)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
          ),
          Text(
            'Duration: '
            '${TimeUtils.formatDuration(event.endDuration.difference(event.startDuration))}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }
}
