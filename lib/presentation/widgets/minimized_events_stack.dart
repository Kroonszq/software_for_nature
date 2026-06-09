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
  const MinimizedEventsStack({super.key});

  /// Deterimines the width of a the stack item
  static const double width = 52;

  /// Determines how much stack items are max visable upon a time
  static const int maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MinimizedEventsBloc, MinimizedEventsState>(
      builder: (context, state) {
        final events = state.minimized;

        // If there are no events do not display it
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: width,
          color: Colors.blueGrey.shade50,
          child: LayoutBuilder(
            builder: (context, constraints) {

              // If the event are under 5 items share the height between the items
              if (events.length <= maxVisible) {
                return Column(
                  children: [
                    for (final event in events)
                      Expanded(child: _MinimizedStackItem(event: event)),
                  ],
                );
              }

              // If there are more then 5 items give each item a fixed height
              final chipHeight = constraints.maxHeight / maxVisible;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (final event in events)
                      SizedBox(
                        height: chipHeight,
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
