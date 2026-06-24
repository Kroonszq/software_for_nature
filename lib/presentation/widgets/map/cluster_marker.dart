import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/time_window.dart';

const double _bubbleSize = 44;
const double _startAngle = -math.pi / 2; // 24 uur klok

class ClusterMarker extends StatelessWidget {
  final int count;
  final List<EventPost> events;
  final TimeWindow timeWindow;
  final Map<String, Color> categoryColors;

  const ClusterMarker({super.key, required this.count, required this.events, required this.timeWindow, this.categoryColors = const {}});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _CategoryPie(count: count, slices: const []);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ClusterBar(span: _spanInWindow()),
        _CategoryPie(count: count, slices: _slices()),
      ],
    );
  }

  List<_CategorySlice> _slices() {
    final counts = <String, int>{};
    for (final event in events) {
      counts.update(event.categoryId, (n) => n + 1, ifAbsent: () => 1);
    }

    return [
      for (final entry in counts.entries)
        _CategorySlice(
          color: categoryColors[entry.key] ?? Colors.blue,
          count: entry.value,
        ),
    ];
  }

  /// The portion of the visible time window this cluster spans, as left/width
  ({double left, double width}) _spanInWindow() {
    final earliest = events.map((e) => e.startDuration).reduce(_earlier);
    final latest = events.map((e) => e.endDuration).reduce(_later);

    final start = _later(earliest, timeWindow.start);
    final end = _earlier(latest, timeWindow.end);

    final totalMs = timeWindow.duration.inMilliseconds;
    final left = start.difference(timeWindow.start).inMilliseconds / totalMs;
    final width = end.difference(start).inMilliseconds / totalMs;

    return (left: left.clamp(0.0, 1.0), width: width.clamp(0.0, 1.0));
  }
}

DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
DateTime _later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

class _CategorySlice {
  final Color color;
  final int count;

  const _CategorySlice({required this.color, required this.count});
}

/// A pie chart of the cluster's categories with the event count in the centre
class _CategoryPie extends StatelessWidget {
  final int count;
  final List<_CategorySlice> slices;

  const _CategoryPie({required this.count, required this.slices});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _bubbleSize,
      height: _bubbleSize,
      child: CustomPaint(
        painter: _PiePainter(slices),
        child: Center(
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<_CategorySlice> slices;

  const _PiePainter(this.slices);

  int get _total => slices.fold(0, (sum, s) => sum + s.count);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    _paintWedges(canvas, center, radius);

    // make background dark so we can still read it
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()..color = const Color(0xCC1A1A1A),
    );

    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _paintWedges(Canvas canvas, Offset center, double radius) {
    final total = _total;

    if (slices.isEmpty || total == 0) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.blue);
      return;
    }
    if (slices.length == 1) {
      canvas.drawCircle(center, radius, Paint()..color = slices.first.color);
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    var angle = _startAngle;
    for (final slice in slices) {
      final sweep = _sweepOf(slice, total);
      canvas.drawArc(rect, angle, sweep, true, Paint()..color = slice.color);
      angle += sweep;
    }

    _paintSeparators(canvas, center, radius, total);
  }

  void _paintSeparators(Canvas canvas, Offset center, double radius, int total) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    var angle = _startAngle;
    for (final slice in slices) {
      final edge = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center, edge, paint);
      angle += _sweepOf(slice, total);
    }
  }

  double _sweepOf(_CategorySlice slice, int total) =>
      slice.count / total * 2 * math.pi;

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}

class _ClusterBar extends StatelessWidget {
  final ({double left, double width}) span;

  const _ClusterBar({required this.span});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _bubbleSize,
      height: 4,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: _bubbleSize * span.left,
            width: _bubbleSize * span.width,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
