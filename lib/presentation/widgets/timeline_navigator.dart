import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/time_window.dart';

class TimelineNavigator extends StatelessWidget {
  final DateTime minTime;
  final DateTime maxTime;
  final TimeWindow window;
  final ValueChanged<TimeWindow> onChanged;

  const TimelineNavigator({
    super.key,
    required this.minTime,
    required this.maxTime,
    required this.window,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double toX(DateTime t) {
          final total = maxTime.difference(minTime).inMilliseconds;
          final offset = t.difference(minTime).inMilliseconds;
          return (offset / total) * width;
        }

        DateTime toTime(double x) {
          final total = maxTime.difference(minTime).inMilliseconds;
          final ms = (x / width) * total;
          return minTime.add(Duration(milliseconds: ms.round()));
        }

        final left = toX(window.start);
        final right = toX(window.end);

        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            final deltaTime =
              toTime(right + d.delta.dx).difference(toTime(right));

            final newWindow = TimeWindow(
              start: window.start.add(deltaTime),
              end: window.end.add(deltaTime),
            );

            onChanged(newWindow);
          },
          child: Stack(
            children: [
              // FULL BAR BACKGROUND
              Container(
                height: 40,
                color: Colors.grey.shade300,
              ),

              // SELECTION WINDOW
              Positioned(
                left: left,
                top: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    final newStart = toTime(left + d.delta.dx);

                    onChanged(TimeWindow(
                      start: newStart,
                      end: window.end,
                    ));
                  },
                  child: Container(
                    width: right - left,
                    height: 40,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),

              // RIGHT HANDLE
              Positioned(
                left: right - 6,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    final newEnd = toTime(right + d.delta.dx);

                    onChanged(TimeWindow(
                      start: window.start,
                      end: newEnd,
                    ));
                  },
                  child: Container(
                    width: 12,
                    height: 40,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}