import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/presentation/models/timeline.dart';

class TimelineHeader extends StatelessWidget{
  final String title;
  final String categoryName;
  final int position;
  final VoidCallback onMinimize;
  final VoidCallback onFullScreen;
  final Color color;
  final Timeline timeline;

    const TimelineHeader({
      super.key,
      required this.title,
      required this.categoryName,
      required this.position,
      required this.onMinimize,
      required this.onFullScreen,
      required this.color,
      required this.timeline,
  });


 @override
  Widget build(BuildContext context) {

    // Use a more compact header on mobile
    final bool isCompact = MediaQuery.sizeOf(context).width < TimelineConstants.compactBreakpoint;

    return Container(
      color: color,
      height: isCompact ? 32 : 50,
      child: Row(
        children: [
          // Drag handle: the ONLY region that starts a reorder drag. Keeping
          // the drag listener confined to the handle (instead of the whole
          // header) avoids a race where a minimize tap removes this timeline
          // from the active set mid-drag, which crashes the reorderable list.
          ReorderableDragStartListener(
            index: position,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.drag_indicator, size: isCompact ? 14 : 18),
              ),
            ),
          ),
          // Tapping the title area minimizes the timeline.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMinimize,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'minimize',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: isCompact ? 9 : 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onFullScreen,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                timeline.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: isCompact ? 14 : 18,
              ),
            ),
          ),

          SizedBox(width: isCompact ? 14 : 22),
        ],
      ),
    );
  }
}
