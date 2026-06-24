
import 'package:software_for_nature/data/models/json_model.dart';

abstract interface class JsonClientInterface<T extends JsonModel> {
  Future<List<T>?> readJson();

  Future<void> writeJson(List<T> items);
}
