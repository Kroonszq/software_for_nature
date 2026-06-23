import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/presentation/widgets/group/group_card.dart';

class GroupsGrid extends StatelessWidget {
  final List<Group> groups;
  final List<User> users;
  final void Function(Group group) onEdit;

  const GroupsGrid({super.key, required this.groups, required this.users, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = (constraints.maxWidth / 300).floor().clamp(1, 6);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final memberCount = users.where((u) => u.groupIds.contains(group.id)).length;
            return GroupCard(
              group: group,
              memberCount: memberCount,
              onEdit: () => onEdit(group),
            );
          },
        );
      },
    );
  }
}
