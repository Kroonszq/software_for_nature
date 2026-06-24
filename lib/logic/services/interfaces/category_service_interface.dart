

import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_query.dart';

abstract interface class CategoryServiceInterface {

  /// Returns the categories the current user may view (scoped to their groups),
  /// hydrated with [Category.events].
  Future<List<Category>> getAllCategories();

  /// Returns every category, ignoring the current user's view access, hydrated
  /// with [Category.events]. Used by group administration, where the whole point
  /// is to grant access to categories the user may not currently see.
  Future<List<Category>> getAllCategoriesUnscoped();


  Future<List<Category>> getCategories(EventQuery query);
}