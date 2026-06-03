
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

class TimelineHeader extends StatelessWidget{
  final String title;
  final int position;
  final VoidCallback onMinimize;

    const TimelineHeader({
      super.key,
      required this.title,
      required this.position,
      required this.onMinimize,
  });


 @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: position,
      child: GestureDetector(
        onTap: onMinimize,
        child: Container(
          color: Colors.blue,
          height: 50,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
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
      ),
    );
  }
}