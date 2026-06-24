import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/json_model.dart';

class User implements JsonModel {
  @override
  final String id;
  final String name;
  final List<String> groupIds;

  List<Group> groups = const [];

  User({required this.id, required this.name, required this.groupIds});

  List<Category> get viewableCategories {
    final byId = <String, Category>{};
    for (final group in groups) {
      for (final category in group.categories) {
        byId[category.id] = category;
      }
    }
    return byId.values.toList();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groupIds'];
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
      groupIds: rawGroups is List
          ? rawGroups.map((g) => g.toString()).toList()
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groupIds': groupIds,
    };
  }
}
