import 'package:flutter/material.dart';


class ZoomButton extends StatelessWidget {
  final IconData icon;
  final String heroTag;
  final VoidCallback onPressed;

  const ZoomButton({
    super.key,
    required this.icon,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 2,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
