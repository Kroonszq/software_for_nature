import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/category.dart';


class CategoryChip extends StatelessWidget {
  final Category category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final foreground = ThemeData.estimateBrightnessForColor(category.color) == Brightness.dark
      ? Colors.white
      : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.name,
        style: TextStyle(color: foreground, fontSize: 12),
      ),
    );
  }
}
