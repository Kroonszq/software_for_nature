import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';

/// A single panel/box shown in the drawer
class EventPanel extends StatelessWidget {
  final EventPost event;

  const EventPanel({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0x22000000))),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Group: ${event.group.title}'),
          const SizedBox(height: 4),
          Text('Start: ${_formatDateTime(event.startDuration)}'),
          Text('End: ${_formatDateTime(event.endDuration)}'),
          if (event.coordinates != null) ...[
            const SizedBox(height: 4),
            Text(
              'Location: ${event.coordinates!.lat.toStringAsFixed(4)}, '
              '${event.coordinates!.lng.toStringAsFixed(4)}',
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(event.description),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.minimize),
                  label: const Text('Minimize'),
                  onPressed: () {
                    context
                      .read<EventInteractionCubit>()
                      .minimize(event);
                    // context
                    //   .read<EventInteractionCubit>()
                    //   .minimizeAllIfNeeded();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  onPressed: () {
                    context
                      .read<EventInteractionCubit>()
                     .dismiss(event);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
