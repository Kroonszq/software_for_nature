
import 'package:logger/logger.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/interfaces/category_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/group_service_interface.dart';

final class GroupService implements GroupServiceInterface {

  final GroupRepositoryInterface _groupRepository;
  final UserRepositoryInterface _userRepository;
  final CategoryRepositoryInterface _categoryRepository;

  final Logger _logger;

  const GroupService({
    required this._logger,
    required this._groupRepository,
    required this._userRepository,
    required this._categoryRepository,
  });

  @override
  Future<List<Group>?> getAllGroups() async {
    final groups = await _groupRepository.getAll();
    if (groups == null) {
      return null;
    }

    final users = await _userRepository.getAll() ?? const <User>[];
    final categories = await _categoryRepository.getAll() ?? const <Category>[];

    for (final group in groups) {
      group.users = users.where((u) => u.groupIds.contains(group.id)).toList();

      group.categories = categories.where((c) => group.categoryIds.contains(c.id)).toList();
    }

    return groups;
  }

  
  @override
  Future<Group?> createGroup(Group group, Set<String> memberUserIds) async {
    var newGroup = await _groupRepository.create(group);
    if(newGroup == null) {
      _logger.e("Something went wrong creating a new group");
      return null;
    }

    await _applyMembershipToGroup(newGroup.id, memberUserIds);

    return newGroup;
  }

  @override
  Future<Group?> updateGroup(Group group, Set<String> memberUserIds) async {
    var updatedGroup = await _groupRepository.update(group);
    if(updatedGroup == null) {
      _logger.e("Something went wrong with updating a new group");
      return null;
    }

    await _applyMembershipToGroup(group.id, memberUserIds);
    
    return updatedGroup;
  }

  @override
  Future<void> deleteGroup(Group group) async {
    await _groupRepository.remove(group);

    await _applyMembershipToGroup(group.id, const {});
  }



  Future<void> _applyMembershipToGroup(String groupId, Set<String> memberUserIds) async {
    var users = await _userRepository.getAll();
    if(users == null){
      return;
    }

    for (final user in users) {
      final isMember = user.groupIds.contains(groupId);
      final shouldBeMember = memberUserIds.contains(user.id);
      if (isMember == shouldBeMember) continue;

      final groupIds = List<String>.from(user.groupIds);
      if (shouldBeMember) {
        groupIds.add(groupId);
      } else {
        groupIds.remove(groupId);
      }

      await _userRepository.update(
        User(id: user.id, name: user.name, groupIds: groupIds),
      );
    }
  }

}