import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';

enum GroupStatus { loading, ready, error }

class GroupState {
  final GroupStatus status;

  /// All groups, with their [Group.categories] relation and [Group.users] hydrated
  final List<Group> groups;

  /// Every category in the system
  final List<Category> categories;

  /// Every user in the system
  final List<User> users;

  const GroupState({
    this.status = GroupStatus.loading,
    this.groups = const [],
    this.categories = const [],
    this.users = const [],
  });

  GroupState copyWith({
    GroupStatus? status,
    List<Group>? groups,
    List<Category>? categories,
    List<User>? users,
  }) {
    return GroupState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      categories: categories ?? this.categories,
      users: users ?? this.users,
    );
  }
}
