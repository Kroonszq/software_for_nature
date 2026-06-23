import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
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

        // When expanded expand big enough to fit the extra details
        final height = isExpanded && collapsedHeight < 220 ? 220.0 : collapsedHeight;

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
                    // Honest duration cue: only the top `rawHeight` slice
                    // represents the event's real length; the rest of the card
                    // is extra room added so the label stays readable.
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

  List<Widget> _buildDetails() {
    return [
      const SizedBox(height: 6),
      Divider(height: 1, color: Colors.blue.shade200),
      const SizedBox(height: 6),
      Text(
        'Category: ${event.category?.name ?? 'Uncategorized'}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade900),
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
    ];
  }

  /// The event's true-to-scale height, straight from its duration.
  double getRawHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * TimelineConstants.pixelsPerMinute;
  }

  double getHeight(EventPost event) {
    if (event.isMoment) {
      return TimelineConstants.timestampEventHeigt;
    }

    final rawHeight = getRawHeight(event);

    // Clamp short events up so they stay readable instead of rendering as a
    // tiny stroke.
    return rawHeight < TimelineConstants.minEventHeight
        ? TimelineConstants.minEventHeight
        : rawHeight;
  }

  /// Builds a "moment/timestamp" event
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

/// Renders an event's tags as a full-width bar at the bottom of the card. The
/// bar is split into equal segments, one per tag, each filled with the tag's
/// own colour and labelled.
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

/// One coloured segment of the full-width tag bar.
class _TagSegment extends StatelessWidget {
  final Tag tag;

  const _TagSegment({required this.tag});

  @override
  Widget build(BuildContext context) {
    // Pick a readable text colour for the segment's fill.
    final textColor =
        ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
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