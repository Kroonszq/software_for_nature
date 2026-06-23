

import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_query.dart';

abstract interface class CategoryServiceInterface {

  /// Returns all categories hydrated with [Category.events]
  Future<List<Category>> getAllCategories();


  Future<List<Category>> getCategories(EventQuery query);
}