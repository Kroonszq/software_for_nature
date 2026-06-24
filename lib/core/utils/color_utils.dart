import 'package:flutter/material.dart';

abstract final class ColorUtils {
  const ColorUtils._();

  static Color fromHex(String value) {
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static String toHex(Color color) => '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}