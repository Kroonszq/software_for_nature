import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/user.dart';
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

    // This should be shown always under the title
    var coreMetaData = {
      'Category': event.category?.name ?? 'Uncategorized',
      'Created at': TimeUtils.formatDateTime(event.createdAt),
      'Author': event.user?.name ?? '',
      'Event id': event.id,
      'Start': TimeUtils.formatDateTime(event.startDuration),
      'End': TimeUtils.formatDateTime(event.endDuration),
      'Duration': TimeUtils.formatDuration(event.endDuration.difference(event.startDuration)),
      if (event.coordinates != null)
        'Location':
            '${event.coordinates!.lat.toStringAsFixed(4)}, ${event.coordinates!.lng.toStringAsFixed(4)}',
    };

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0x22000000))),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Event Title
          Text(
            event.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          /// Event Meta data
          Column(
            children: [
              for (var metaDataKey in coreMetaData.keys) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Text(metaDataKey, style: const TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(coreMetaData[metaDataKey].toString(), style: const TextStyle(fontWeight: FontWeight.w500))
                    )
                  ],
                ),
              ]
            ],
          ),
          const SizedBox(height: 12),

          /// Tabs buttons for content/comments
          SegmentedButton<_PanelTab>(
            segments: const [
              ButtonSegment(
                value: _PanelTab.content,
                label: Text('Content'),
                icon: Icon(Icons.article_outlined),
              ),
              ButtonSegment(
                value: _PanelTab.comments,
                label: Text('Comments'),
                icon: Icon(Icons.mode_comment_outlined),
              ),
            ],
            selected: {_tab},
            onSelectionChanged: (selection) {
              setState(() => _tab = selection.first);
            },
          ),
        
          const SizedBox(height: 12),

          /// Tabs contents either (Content/Comments)
          Expanded(
            child: _tab == _PanelTab.content
                ? EventContent(event: event)
                : EventComments(eventId: event.id),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              if (_isAuthor) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      // Launch the editor (its synchronous part shows the dialog
                      // and captures the refresh), then close this event panel.
                      openEventEditor(context, event);
                      context.read<EventInteractionCubit>().dismiss(event);
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
          ),
          
        ],
      ),
    );
  }
}





