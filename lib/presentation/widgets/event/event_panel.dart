import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';
import 'package:software_for_nature/presentation/widgets/event/drawer/event_comments.dart';
import 'package:software_for_nature/presentation/widgets/event/drawer/event_content.dart';
import 'package:software_for_nature/presentation/widgets/event/event_edit_drawer.dart';

/// Which section of the panel is currently visible.
enum _PanelTab { content, comments }

/// A single panel shown in the drawer, displaying the full details of an event
class EventPanel extends StatefulWidget {
  final EventPost event;

  const EventPanel({super.key, required this.event});

  @override
  State<EventPanel> createState() => _EventPanelState();
}

class _EventPanelState extends State<EventPanel> {
  _PanelTab _tab = _PanelTab.content;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await context.read<UserServiceInterface>().getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  /// True when the signed-in user authored this event and may edit it.
  bool get _isAuthor =>
      _currentUser != null && _currentUser!.id == widget.event.userId;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0x22000000))),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildCategoryAndTags(event),

              const SizedBox(height: 12),

              BlocBuilder<HybridBloc, HybridState>(
                builder: (context, state) {
                  return _buildTimelineSummary(event, state.timeRange);
                },
              ),

              const SizedBox(height: 16),

              _buildMetadataRow('Created', TimeUtils.formatDateTime(event.createdAt)),
              _buildMetadataRow('Author', event.user?.name ?? ''),
              _buildMetadataRow('Event ID', event.id),
              if (event.coordinates != null)
                _buildMetadataRow(
                  'Location',
                  '${event.coordinates!.lat.toStringAsFixed(4)}, ${event.coordinates!.lng.toStringAsFixed(4)}',
                ),

              const SizedBox(height: 12),

              SegmentedButton<_PanelTab>(
                segments: _buildTabSegments(context),
                selected: {_tab},
                onSelectionChanged: (selection) {
                  setState(() => _tab = selection.first);
                },
              ),

              const SizedBox(height: 12),

              _tab == _PanelTab.content
                  ? EventContent(event: event)
                  : EventComments(eventId: event.id),

              const SizedBox(height: 12),

              _buildActionButtons(context, event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryAndTags(EventPost event) {
    final category = event.category;

    final categoryChip = category != null
        ? Chip(
            label: Text(
              category.name,
              style: TextStyle(
                color: ThemeData.estimateBrightnessForColor(category.color) == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: category.color.withValues(alpha: 0.9),
          )
        : null;

    final tagChips = event.tags.map(_buildTagChip).toList();

    if (categoryChip == null && tagChips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categoryChip != null) ...[
          const Text('Category', style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          categoryChip,
          if (tagChips.isNotEmpty) const SizedBox(height: 14),
        ],
        if (tagChips.isNotEmpty) ...[
          const Text('Tags', style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tagChips,
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(Tag tag) {
    final labelColor = ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Chip(
      label: Text(tag.label, style: TextStyle(color: labelColor)),
      backgroundColor: tag.color.withValues(alpha: 0.9),
    );
  }

  Widget _buildTimelineSummary(EventPost event, DateTimeRange? timeRange) {
    final eventDuration = event.endDuration.difference(event.startDuration);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timing', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildMetadataRow('Start', TimeUtils.formatDateTime(event.startDuration)),
          _buildMetadataRow('End', TimeUtils.formatDateTime(event.endDuration)),
          _buildMetadataRow('Duration', TimeUtils.formatDuration(eventDuration)),
          _buildMetadataRow(
            'Timestamp',
            event.timestamp != null
                ? TimeUtils.formatDateTime(event.timestamp!)
                : '—',
          ),
          const SizedBox(height: 8),
          _EventTimelineBar(event: event, timeRange: timeRange),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EventPost event) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Row(
      children: [
        if (_isAuthor) ...[
          if (isSmallScreen)
            IconButton.filled(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () {
                openEventEditor(context, event);
                context.read<EventInteractionCubit>().dismiss(event);
              },
            )
          else
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () {
                  openEventEditor(context, event);
                  context.read<EventInteractionCubit>().dismiss(event);
                },
              ),
            ),
          const SizedBox(width: 8),
        ],
        if (isSmallScreen)
          IconButton.filled(
            icon: const Icon(Icons.minimize),
            tooltip: 'Minimize',
            onPressed: () {
              context.read<EventInteractionCubit>().minimize(event);
            },
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.minimize),
              label: const Text('Minimize'),
              onPressed: () {
                context.read<EventInteractionCubit>().minimize(event);
              },
            ),
          ),
        const SizedBox(width: 8),
        if (isSmallScreen)
          IconButton.outlined(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              context.read<EventInteractionCubit>().dismiss(event);
            },
          )
        else
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              onPressed: () {
                context.read<EventInteractionCubit>().dismiss(event);
              },
            ),
          ),
      ],
    );
  }

  List<ButtonSegment<_PanelTab>> _buildTabSegments(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return [
      ButtonSegment(
        value: _PanelTab.content,
        icon: const Icon(Icons.article_outlined),
        label: isSmallScreen ? null : const Text('Content'),
      ),
      ButtonSegment(
        value: _PanelTab.comments,
        icon: const Icon(Icons.mode_comment_outlined),
        label: isSmallScreen ? null : const Text('Comments'),
      ),
    ];
  }
}

class _EventTimelineBar extends StatelessWidget {
  final EventPost event;
  final DateTimeRange? timeRange;

  const _EventTimelineBar({required this.event, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    final range = timeRange ?? DateTimeRange(start: event.startDuration, end: event.endDuration);
    final totalSeconds = math.max(range.duration.inSeconds, 1).toDouble();

    final eventStart = event.startDuration.isBefore(range.start)
        ? 0.0
        : event.startDuration.difference(range.start).inSeconds / totalSeconds;
    final eventEnd = event.endDuration.isAfter(range.end)
        ? 1.0
        : event.endDuration.difference(range.start).inSeconds / totalSeconds;
    final eventWidth = math.min(math.max(eventEnd - eventStart, 0.0), 1.0);

    const legHeight = 16.0;
    const barHeight = 14.0;
    const labelSpacing = 4.0;
    const outsideLabelPadding = 8.0;
    const labelStyle = TextStyle(fontSize: 10, color: Colors.black87);
    final startLabel = TimeUtils.formatDateTime(event.startDuration);
    final endLabel = TimeUtils.formatDateTime(event.endDuration);

    Size measureTextSize(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return painter.size;
    }

    final startLabelSize = measureTextSize(startLabel, labelStyle);
    final endLabelSize = measureTextSize(endLabel, labelStyle);
    final startLabelWidth = startLabelSize.width;
    final endLabelWidth = endLabelSize.width;
    final labelHeight = math.max(startLabelSize.height, endLabelSize.height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final left = constraints.maxWidth * eventStart;
        final width = constraints.maxWidth * eventWidth;
        final barWidth = width > 12 ? width : 12.0;
        final xStart = math.max(0.0, math.min(left, constraints.maxWidth - barWidth));
        final xEnd = xStart + barWidth;

        final startOutsideLeft = xStart - startLabelWidth - outsideLabelPadding;
        final startInsideLeft = xStart + outsideLabelPadding;
        final startLeftOutside = startOutsideLeft >= 0;
        final startLeft = startLeftOutside
            ? startOutsideLeft
            : math.min(constraints.maxWidth - startLabelWidth, startInsideLeft);

        final endOutsideLeft = xEnd + outsideLabelPadding;
        final endInsideLeft = xEnd - endLabelWidth - outsideLabelPadding;
        final endLeftOutside = endOutsideLeft + endLabelWidth <= constraints.maxWidth;
        final endLeft = endLeftOutside
            ? math.min(constraints.maxWidth - endLabelWidth, endOutsideLeft)
            : math.max(0.0, endInsideLeft);

        final labelOverlap = endLeft < startLeft + startLabelWidth + 4;
        final topPadding = labelOverlap ? labelHeight + 8.0 : 0.0;
        final startTop = topPadding;
        final endTop = labelOverlap ? topPadding - (labelHeight + 8.0) : 0.0;
        final barTop = labelHeight + legHeight + topPadding;

        final startLineHeight = barTop - (startTop + labelHeight + labelSpacing);
        final endLineHeight = barTop - (endTop + labelHeight + labelSpacing);

        return SizedBox(
          height: barTop + barHeight + 28.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: barTop,
                left: 0,
                right: 0,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned(
                top: barTop,
                left: xStart,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: _TimelineLegLabel(
                  maxWidth: constraints.maxWidth,
                  xPosition: xStart,
                  isStart: true,
                  label: startLabel,
                  lineHeight: startLineHeight,
                  labelLeft: startLeft,
                  labelWidth: startLabelWidth,
                  labelTop: startTop,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: _TimelineLegLabel(
                  maxWidth: constraints.maxWidth,
                  xPosition: xEnd,
                  isStart: false,
                  label: endLabel,
                  lineHeight: endLineHeight,
                  labelLeft: endLeft,
                  labelWidth: endLabelWidth,
                  labelTop: endTop,
                ),
              ),
              Positioned(
                top: barTop + barHeight + 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TimeUtils.formatDateTime(range.start),
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    Text(
                      TimeUtils.formatDateTime(range.end),
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineLegLabel extends StatelessWidget {
  final double maxWidth;
  final double xPosition;
  final bool isStart;
  final String label;
  final double labelLeft;
  final double labelWidth;
  final double lineHeight;
  final double labelTop;

  const _TimelineLegLabel({
    required this.maxWidth,
    required this.xPosition,
    required this.isStart,
    required this.label,
    required this.labelLeft,
    required this.labelWidth,
    required this.lineHeight,
    required this.labelTop,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 4.0;
    const lineThickness = 2.0;
    final textStyle = const TextStyle(fontSize: 10, color: Colors.black87);

    final painter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final textHeight = painter.size.height;

    return SizedBox(
      width: maxWidth,
      height: textHeight + spacing + lineHeight + labelTop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: labelLeft,
            top: labelTop,
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
          Positioned(
            left: math.max(0.0, xPosition - (lineThickness / 2)),
            top: labelTop + textHeight + spacing,
            child: Container(
              width: lineThickness,
              height: lineHeight,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}





