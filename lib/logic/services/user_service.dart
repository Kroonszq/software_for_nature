import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/interfaces/category_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';

final class UserService implements UserServiceInterface {
  final UserRepositoryInterface _userRepository;
  final GroupRepositoryInterface _groupRepository;
  final CategoryRepositoryInterface _categoryRepository;

  const UserService({required this._userRepository,required this._groupRepository,required this._categoryRepository});

  @override
  Future<List<User>> getAllUsers() async {
    final users = await _userRepository.getAll() ?? const <User>[];
    final groups = await _groupRepository.getAll() ?? const <Group>[];
    final categories = await _categoryRepository.getAll() ?? const <Category>[];

    final categoriesById = {for (final c in categories) c.id: c};
    final groupsById = {for (final g in groups) g.id: g};

    // Resolve each group's categories from its categoryIds.
    for (final g in groups) {
      g.categories = g.categoryIds
          .map((id) => categoriesById[id])
          .whereType<Category>()
          .toList();
    }

    // Resolve each user's groups from its groupIds.
    for (final u in users) {
      u.groups = u.groupIds
          .map((id) => groupsById[id])
          .whereType<Group>()
          .toList();
    }

    return users;
  }

  @override
  Future<User?> getCurrentUser() async {
    final users = await getAllUsers();
    return users.isEmpty ? null : users.first;
  }
}
