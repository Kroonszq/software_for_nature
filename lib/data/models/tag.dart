import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';

class Tag {
  final String label;
  final Color color;

  const Tag({required this.label, required this.color, });

  Map<String, dynamic> toJson() => {
        'label': label,
        'color': ColorUtils.toHex(color),
      };

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      label: json['label'] as String,
      color: ColorUtils.fromHex(json['color'] as String),
    );
  }

  @override
  bool operator ==(Object other) => other is Tag && other.label == label && other.color == color;

  @override
  int get hashCode => Object.hash(label, color);
}
