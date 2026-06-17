import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/minimized_events/minimized_events_bloc.dart';

/// A vertical stack of minimized events
///
/// The class uses [MinimizedEventsBloc] to deterimine what events to show
/// And what the state of the events are
///
class MinimizedEventsStack extends StatelessWidget {
  /// The direction the events are stacked in. Vertical is used for the desktop
  /// left rail, horizontal for the mobile bottom bar.
  final Axis axis;

  const MinimizedEventsStack({super.key, this.axis = Axis.vertical});

  /// Deterimines the thickness (width when vertical / height when horizontal)
  /// of the stack.
  static const double width = 52;

  /// Determines how much stack items are max visable upon a time on the
  /// vertical desktop rail.
  static const int maxVisible = 5;

  /// Determines how many stack items are visible at once on the horizontal
  /// mobile bar before it starts scrolling.
  static const int maxVisibleHorizontal = 3;

  @override
  Widget build(BuildContext context) {
    final bool isHorizontal = axis == Axis.horizontal;
    final int maxVisibleItems = isHorizontal ? maxVisibleHorizontal : maxVisible;

    return BlocBuilder<MinimizedEventsBloc, MinimizedEventsState>(
      builder: (context, state) {
        final events = state.minimized;

        // If there are no events do not display it
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: isHorizontal ? double.infinity : width,
          height: isHorizontal ? width : null,
          color: Colors.blueGrey.shade50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // If the events are under the max share the available space
              // evenly between the items.
              if (events.length <= maxVisibleItems) {
                return Flex(
                  direction: axis,
                  children: [
                    for (final event in events)
                      Expanded(child: _MinimizedStackItem(event: event)),
                  ],
                );
              }

              // Otherwise give each item a fixed extent and allow scrolling.
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
                        child: _MinimizedStackItem(event: event),
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

class _MinimizedStackItem extends StatelessWidget {
  final EventPost event;

  const _MinimizedStackItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Tooltip(
        message: event.title,
        child: Material(
          color: Colors.blue.shade100,
          child: InkWell(
            onTap: () {
              context.read<MinimizedEventsBloc>().add(OpenEvent(event));
              Scaffold.of(context).openDrawer();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        event.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    iconSize: 12,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context
                          .read<MinimizedEventsBloc>()
                          .add(CloseEvent(event));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
