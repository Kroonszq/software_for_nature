import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/models/timeline_geometry.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';

class TimelineContent extends StatefulWidget {
  final double minHeight;
  final List<EventPost> listOfEvents;
  final ScrollController? scrollController;
  final DateTime? earliest;
  final Color? groupColor;

  /// MOBILE: When false the column's own horizontal scroll is disabled this is for mobile the user has to click the column first
  final bool enableHorizontalScroll;

  /// Whether to overlay the floating "N events above/below" counters. Disabled
  /// for the small sidebar previews, which should stay uncluttered.
  final bool showOffscreenIndicators;

  const TimelineContent({
    super.key,
    required this.listOfEvents,
    this.earliest,
    this.scrollController,
    this.groupColor,
    this.minHeight = 0,
    this.enableHorizontalScroll = true,
    this.showOffscreenIndicators = true,
  });

  @override
  State<TimelineContent> createState() => _TimelineContentState();
}

class _TimelineContentState extends State<TimelineContent> {
  Map<int, List<EventPost>> listOfRows = {};
  final ScrollController _horizontalScrollController = ScrollController();
  bool _hasExpandedCard = false;

  /// Live vertical scroll metrics for this column, fed from the scroll view's
  /// notifications rather than the scroll controller. The hybrid view recreates
  /// its controllers on every state change, so the controller's attach state is
  /// unreliable at build time; ScrollMetricsNotification fires on layout and is
  /// therefore a dependable signal for "how much is off-screen".
  final ValueNotifier<ScrollMetrics?> _verticalMetrics =
      ValueNotifier<ScrollMetrics?>(null);

  /// The live vertical [ScrollPosition] for this column, resolved from scroll
  /// notifications. Tapping an off-screen counter drives this directly, which
  /// is reliable even when [widget.scrollController] is null or stale (the
  /// hybrid view recreates its controllers on every state change).
  ScrollPosition? _verticalPosition;

  /// Records the latest vertical metrics (for the counters) and resolves the
  /// active scroll position (for tap-to-scroll) from the notification context.
  void _captureVertical(
    ScrollMetrics metrics,
    BuildContext? notificationContext,
  ) {
    if (metrics.axis != Axis.vertical) return;
    _verticalMetrics.value = metrics;
    if (notificationContext != null) {
      _verticalPosition = Scrollable.maybeOf(notificationContext)?.position;
    }
  }

  // The last focus request handled, so a marker hover scrolls this column
  // horizontally to the event only once per request.
  int _lastFocusRequestId = 0;

  @override
  void initState() {
    super.initState();
    calculateRows();
  }

  @override
  void didUpdateWidget(covariant TimelineContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recalculate the row layout when the events change. This must detect more
    // than added/removed ids: editing an event keeps its id but changes its
    // time/title/description, and the rows hold the actual event objects used
    // for both positioning and card content, so a stale signature would leave
    // the column showing the old data.
    final oldSignature = _eventsSignature(oldWidget.listOfEvents);
    final newSignature = _eventsSignature(widget.listOfEvents);

    if (oldSignature != newSignature) {
      listOfRows = {};
      calculateRows();
    }

    // MOBILE: Keep the scroll where the user left it when unfocusing a column on mobile
    if (oldWidget.enableHorizontalScroll != widget.enableHorizontalScroll &&
        _horizontalScrollController.hasClients) {
      final double offset = _horizontalScrollController.offset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_horizontalScrollController.hasClients) {
          return;
        }
        final double max = _horizontalScrollController.position.maxScrollExtent;
        _horizontalScrollController.jumpTo(offset.clamp(0.0, max));
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalMetrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listOfEvents.isEmpty) {
      return Container(
        color: (widget.groupColor ?? Colors.blueGrey).withValues(alpha: 0.75),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No events found',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
      );
    }

    var timelineGeometry = TimelineGeometry.fromEvents(
      widget.listOfEvents,
      earliest: widget.earliest,
    );

    final groupColor =
        widget.listOfEvents.first.category?.color ??
        widget.groupColor ??
        Colors.blue;

    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state is! TimelineInitial) {
          return;
        }

        final selected = state.selectedPost;
        final inThisColumn =
            selected != null &&
            widget.listOfEvents.any((e) => e.id == selected.id);
        _hasExpandedCard = inThisColumn;

        if (inThisColumn && state.focusRequestId != _lastFocusRequestId) {
          _lastFocusRequestId = state.focusRequestId;
          _scrollToEventHorizontally(selected);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Capture vertical scroll metrics for the off-screen counters.
          // ScrollMetricsNotification fires when content/viewport dimensions
          // change (i.e. on layout), and ScrollNotification fires while the
          // user scrolls — together they keep the counters accurate without
          // depending on the scroll controller's transient attach state.
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (n) {
              _captureVertical(n.metrics, n.context);
              return false;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                _captureVertical(n.metrics, n.context);
                return false;
              },
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final scrollHorizontally =
                        HardwareKeyboard.instance.isControlPressed ||
                        _hasExpandedCard;
                    if (scrollHorizontally) {
                      final newOffset =
                          (_horizontalScrollController.offset +
                                  event.scrollDelta.dy)
                              .clamp(
                                0.0,
                                _horizontalScrollController
                                    .position
                                    .maxScrollExtent,
                              );
                      _horizontalScrollController.jumpTo(newOffset);
                    }
                  }
                },
                child: Container(
                  color: groupColor.withValues(alpha: 0.75),
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: widget.enableHorizontalScroll
                              ? null
                              : const NeverScrollableScrollPhysics(),

                          child: SingleChildScrollView(
                            controller: widget.scrollController,
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: widget.minHeight,
                                minWidth: constraints.maxWidth,
                              ),
                              child: BlocBuilder<TimelineBloc, TimelineState>(
                                builder: (context, state) {
                                  final selectedId = state is TimelineInitial
                                      ? state.selectedPost?.id
                                      : null;
                                  final result = _buildCards(
                                    selectedId,
                                    timelineGeometry.earliest,
                                  );

                                  return SizedBox(
                                    height: timelineGeometry.totalHeight + 16,
                                    width: result.contentWidth,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: result.cards,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Floating counters showing how many events sit above/below the
          // current vertical viewport.
          if (widget.showOffscreenIndicators)
            Positioned.fill(
              child: OffscreenEventIndicators(
                metrics: _verticalMetrics,
                resolvePosition: () => _verticalPosition,
                events: widget.listOfEvents,
                earliest: timelineGeometry.earliest,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the positioned event cards for the stack and reports the total
  /// content width. The selected card (if any) is added last so it paints on
  /// top, with a dimming scrim behind it to make it stand out.
  ({List<Widget> cards, double contentWidth}) _buildCards(
    String? selectedId,
    DateTime earliest,
  ) {
    final cards = <Widget>[];
    Widget? selectedCard;
    double contentWidth =
        TimelineConstants.cardWithIncMargins * listOfRows.length;

    // Build rows * columns
    for (var entry in listOfRows.entries) {
      for (final event in entry.value) {
        final card = Positioned(
          key: ValueKey(event.id),
          left: entry.key * TimelineConstants.cardWithIncMargins,
          top:
              event.startDuration.difference(earliest).inMinutes *
              TimelineConstants.pixelsPerMinute,
          child: TimelineEventCard(event: event),
        );

        if (event.id == selectedId) {
          selectedCard = card;
          final expandedRight =
              entry.key * TimelineConstants.cardWithIncMargins +
              TimelineConstants.expandedCardWidth;
          if (expandedRight > contentWidth) {
            contentWidth = expandedRight;
          }
        } else {
          cards.add(card);
        }
      }
    }

    if (selectedCard != null) {
      cards.add(selectedCard);
    }

    return (cards: cards, contentWidth: contentWidth);
  }

  /// A fingerprint of the events that changes whenever any field affecting the
  /// layout or card content changes, so edits (same id, new values) are caught.
  String _eventsSignature(List<EventPost> events) {
    return events
        .map(
          (e) =>
              '${e.id}:${e.startDuration.millisecondsSinceEpoch}:${e.endDuration.millisecondsSinceEpoch}:${e.timestamp?.millisecondsSinceEpoch ?? ''}:${e.title}:${e.description}:${e.categoryId}',
        )
        .join('|');
  }

  void calculateRows() {
    // Sort by start time
    final sorted = [...widget.listOfEvents]
      ..sort((a, b) => a.startDuration.compareTo(b.startDuration));

    for (EventPost event in sorted) {
      bool placed = false;
      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
              event.startDuration.isBefore(existing.endDuration) &&
                  event.endDuration.isAfter(existing.startDuration) ||
              event.startDuration == existing.startDuration,
        );

        if (!overlaps) {
          listOfRows[row]!.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        listOfRows[listOfRows.length] = [event];
      }
    }
  }

  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * TimelineConstants.pixelsPerMinute;
  }

  /// When requested scroll to the event horizontally
  void _scrollToEventHorizontally(EventPost event) {
    int? rowIndex;
    for (final entry in listOfRows.entries) {
      if (entry.value.any((e) => e.id == event.id)) {
        rowIndex = entry.key;
        break;
      }
    }
    if (rowIndex == null) return;

    final double targetLeft = rowIndex * TimelineConstants.cardWithIncMargins;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontalScrollController.hasClients) {
        return;
      }

      final position = _horizontalScrollController.position;

      // Add a little bit off offset
      final double offset = (targetLeft - position.viewportDimension * 0.25)
          .clamp(0.0, position.maxScrollExtent);

      // Scroll to the position
      _horizontalScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }
}

/// Floating counters that sit on top of a timeline column and report how many
/// events are scrolled out of view above and below the current vertical
/// viewport. Tapping a counter scrolls the column toward the nearest
/// off-screen event in that direction.
class OffscreenEventIndicators extends StatelessWidget {
  /// Live vertical scroll metrics for the column, captured from the scroll
  /// view's notifications. This is decoupled from [controller]'s attach state,
  /// which is unreliable because the hybrid view recreates its controllers on
  /// every state change.
  final ValueListenable<ScrollMetrics?> metrics;

  /// Resolves the live vertical scroll position, used to drive [animateTo] when
  /// a badge is tapped. Returns null while the column has no attached viewport.
  final ScrollPosition? Function() resolvePosition;
  final List<EventPost> events;
  final DateTime earliest;

  const OffscreenEventIndicators({
    super.key,
    required this.metrics,
    required this.resolvePosition,
    required this.events,
    required this.earliest,
  });

  /// Vertical pixel offset of an event's top edge within the column content.
  double _eventTop(EventPost event) =>
      event.startDuration.difference(earliest).inMinutes *
      TimelineConstants.pixelsPerMinute;

  /// Vertical pixel offset of an event's bottom edge within the column content.
  double _eventBottom(EventPost event) =>
      event.endDuration.difference(earliest).inMinutes *
      TimelineConstants.pixelsPerMinute;

  /// Scrolls the column so the nearest off-screen event in [downwards]
  /// direction comes into view.
  void _scrollTowards(bool downwards) {
    final position = resolvePosition();
    if (position == null ||
        !position.hasContentDimensions ||
        !position.hasViewportDimension) {
      return;
    }

    final double top = position.pixels;
    final double bottom = top + position.viewportDimension;

    double? target;
    if (downwards) {
      // Closest event whose top sits below the current viewport.
      for (final event in events) {
        final double eTop = _eventTop(event);
        if (eTop > bottom) {
          if (target == null || eTop < target) {
            target = eTop;
          }
        }
      }
      // Land the event a little below the top edge for context.
      target = (target ?? position.maxScrollExtent) - 24;
    } else {
      // Closest event whose bottom sits above the current viewport.
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

/// A small translucent pill showing a direction arrow and an event count.
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
