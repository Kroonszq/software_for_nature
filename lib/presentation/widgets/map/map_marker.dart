import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/presentation/widgets/map/marker_label.dart';

class MapMarker extends StatefulWidget {
  final EventPost event;
  final TimeWindow timeWindow;

  /// colour of the pin from the category
  final Color color;

  const MapMarker({super.key, required this.event, required this.timeWindow, this.color = Colors.blue});

  /// total size of the marker box
  static const double markerWidth = 200;
  static const double markerHeight = 160;

  @override
  State<MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<MapMarker> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
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
        _DurationBar(event: event, timeWindow: widget.timeWindow),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: () {
              context.read<EventInteractionCubit>().select(event);
              Scaffold.of(context).openDrawer();
            },
            child: Icon(
              Icons.location_pin,
              size: 32,
              color: widget.color,
            ),
          ),
        ),
        MarkerLabel(title: event.title, maxWidth: MapMarker.markerWidth),
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
    final eventMinutes = event.endDuration.difference(event.startDuration).inMinutes;

    final windowMinutes = timeWindow.duration.inMinutes;

    final fraction = windowMinutes > 0
        ? (eventMinutes / windowMinutes).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: fraction,
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
