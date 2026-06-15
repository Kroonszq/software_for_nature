
/// Contract for models that can be (de)serialized to/from JSON
abstract interface class JsonModel<T> {

  /// All models should require an id to perform id based queries
  String get id;

  Map<String, dynamic> toJson();
}
