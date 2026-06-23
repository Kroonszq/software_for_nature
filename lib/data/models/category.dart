import 'package:flutter/cupertino.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/json_model.dart';

final class Category implements JsonModel {
  @override
  final String id;
  final String name;
  final Color color;

  /// Hydrated relation: the events that belong to this category.
  List<EventPost> events = const[];

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: ColorUtils.fromHex(json['color'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': ColorUtils.toHex(color),
    };
  }
}
