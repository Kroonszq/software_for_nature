import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/presentation/widgets/group/category_chip.dart';


class GroupCard extends StatelessWidget {
  final Group group;
  final int memberCount;
  final VoidCallback onEdit;

  const GroupCard({super.key, required this.group, required this.memberCount, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final foreground = ThemeData.estimateBrightnessForColor(group.color) == Brightness.dark
      ? Colors.white
      : Colors.black87;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(),
      child: InkWell(
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // cololored header
            Container(
              color: group.color,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: foreground),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${group.categories.length} categor'
                          '${group.categories.length == 1 ? 'y' : 'ies'}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.person, size: 14, color: Colors.black54),
                        const SizedBox(width: 2),
                        Text(
                          '$memberCount',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: group.categories.isEmpty
                          ? const Text(
                              'No categories',
                              style: TextStyle(color: Colors.black38),
                            )
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final category in group.categories)
                                    CategoryChip(category: category),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
