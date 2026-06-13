import 'package:flutter/material.dart';

class TimelineHeader extends StatelessWidget{
  final String title;
  final String groupName;
  final int position;
  final VoidCallback onMinimize;
  final Color color;

    const TimelineHeader({
      super.key,
      required this.title,
      required this.groupName,
      required this.position,
      required this.onMinimize,
      required this.color,
  });


 @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: position,
      child: GestureDetector(
        onTap: onMinimize,
        child: Container(
          color: color,
          height: 50,
          child: Row(
            children: [
              // Drag icon for the user
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.drag_indicator, size: 18),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        groupName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'minimize',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 22),
            ],
          ),
        ),
      ),
    );
  }
}