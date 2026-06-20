import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';

class TimelineEventCard extends StatelessWidget {
  static const double pixelsPerMinute = 2.0;
  final EventPost event;

  const TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state is! TimelineInitial) {
          return SizedBox(
            width: 100,
            height: getHeight(event),
          );
        }

        final isExpanded = state.selectedPost?.id == event.id;
        final collapsedHeight = getHeight(event);
        // When expanded expand big enough to fit the extra details
        final height = isExpanded && collapsedHeight < 220 ? 220.0 : collapsedHeight;

        return Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: 30, // padding so we dont ruin the bottom scrollbar :)
          ),
          child: MouseRegion(
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: InkWell(
              onTap: () {
                context.read<EventInteractionCubit>().select(event);
                Scaffold.of(context).openDrawer();
              },
              onHover: (isHovering) {
                if (isHovering) {
                  context.read<TimelineBloc>().add(SelectTimelineEvent(event));
                } else {
                  context.read<TimelineBloc>().add(UnSelectTimelineEvent());
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? Colors.blue.shade100
                      : Colors.white,
                  border: Border.all(color: Colors.blue),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                width: isExpanded ? 280 : 100,
                height: height,

                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event title
                              Text(
                                event.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Event start time
                              Text(
                                'Start: ${_formatTime(event.startDuration)}',
                                style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.blue.shade900
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Event end time
                              Text(
                                'End: ${_formatTime(event.endDuration)}',
                                style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.blue.shade900
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isExpanded) 
                                ..._buildDetails(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetails() {
    return [
      const SizedBox(height: 6),
      Divider(height: 1, color: Colors.blue.shade200),
      const SizedBox(height: 6),
      Text(
        'Group: ${event.group.title}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade900),
          overflow: TextOverflow.ellipsis,
      ),
      if (event.coordinates != null) ...[
        const SizedBox(height: 2),
        Text(
          'Location: ${event.coordinates!.lat.toStringAsFixed(4)}, '
          '${event.coordinates!.lng.toStringAsFixed(4)}',
          style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 4),
      Text(
        event.description,
        style: const TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
        maxLines: 6,
      ),
    ];
  }

  String _formatTime(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * pixelsPerMinute;
  }
}