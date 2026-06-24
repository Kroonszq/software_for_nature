import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/logic/cubit/group/group_state.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/group_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupServiceInterface _groupService;
  final CategoryServiceInterface _categoryService;
  final UserServiceInterface _userService;

  GroupCubit({required this._groupService, required this._categoryService, required this._userService}) : super(const GroupState());

  Future<void> load() async {
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      final groups = await _groupService.getAllGroups() ?? const <Group>[];
      final users = await _userService.getAllUsers();
      // Group administration assigns access, so it must list every category,
      // not just the ones the current user can already view.
      final categories = await _categoryService.getAllCategoriesUnscoped();

      emit(state.copyWith(
        status: GroupStatus.ready,
        groups: groups,
        categories: categories,
        users: users,
      ));
    } catch (_) {
      emit(state.copyWith(status: GroupStatus.error));
    }
  }

  Future<void> createGroup({
    required String title,
    required Color color,
    required List<String> categoryIds,
    required Set<String> memberUserIds,
  }) async {
    final group = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      color: color,
      categoryIds: categoryIds,
    );

    await _groupService.createGroup(group, memberUserIds);

    await load();
  }

  Future<void> updateGroup(
    Group original, {
    required String title,
    required Color color,
    required List<String> categoryIds,
    required Set<String> memberUserIds,
  }) async {
    final updated = Group(
      id: original.id,
      title: title,
      color: color,
      categoryIds: categoryIds,
    );

    await _groupService.updateGroup(updated, memberUserIds);

    await load();
  }

  Future<void> deleteGroup(Group group) async {
    await _groupService.deleteGroup(group);

    await load();
  }
}
