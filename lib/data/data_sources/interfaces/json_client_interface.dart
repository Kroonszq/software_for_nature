
import 'package:software_for_nature/data/models/json_model.dart';

abstract interface class JsonClientInterface<T extends JsonModel> {
  /// Reads the JSON file and deserializes it into a list of `T`.
  /// Returns `null` if the read/parse fails.
  Future<List<T>?> readJson();

  /// Serializes [items] back into the JSON file.
  Future<void> writeJson(List<T> items);
}
