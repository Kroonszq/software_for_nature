import 'package:software_for_nature/data/models/json_model.dart';

/// An application user. Events are owned by a user via their [id].
class User implements JsonModel {
  @override
  final String id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
