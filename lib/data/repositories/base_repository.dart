
import 'package:collection/collection.dart';
import 'package:software_for_nature/data/data_sources/interfaces/json_client_interface.dart';
import 'package:software_for_nature/data/models/json_model.dart';
import 'package:software_for_nature/data/repositories/interfaces/base_repository_interface.dart';

abstract class BaseRepository<T extends JsonModel> implements BaseRepositoryInterface<T> {

  final JsonClientInterface<T> jsonClient;
  List<T>? _cache;

  BaseRepository({required this.jsonClient});


  Future<List<T>> _load() async 
  {
    return _cache ??= await jsonClient.readJson() ?? <T>[];
  }

  @override
  Future<List<T>> getAll()
  {
    return _load();
  }

  @override
  Future<T?> getById(int id) async 
  {
    final typeCollection = await _load();
    return typeCollection.firstWhereOrNull((e) => e.id == id.toString());
  }

  @override
  Future<T> create(T type) async 
  {
    final typeCollection = await _load();
    typeCollection.add(type);
    await jsonClient.writeJson(typeCollection);
    return type;
  }

  @override
  Future<T?> update(T type) async 
  {
    final typeCollection = await _load();
    final index = typeCollection.indexWhere((e) => e.id == type.id);
    if (index == -1) {
      return null;
    }

    typeCollection[index] = type;
    await jsonClient.writeJson(typeCollection);
    return type;
  }

  @override
  Future<int> remove(T type){
    return removeById(int.parse(type.id));
  } 

  @override
  Future<int> removeById(int id) async 
  {
    final typeCollection = await _load();
    final removed = typeCollection.where((e) => e.id == id.toString()).length;
    if (removed == 0) {
      return 0;
    }

    typeCollection.removeWhere((e) => e.id == id.toString());
    await jsonClient.writeJson(typeCollection);
    return removed;
  }

}