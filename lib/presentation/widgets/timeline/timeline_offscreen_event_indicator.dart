
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';

class OffscreenEventIndicators extends StatelessWidget {
  final ValueListenable<ScrollMetrics?> metrics;
  final ScrollPosition? Function() resolvePosition;
  final List<EventPost> events;
  final DateTime earliest;

  const OffscreenEventIndicators({super.key, required this.metrics, required this.resolvePosition, required this.events, required this.earliest});

  double _eventTop(EventPost event) => event.startDuration.difference(earliest).inMinutes * TimelineConstants.pixelsPerMinute;
  double _eventBottom(EventPost event) => event.endDuration.difference(earliest).inMinutes * TimelineConstants.pixelsPerMinute;


  void _scrollTowards(bool downwards) {
    final position = resolvePosition();
    if (position == null || !position.hasContentDimensions || !position.hasViewportDimension) {
      return;
    }

    final double top = position.pixels;
    final double bottom = top + position.viewportDimension;

    double? target;
    if (downwards) {
      // closest event whose top sits below the current viewport
      for (final event in events) {
        final double eTop = _eventTop(event);
        if (eTop > bottom) {
          if (target == null || eTop < target) {
            target = eTop;
          }
        }
      }

      target = (target ?? position.maxScrollExtent) - 24;
    } else {
      // closest event whose bottom sits above the current viewport
      for (final event in events) {
        final double eBottom = _eventBottom(event);
        if (eBottom < top) {
          if (target == null || eBottom > target) {
            target = eBottom;
          }
        }
      }
      target = (target ?? 0) - position.viewportDimension + 24;
    }

    position.animateTo(
      target.clamp(0.0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScrollMetrics?>(
      valueListenable: metrics,
      builder: (context, m, _) {
        if (m == null || !m.hasViewportDimension || !m.hasContentDimensions) {
          return const SizedBox.shrink();
        }

        final double top = m.pixels;
        final double bottom = top + m.viewportDimension;

        int above = 0;
        int below = 0;
        for (final event in events) {
          if (_eventBottom(event) < top) {
            above++;
          } else if (_eventTop(event) > bottom) {
            below++;
          }
        }

        if (above == 0 && below == 0) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            if (above > 0)
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: _OffscreenBadge(
                    count: above,
                    downwards: false,
                    onTap: () => _scrollTowards(false),
                  ),
                ),
              ),
            if (below > 0)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: _OffscreenBadge(
                    count: below,
                    downwards: true,
                    onTap: () => _scrollTowards(true),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OffscreenBadge extends StatelessWidget {
  final int count;
  final bool downwards;
  final VoidCallback onTap;

  const _OffscreenBadge({
    required this.count,
    required this.downwards,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                downwards ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$count event${count == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
