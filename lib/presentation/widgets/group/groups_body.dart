import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/logic/cubit/group/group_cubit.dart';
import 'package:software_for_nature/logic/cubit/group/group_state.dart';
import 'package:software_for_nature/presentation/widgets/group/group_form_drawer.dart';
import 'package:software_for_nature/presentation/widgets/group/groups_grid.dart';

class GroupsBody extends StatefulWidget {
  const GroupsBody({super.key});

  @override
  State<GroupsBody> createState() => _GroupsBodyState();
}

class _GroupsBodyState extends State<GroupsBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Group? _editing;

  void _openCreate() {
    setState(() => _editing = null);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openEdit(Group group) {
    setState(() => _editing = group);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state.status == GroupStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == GroupStatus.error) {
          return const Center(child: Text('Could not load groups.'));
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          endDrawer: GroupFormDrawer(
            key: ValueKey(_editing?.id ?? '__new__'),
            categories: state.categories,
            users: state.users,
            existing: _editing,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFF5900),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            onPressed: _openCreate,
            icon: const Icon(Icons.add),
            label: const Text('New group'),
          ),
          body: state.groups.isEmpty
              ? const Center(
                  child: Text('No groups yet. Create one to get started.'),
                )
              : GroupsGrid(
                  groups: state.groups,
                  users: state.users,
                  onEdit: _openEdit,
                ),
        );
      },
    );
  }
}
