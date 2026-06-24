import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/core/utils/attachment_service.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';

class TimelineEventCard extends StatelessWidget {
  final EventPost event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state is! TimelineInitial) {
          return SizedBox(
            width: 100,
            height: getHeight(event),
          );
        }

        if (event.isMoment) {
          return _buildMoment(
            context,
            highlighted: state.selectedPost?.id == event.id,
          );
        }

        final isExpanded = state.selectedPost?.id == event.id;
        final collapsedHeight = getHeight(event);
        final rawHeight = getRawHeight(event);
        final isClamped = !isExpanded && rawHeight < collapsedHeight;

        // when expanded expand big enough to fit the extra details
        var expandedMinHeight = 220.0;
        if (_firstImageAttachment != null) {
          expandedMinHeight += 100.0;
        }

        if (event.tags.isNotEmpty) {
          expandedMinHeight += 40.0;
        }
        
        final height = isExpanded && collapsedHeight < expandedMinHeight
            ? expandedMinHeight
            : collapsedHeight;

        return Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: 30, // padding so we dont ruin the bottom scrollbar :)
          ),
          child: MouseRegion(
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: InkWell(
              onTap: () {
                context.read<EventInteractionCubit>().select(event);
                Scaffold.of(context).openDrawer();
              },
              onHover: (isHovering) {
                if (isHovering) {
                  context.read<TimelineBloc>().add(SelectTimelineEvent(event));
                } else {
                  context.read<TimelineBloc>().add(UnSelectTimelineEvent());
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? Colors.blue.shade100
                      : Colors.white,
                  border: Border.all(color: Colors.blue),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                width: isExpanded ? 280 : 100,
                height: height,

                child: Stack(
                  children: [
                    if (isClamped)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: rawHeight,
                        child: Container(
                          color: Colors.blue.withValues(alpha: 0.18),
                        ),
                      ),
                    Positioned.fill(
                      child: Column(
                        children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event title
                              Text(
                                event.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Event start time
                              Text(
                                'Start: ${TimeUtils.formatDateTime(event.startDuration)}',
                                style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.blue.shade900
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Event end time
                              Text(
                                'End: ${TimeUtils.formatDateTime(event.endDuration)}',
                                style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.blue.shade900
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isExpanded) 
                                ..._buildDetails(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tags pinned to the bottom of the card, each drawn with a
                    // stroke in its own colour.
                    if (event.tags.isNotEmpty) _TagStrip(tags: event.tags),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The first image attachment on this event, or null if there is none.
  EventAttachment? get _firstImageAttachment {
    for (final attachment in event.attachments) {
      if (AttachmentService.kindOf(attachment) == AttachmentKind.image) {
        return attachment;
      }
    }
    return null;
  }

  List<Widget> _buildDetails() {
    final image = _firstImageAttachment;
    return [
      const SizedBox(height: 6),
      Divider(height: 1, color: Colors.blue.shade200),
      const SizedBox(height: 6),
      if (image != null) ...[
        _HoverImagePreview(attachment: image),
        const SizedBox(height: 6),
      ],
      Text(
        'Category: ${event.category?.name ?? 'Uncategorized'}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade900),
          overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      Text(
        'Duration: '
        '${TimeUtils.formatDuration(event.endDuration.difference(event.startDuration))}',
        style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
        overflow: TextOverflow.ellipsis,
      ),
      if (event.coordinates != null) ...[
        const SizedBox(height: 2),
        Text(
          'Location: ${event.coordinates!.lat.toStringAsFixed(4)}, '
          '${event.coordinates!.lng.toStringAsFixed(4)}',
          style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 4),
      Text(
        event.description,
        style: const TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
        maxLines: 6,
      ),
      if (event.tags.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: event.tags.map((t) => _TagChip(tag: t)).toList(),
        ),
      ],
    ];
  }

  double getRawHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * TimelineConstants.pixelsPerMinute;
  }

  double getHeight(EventPost event) {
    if (event.isMoment) {
      return TimelineConstants.timestampEventHeigt;
    }

    final rawHeight = getRawHeight(event);

    return rawHeight < TimelineConstants.minEventHeight
        ? TimelineConstants.minEventHeight
        : rawHeight;
  }

  Widget _buildMoment(BuildContext context, {required bool highlighted}) {
    final Color orange = Colors.orange.shade800;
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 30),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.deferToChild,
        child: InkWell(
          onTap: () {
            context.read<EventInteractionCubit>().select(event);
            Scaffold.of(context).openDrawer();
          },
          onHover: (isHovering) {
            if (isHovering) {
              context.read<TimelineBloc>().add(SelectTimelineEvent(event));
            } else {
              context.read<TimelineBloc>().add(UnSelectTimelineEvent());
            }
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: highlighted ? 280 : 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: orange,
                // Fully rounded ends make the container a horizontal oval.
                borderRadius: BorderRadius.circular(TimelineConstants.timestampEventHeigt),
              ),
              child: Text(
                event.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _HoverImagePreview extends StatelessWidget {
  final EventAttachment attachment;

  const _HoverImagePreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: AttachmentService.resolveFile(attachment),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            file,
            height: 90,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
      ? Colors.white
      : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}


class _TagStrip extends StatelessWidget {
  final List<Tag> tags;

  const _TagStrip({required this.tags});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: tags.map((t) => Expanded(child: _TagSegment(tag: t))).toList(),
      ),
    );
  }
}

class _TagSegment extends StatelessWidget {
  final Tag tag;

  const _TagSegment({required this.tag});

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
      ? Colors.white
      : Colors.black87;

    return Container(
      height: 16,
      alignment: Alignment.center,
      color: tag.color,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        tag.label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}