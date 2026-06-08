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

@override
Widget build(BuildContext context) {
  final totalMinutes = latest.difference(earliest).inMinutes;
  final totalHeight = totalMinutes * pixelsPerMinute + headerHeight + 16;

  return SizedBox(
    width: 60,
    height: totalHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: headerHeight),
        Stack(
          children: [
            SizedBox(
              height: totalMinutes * pixelsPerMinute,
              width: 60,
            ),
            for (int i = 0; i <= totalMinutes; i += 30)
              Positioned(
                top: i * pixelsPerMinute,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(earliest.add(Duration(minutes: i))),
                      style: const TextStyle(fontSize: 9),
                    ),
                    const SizedBox(width: 2),
                    Container(width: 8, height: 1, color: Colors.grey),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}