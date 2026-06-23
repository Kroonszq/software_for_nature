import 'package:software_for_nature/data/models/group.dart';

abstract interface class GroupServiceInterface {
  Future<List<Group>?> getAllGroups();

  Future<Group?> createGroup(Group group, Set<String> memberUserIds);

  Future<Group?> updateGroup(Group group, Set<String> memberUserIds);

  Future<void> deleteGroup(Group group);
}