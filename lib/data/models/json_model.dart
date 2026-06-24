
abstract interface class JsonModel<T> {

  String get id;

  Map<String, dynamic> toJson();
}
