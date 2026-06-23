
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/interfaces/category_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';

final class CategoryService  implements CategoryServiceInterface {
  final EventPostRepositoryInterface _eventPostRepository;
  final CategoryRepositoryInterface _categoryRepository;
  final UserRepositoryInterface _userRepository;

  const CategoryService({required this._eventPostRepository, required this._categoryRepository, required this._userRepository});
  

  @override
  Future<List<Category>> getAllCategories() async {
    final categories = await _categoryRepository.getAll();
    if(categories == null) {
      return const <Category>[];
    }
    
    for (final c in categories){
      c.events = await _eventPostRepository.getAllByCategoryId(c.id) ?? const <EventPost>[];
    }

    return categories;
  }

  @override
  Future<List<Category>> getCategories(EventQuery query) async {
    final categories = await _categoryRepository.getAll();
    if (categories == null) {
      return const <Category>[];
    }

    var scoped = categories;
    if(query.categoryIds != null && query.categoryIds!.isNotEmpty){
      scoped = categories.where((c) => query.categoryIds!.contains(c.id)).toList();
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