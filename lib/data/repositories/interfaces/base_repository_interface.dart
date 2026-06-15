
import 'package:software_for_nature/data/models/json_model.dart';

abstract interface class BaseRepositoryInterface<T extends JsonModel>
{
  Future<T?> create(T eventPost);
  Future<T?> getById(int id);
  Future<List<T>?> getAll();
  Future<T?> update(T eventPost);
  Future<int> remove(T eventPost);
  Future<int> removeById(int id);
}