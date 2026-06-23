import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/category_repository_interface.dart';

class CategoryRepository extends BaseRepository<Category> implements CategoryRepositoryInterface {
  CategoryRepository({required super.jsonClient});
}
