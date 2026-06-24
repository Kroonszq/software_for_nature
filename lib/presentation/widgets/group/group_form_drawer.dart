import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/logic/cubit/group/group_cubit.dart';
import 'package:software_for_nature/presentation/widgets/group/selectable_table.dart';


class GroupFormDrawer extends StatefulWidget {
  final List<Category> categories;
  final List<User> users;
  final Group? existing;

  const GroupFormDrawer({super.key, required this.categories, required this.users, this.existing});

  @override
  State<GroupFormDrawer> createState() => _GroupFormDrawerState();
}

class _GroupFormDrawerState extends State<GroupFormDrawer> {
  static const List<Color> _palette = [
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  late final TextEditingController _titleController;
  late Color _color;
  late Set<String> _selectedCategoryIds;
  late Set<String> _selectedUserIds;

  String _categoryQuery = '';
  String _userQuery = '';

  /// while true the footer shows an inline delete confirmation
  bool _confirmingDelete = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _color = widget.existing?.color ?? _palette.first;
    _selectedCategoryIds = {...?widget.existing?.categoryIds};

    // members are the users that already reference this group
    final groupId = widget.existing?.id;
    if(groupId != null){
      _selectedUserIds = widget.users.where((u) => u.groupIds.contains(groupId)).map((u) => u.id).toSet();
    } else{
      _selectedUserIds = {};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _close() => Scaffold.of(context).closeEndDrawer();

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _busy) {
      return;
    }

    setState(() => _busy = true);
    final cubit = context.read<GroupCubit>();
    final existing = widget.existing;

    if (existing == null) {
      await cubit.createGroup(
        title: title,
        color: _color,
        categoryIds: _selectedCategoryIds.toList(),
        memberUserIds: _selectedUserIds,
      );
    } else {
      await cubit.updateGroup(
        existing,
        title: title,
        color: _color,
        categoryIds: _selectedCategoryIds.toList(),
        memberUserIds: _selectedUserIds,
      );
    }

    if (!mounted){
      return;
    } 
    _close();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null || _busy){
      return;
    }

    setState(() => _busy = true);
    await context.read<GroupCubit>().deleteGroup(existing);

    if (!mounted){
      return;
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: width < 600 ? width * 0.9 : 480,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit group' : 'New group',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _busy ? null : _close,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Colour',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final color in _palette)
                          GestureDetector(
                            onTap: () => setState(() => _color = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _color.toARGB32() == color.toARGB32()
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Categories this group can view',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (widget.categories.isEmpty)
                      const Text(
                        'No categories available.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      SelectableTable(
                        searchHint: 'Search categories',
                        query: _categoryQuery,
                        onQueryChanged: (value) =>
                            setState(() => _categoryQuery = value),
                        rows: [
                          for (final category in widget.categories)
                            SelectableRow(
                              id: category.id,
                              label: category.name,
                              searchText: category.name,
                              leading: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                        selectedIds: _selectedCategoryIds,
                        onChanged: (id, selected) => setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(id);
                          } else {
                            _selectedCategoryIds.remove(id);
                          }
                        }),
                      ),
                    const SizedBox(height: 20),

                    const Text(
                      'Members',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (widget.users.isEmpty)
                      const Text(
                        'No users available.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      SelectableTable(
                        searchHint: 'Search members',
                        query: _userQuery,
                        onQueryChanged: (value) =>
                            setState(() => _userQuery = value),
                        rows: [
                          for (final user in widget.users)
                            SelectableRow(
                              id: user.id,
                              label: user.name,
                              searchText: user.name,
                              leading: const Icon(Icons.person, size: 18),
                            ),
                        ],
                        selectedIds: _selectedUserIds,
                        onChanged: (id, selected) => setState(() {
                          if (selected) {
                            _selectedUserIds.add(id);
                          } else {
                            _selectedUserIds.remove(id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Footer actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFooter(isEditing),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isEditing) {
    if (_confirmingDelete) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Delete "${widget.existing?.title}"?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() => _confirmingDelete = false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: _busy ? null : _delete,
            child: const Text('Delete'),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (isEditing)
          TextButton.icon(
            onPressed: _busy ? null : () => setState(() => _confirmingDelete = true),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        const Spacer(),
        TextButton(
          onPressed: _busy ? null : _close,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF5900),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: _busy ? null : _submit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
