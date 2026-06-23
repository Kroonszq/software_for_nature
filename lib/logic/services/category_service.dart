
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/interfaces/category_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';

final class CategoryService  implements CategoryServiceInterface {
  final EventPostRepositoryInterface _eventPostRepository;
  final CategoryRepositoryInterface _categoryRepository;
  final UserRepositoryInterface _userRepository;
  final GroupRepositoryInterface _groupRepository;

  const CategoryService({required this._eventPostRepository, required this._categoryRepository, required this._userRepository, required this._groupRepository});

  /// The set of category ids the current user may view, derived from the
  /// categories granted by every group the user belongs to. A user that is no
  /// longer in a group loses access to that group's categories.
  Future<Set<String>> _viewableCategoryIds() async {
    final users = await _userRepository.getAll() ?? const <User>[];
    if (users.isEmpty) {
      return const <String>{};
    }

    // The "current" user is the first one, matching getCurrentUser() and the
    // way new events are attributed.
    final currentUser = users.first;

    final groups = await _groupRepository.getAll() ?? const <Group>[];
    return {
      for (final group in groups)
        if (currentUser.groupIds.contains(group.id)) ...group.categoryIds,
    };
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final categories = await _categoryRepository.getAll();
    if(categories == null) {
      return const <Category>[];
    }

    // Only expose the categories the current user has access to through groups.
    final viewableIds = await _viewableCategoryIds();
    final scoped = categories.where((c) => viewableIds.contains(c.id)).toList();

    for (final c in scoped){
      c.events = await _eventPostRepository.getAllByCategoryId(c.id) ?? const <EventPost>[];
    }

    return scoped;
  }

  @override
  Future<List<Category>> getCategories(EventQuery query) async {
    final categories = await _categoryRepository.getAll();
    if (categories == null) {
      return const <Category>[];
    }

    // Start from the categories the current user is allowed to view.
    final viewableIds = await _viewableCategoryIds();
    var scoped = categories.where((c) => viewableIds.contains(c.id)).toList();
    if(query.categoryIds != null && query.categoryIds!.isNotEmpty){
      scoped = scoped.where((c) => query.categoryIds!.contains(c.id)).toList();
    }

    for (final c in scoped) {
      final events = await _eventPostRepository.queryEvents(
        EventQuery(
          categoryIds: {c.id},
          startDate: query.startDate,
          endDate: query.endDate,
          search: query.search,
          bounds: query.bounds,
          timeRange: query.timeRange,
          tagLabels: query.tagLabels,
        ),
      );

      // Hydrate event with user and category
      for (final e in events) {
        var user = await _userRepository.getById(int.parse(e.userId));

        e.user = user;
        e.category = c;
      }

      // Hydrate category with events
      c.events = events;
    }

    return scoped;
  }

  

}