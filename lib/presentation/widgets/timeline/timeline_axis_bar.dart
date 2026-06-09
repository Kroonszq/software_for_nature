import 'package:flutter/material.dart';

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

@override
Widget build(BuildContext context) {
  final totalMinutes = latest.difference(earliest).inMinutes;
  final totalHeight = totalMinutes * pixelsPerMinute + headerHeight + 16;

  final stackChildren = <Widget>[
    SizedBox(
      height: totalMinutes * pixelsPerMinute,
      width: _width,
    ),
  ];

  DateTime? previousDay;
  for (int i = 0; i <= totalMinutes; i += 30) {
    final tickTime = earliest.add(Duration(minutes: i));
    final tickDay = DateTime(tickTime.year, tickTime.month, tickTime.day);

    // Show the date label if its the first tick
    final showDate = previousDay == null || tickDay != previousDay;
    previousDay = tickDay;

    // Display date label
    if (showDate) {
      stackChildren.add(
        Positioned(
          top: i * pixelsPerMinute - 11,
          left: 0,
          right: 10,
          child: Text(
            _formatDate(tickTime),
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Add tick to stack
    stackChildren.add(
      Positioned(
        top: i * pixelsPerMinute,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _formatTime(tickTime),
              style: const TextStyle(fontSize: 9),
            ),
            const SizedBox(width: 2),
            Container(width: 8, height: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Display axis
  return SizedBox(
    width: _width,
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

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  String _formatDate(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}