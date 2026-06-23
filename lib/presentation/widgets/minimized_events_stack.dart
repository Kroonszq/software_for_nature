import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';

class MinimizedEventsStack extends StatelessWidget {
  /// The direction the events are stacked in. vertical is used for the desktop horizontal for mobile
  final Axis axis;

  const MinimizedEventsStack({super.key, this.axis = Axis.vertical});

  /// Deterimines the thickness (width when vertical / height when horizontal) of stack
  static const double width = 52;

  /// DESKTOP: Determines how much stack items are max visable upon a time on the
  static const int maxVisible = 5;

  /// MOBILE: Determines how many stack items are visible at once on the horizontal
  static const int maxVisibleHorizontal = 3;

  @override
  Widget build(BuildContext context) {
    final bool isHorizontal = axis == Axis.horizontal;
    final int maxVisibleItems = isHorizontal ? maxVisibleHorizontal : maxVisible;

    return BlocBuilder<EventInteractionCubit, EventInteractionState>(
      builder: (context, state) {
        final events = state.minimizedEvents;

        if (events.isEmpty) return const SizedBox.shrink();

        return Container(
          width: isHorizontal ? double.infinity : width,
          height: isHorizontal ? width : null,
          color: Colors.blueGrey.shade50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // If the events are under the max share the available space evenly between the items.
              if (events.length <= maxVisibleItems) {
                return Flex(
                  direction: axis,
                  children: [
                    for (final event in events)
                      Expanded(child: MinimizedStackItem(event: event)),
                  ],
                );
              }

              // Otherwise give each item a fixed extent and allow scrolling
              final double chipExtent = isHorizontal
                  ? constraints.maxWidth / maxVisibleItems
                  : constraints.maxHeight / maxVisibleItems;

              return SingleChildScrollView(
                scrollDirection: axis,
                child: Flex(
                  direction: axis,
                  children: [
                    for (final event in events)
                      SizedBox(
                        width: isHorizontal ? chipExtent : null,
                        height: isHorizontal ? null : chipExtent,
                        child: MinimizedStackItem(event: event),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MinimizedStackItem extends StatelessWidget {
  final EventPost event;

  const MinimizedStackItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventInteractionCubit, EventInteractionState>(
      builder: (context, state) {
        final Color groupColor = event.category?.color ?? Colors.blue.shade100;
        final Color textColor = ThemeData.estimateBrightnessForColor(groupColor) == Brightness.dark
          ? Colors.white
          : Colors.black87;

        return Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: groupColor,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.read<EventInteractionCubit>().restore(event);
                Scaffold.of(context).openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        event.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 8, color: textColor),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        iconSize: 12,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: textColor,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          context
                              .read<EventInteractionCubit>()
                              .dismiss(event);
                        },
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
}
