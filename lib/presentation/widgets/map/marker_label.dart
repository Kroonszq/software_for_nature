import 'package:flutter/material.dart';

/// A small white chip showing an event's title beneath a map marker. Kept
/// compact (single line, ellipsised) so it doesn't crowd the map.
class MarkerLabel extends StatelessWidget {
  final String title;
  final double maxWidth;

  const MarkerLabel({
    super.key,
    required this.title,
    this.maxWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
