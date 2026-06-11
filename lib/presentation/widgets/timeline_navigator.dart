import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/time_window.dart';

class TimelineNavigator extends StatefulWidget {
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
  State<TimelineNavigator> createState() => _TimelineNavigatorState();
}

class _TimelineNavigatorState extends State<TimelineNavigator> {
  static const double height = 50;

  double? _dragStartX;
  double? _startLeft;
  double? _startRight;

  double _toX(DateTime t, double width) {
    final total =
        widget.maxTime.difference(widget.minTime).inMilliseconds;
    if (total == 0) return 0;

    final offset = t.difference(widget.minTime).inMilliseconds;
    return (offset / total) * width;
  }

  DateTime _toTime(double x, double width) {
    final total =
        widget.maxTime.difference(widget.minTime).inMilliseconds;
    if (total == 0) return widget.minTime;

    final ms = (x / width) * total;
    return widget.minTime.add(Duration(milliseconds: ms.round()));
  }

  TimeWindow _zoom(TimeWindow w, double factor) {
    final center =
        w.start.add(w.end.difference(w.start) ~/ 2);

    final halfStart = center.difference(w.start).inMilliseconds;
    final halfEnd = w.end.difference(center).inMilliseconds;

    final newStart = center.subtract(
      Duration(milliseconds: (halfStart * factor).round()),
    );

    final newEnd = center.add(
      Duration(milliseconds: (halfEnd * factor).round()),
    );

    return TimeWindow(start: newStart, end: newEnd);
  }

  void _onZoom(double factor) {
    final newWindow = _zoom(widget.window, factor);

    widget.onChanged(_clampWindow(newWindow));
  }

  TimeWindow _clampWindow(TimeWindow w) {
    final min = widget.minTime;
    final max = widget.maxTime;

    DateTime start = w.start;
    DateTime end = w.end;

    if (start.isBefore(min)) {
      final shift = min.difference(start);
      start = min;
      end = end.add(shift);
    }

    if (end.isAfter(max)) {
      final shift = end.difference(max);
      end = max;
      start = start.subtract(shift);
    }

    return TimeWindow(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final left =
            _toX(widget.window.start, width).clamp(0.0, width);
        final right =
            _toX(widget.window.end, width).clamp(0.0, width);
        final range = (right - left).clamp(0.0, width);

        return Listener(
          // WHEEL ZOOM (WEB/DESKTOP)
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final zoomFactor =
                  event.scrollDelta.dy > 0 ? 1.1 : 0.9;

              _onZoom(zoomFactor);
            }
          },

          child: GestureDetector(
            // PINCH ZOOM (MOBILE)
            onScaleStart: (d) {
              _dragStartX = d.focalPoint.dx;
              _startLeft = left;
              _startRight = right;
            },

            onScaleUpdate: (d) {
              // pinch zoom
              if (d.scale != 1.0) {
                final factor = 1 / d.scale;
                _onZoom(factor);
                return;
              }

              // fallback drag move
              final dx = d.focalPoint.dx - (_dragStartX ?? 0);

              final newLeft =
                  (_startLeft! + dx).clamp(0.0, width);
              final newRight =
                  (_startRight! + dx).clamp(0.0, width);

              widget.onChanged(
                TimeWindow(
                  start: _toTime(newLeft, width),
                  end: _toTime(newRight, width),
                ),
              );
            },

            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // BACKGROUND
                  Container(
                    width: width,
                    height: height,
                    color: Colors.grey.shade300,
                  ),

                  // SELECTION BAR
                  Positioned(
                    left: left,
                    top: 0,
                    child: Container(
                      width: range,
                      height: height,
                      color: Colors.blue.withOpacity(0.25),
                    ),
                  ),

                  // MOVE AREA
                  Positioned(
                    left: left,
                    top: 0,
                    child: Container(
                      width: range,
                      height: height,
                      color: Colors.transparent,
                    ),
                  ),

                  // LEFT HANDLE
                  Positioned(
                    left: left - 8,
                    top: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (d) {
                        _dragStartX = d.globalPosition.dx;
                        _startLeft = left;
                      },
                      onHorizontalDragUpdate: (d) {
                        final dx =
                            d.globalPosition.dx - _dragStartX!;

                        final newLeft =
                            (_startLeft! + dx)
                                .clamp(0.0, right - 1);

                        widget.onChanged(
                          TimeWindow(
                            start: _toTime(newLeft, width),
                            end: widget.window.end,
                          ),
                        );
                      },
                      child: Container(
                        width: 16,
                        height: height,
                        color: Colors.blue.withOpacity(0.85),
                        child: const Icon(Icons.drag_handle, size: 10),
                      ),
                    ),
                  ),

                  // RIGHT HANDLE
                  Positioned(
                    left: right - 8,
                    top: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (d) {
                        _dragStartX = d.globalPosition.dx;
                        _startRight = right;
                      },
                      onHorizontalDragUpdate: (d) {
                        final dx =
                            d.globalPosition.dx - _dragStartX!;

                        final newRight =
                            (_startRight! + dx)
                                .clamp(left + 1, width);

                        widget.onChanged(
                          TimeWindow(
                            start: widget.window.start,
                            end: _toTime(newRight, width),
                          ),
                        );
                      },
                      child: Container(
                        width: 16,
                        height: height,
                        color: Colors.blue.withOpacity(0.85),
                        child: const Icon(Icons.drag_handle, size: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}