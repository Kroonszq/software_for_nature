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

    return ReorderableDragStartListener(
      index: position,
      child: GestureDetector(
        onTap: onMinimize,
        child: Container(
          color: color,
          height: isCompact ? 32 : 50,
          child: Row(
            children: [
              // Drag icon for the user
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.drag_indicator, size: isCompact ? 14 : 18),
              ),
              Expanded(
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
              GestureDetector(
                onTap: onFullScreen,
                child:
                  Padding(
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
        ),
      ),
    );
  }
}
