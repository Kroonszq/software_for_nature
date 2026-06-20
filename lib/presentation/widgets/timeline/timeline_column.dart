import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/timeline.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_header.dart';

/// A single timeline "lane": the header on top and the scrollable
/// [TimelineContent] body below, wrapped in a focus border + tap gesture.
///
/// The body (events laid out against time) lives in [TimelineContent]; this
/// widget only composes the lane chrome around it so it can be reordered inside
/// the [TimelineView]'s horizontal list.
class TimelineColumn extends StatelessWidget {
  final Timeline timeline;
  final int timelineKey;
  final int position;
  final double width;
  final bool isFocused;
  final bool enableHorizontalScroll;
  final DateTime earliest;
  final double minHeight;
  final ScrollController? scrollController;
  final VoidCallback? onTap;
  final VoidCallback onMinimize;

  const TimelineColumn({
    super.key,
    required this.timeline,
    required this.timelineKey,
    required this.position,
    required this.width,
    required this.isFocused,
    required this.enableHorizontalScroll,
    required this.earliest,
    required this.minHeight,
    required this.scrollController,
    required this.onTap,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    final String groupName = timeline.events.isNotEmpty
        ? timeline.events.first.group?.title ?? timeline.title
        : timeline.title;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused ? const Color(0xFFFF5900) : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            // Timeline header
            TimelineHeader(
              title: 'Timeline $timelineKey',
              groupName: groupName,
              position: position,
              color: timeline.color,
              onMinimize: onMinimize,
            ),
            // Timeline content
            Expanded(
              child: timeline.timelineWidget != null
                  ? TimelineContent(
                      earliest: earliest,
                      listOfEvents: timeline.timelineWidget!.listOfEvents,
                      scrollController: scrollController,
                      groupColor: timeline.color,
                      minHeight: minHeight,
                      enableHorizontalScroll: enableHorizontalScroll,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
