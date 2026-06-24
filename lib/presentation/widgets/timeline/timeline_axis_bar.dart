import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';

class TimeAxisBar extends StatelessWidget {
  static const double pixelsPerMinute = 2.0;
  final DateTime earliest;
  final DateTime latest;
  final double headerHeight;

  const TimeAxisBar({
    super.key,
    required this.earliest,
    required this.latest,
    this.headerHeight = 50,
  });

  /// The timelineaxis width
  static const double _width = 72;

  /// A smaller width used on mobile screens to give the timelines more horizontal room
  static const double _compactWidth = 48;

@override
Widget build(BuildContext context) {
  final bool isCompact = MediaQuery.sizeOf(context).width < 700;
  final double width = isCompact ? _compactWidth : _width;

  final totalMinutes = latest.difference(earliest).inMinutes;
  final totalHeight = totalMinutes * pixelsPerMinute + headerHeight + 16;

  final stackChildren = <Widget>[
    SizedBox(
      height: totalMinutes * pixelsPerMinute,
      width: width,
    ),
  ];

  DateTime? previousDay;
  for (int i = 0; i <= totalMinutes; i += 30) {
    final tickTime = earliest.add(Duration(minutes: i));
    final tickDay = DateTime(tickTime.year, tickTime.month, tickTime.day);

    // show the date label if its the first tick
    final showDate = previousDay == null || tickDay != previousDay;
    previousDay = tickDay;

    // display date label
    if (showDate) {
      stackChildren.add(
        Positioned(
          top: i * pixelsPerMinute - 11,
          left: 0,
          right: 10,
          child: Text(
            TimeUtils.formatDate(tickTime),
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // add tick to stack
    stackChildren.add(
      Positioned(
        top: i * pixelsPerMinute,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              TimeUtils.formatTime(tickTime),
              style: const TextStyle(fontSize: 9),
            ),
            const SizedBox(width: 2),
            Container(width: 8, height: 1, color: Colors.grey),
          ],
        ),
      ),
    );
    }

    // display axis
    return SizedBox(
      width: width,
      height: totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: headerHeight),
          Stack(
            clipBehavior: Clip.none,
            children: stackChildren,
          ),
        ],
      ),
    );
  }
}