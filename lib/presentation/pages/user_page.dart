import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';


enum _UserView { menu, createdEvents }

class _UserData {
  final User user;
  final List<EventPost> createdEvents;

  const _UserData({required this.user, required this.createdEvents});
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventInteractionCubit(),
      child: Layout(
        child: const _UserPageBody(),
      ),
    );
  }
}

class _UserPageBody extends StatefulWidget {
  const _UserPageBody();

  @override
  State<_UserPageBody> createState() => _UserPageBodyState();
}

class _UserPageBodyState extends State<_UserPageBody> {
  _UserView _view = _UserView.menu;
  late Future<_UserData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_UserData> _load() async {
    // Capture the repositories before awaiting so we don't touch the
    // BuildContext across async gaps.
    final userRepository = context.read<UserRepositoryInterface>();
    final eventRepository = context.read<EventPostRepository>();

    // There is a single "current" user (the first one), matching how new
    // events are attributed in the event form.
    final users = await userRepository.getAll() ?? const <User>[];
    final user = users.isNotEmpty
        ? users.first
        : const User(id: '1', name: 'Unknown user');

    final allEvents = await eventRepository.getAll();
    final createdEvents =
        allEvents.where((e) => e.userId == user.id).toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return _UserData(user: user, createdEvents: createdEvents);
  }

  void _openEvent(EventPost event) {
    context.read<EventInteractionCubit>().select(event);
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_UserData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Could not load your profile.'));
        }

        final data = snapshot.data!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _view == _UserView.menu
                ? _buildMenu(data)
                : _buildCreatedEvents(data),
          ),
        );
      },
    );
  }

  Widget _buildMenu(_UserData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.black,
                child: Text(
                  _initials(data.user.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'User id: ${data.user.id}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // Options.
        ListTile(
          leading: const Icon(Icons.event_note_outlined),
          title: const Text('Created events'),
          subtitle: Text('${data.createdEvents.length} events'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => _view = _UserView.createdEvents),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Account settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _comingSoon('Account settings'),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: () => _comingSoon('Sign out'),
        ),
      ],
    );
  }

  Widget _buildCreatedEvents(_UserData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header with a back action.
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => setState(() => _view = _UserView.menu),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Created events',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${data.createdEvents.length}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: data.createdEvents.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("You haven't created any events yet."),
                  ),
                )
              : ListView.separated(
                  itemCount: data.createdEvents.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = data.createdEvents[index];
                    return ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        TimeUtils.formatDateTime(event.occurredAt),
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _openEvent(event),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _comingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is not available yet.')),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
