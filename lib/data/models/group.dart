import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/json_model.dart';
import 'package:software_for_nature/data/models/user.dart';

class Group implements JsonModel {
  @override
  final String id;

  final String title;
  final Color color;

  /// Ids of the categories this group grants access to. A user that belongs to
  /// this group may view the events of these categories.
  final List<String> categoryIds;

  /// Hydrated relation: the categories resolved from [categoryIds].
  List<Category> categories = const [];
  List<User> users = const [];

  Group({
    required this.id,
    required this.title,
    required this.color,
    this.categoryIds = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categoryIds'];
    return Group(
      id: json['id'].toString(),
      title: json['title'] as String,
      color: ColorUtils.fromHex(json['color'] as String),
      categoryIds: rawCategories is List
          ? rawCategories.map((c) => c.toString()).toList()
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'color': ColorUtils.toHex(color),
        'categoryIds': categoryIds,
      };
}
