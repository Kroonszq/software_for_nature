import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/models/timeline.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_header.dart';

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
  final VoidCallback onFullScreen;


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
    required this.onFullScreen
  });

  @override
  Widget build(BuildContext context) {
    final String categoryName = timeline.events.isNotEmpty
        ? timeline.events.first.category?.name ?? timeline.title
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
              categoryName: categoryName,
              position: position,
              color: timeline.color,
              onMinimize: onMinimize,
              onFullScreen: onFullScreen,
              timeline: timeline,
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
