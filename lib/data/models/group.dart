import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';
import 'package:software_for_nature/data/models/json_model.dart';

class Group implements JsonModel {
  @override
  final String id;

  final String title;
  final Color color;

  const Group({
    required this.id,
    required this.title,
    required this.color,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'].toString(),
      title: json['title'] as String,
      color: ColorUtils.fromHex(json['color'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'color': ColorUtils.toHex(color),
      };
}
