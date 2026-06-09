import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';

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

        return MouseRegion(
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
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
              margin: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 30, // <-- keeps card above scrollbar
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                border: Border.all(color: Colors.blue),
              ),
              padding: const EdgeInsets.all(4),
              width: state.selectedPost == event ? 800 : 100,
              height: getHeight(event),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Start: ${_formatTime(event.startDuration)}',
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'End: ${_formatTime(event.endDuration)}',
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

String _formatTime(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * pixelsPerMinute;
  }
}