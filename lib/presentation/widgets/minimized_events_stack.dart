import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';

/// A vertical stack of minimized events
class MinimizedEventsStack extends StatelessWidget {
  const MinimizedEventsStack({super.key});

  static const double width = 52;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventInteractionCubit, EventInteractionState>(
      builder: (context, state) {
        final events = state.minimizedEvents;

        if (events.isEmpty) return const SizedBox.shrink();

        return Container(
          width: 52,
          color: Colors.blueGrey.shade50,
          child: Column(
            children: [
              for (final event in events)
                Expanded(
                  child: MinimizedStackItem(event: event),
                ),
            ],
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
        return Material(
          color: Colors.blue.shade100,
          child: InkWell(
            onTap: () {
              context.read<EventInteractionCubit>().restore(event);
              Scaffold.of(context).openDrawer();
            },
            child: Stack(
              children: [
                Center(
                  child: Text(
                    event.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    iconSize: 12,
                    padding: EdgeInsets.zero,
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
        );
      },
    );
  }
}
