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
              child: Text(event.title),
            ),
          ),
        );
      },
    );
  }

  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * pixelsPerMinute;
  }
}