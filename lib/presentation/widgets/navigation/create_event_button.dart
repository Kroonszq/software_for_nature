import 'package:flutter/material.dart';

class CreateEventButton extends StatelessWidget {
  /// When true, only the icon is shown (used on narrow/mobile screens).
  final bool compact;

  const CreateEventButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Color(0xFFFF5900)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      padding: compact
          ? WidgetStateProperty.all(const EdgeInsets.all(8))
          : null,
      minimumSize: compact
          ? WidgetStateProperty.all(const Size(40, 40))
          : null,
    );

    // ppens the EventCreationDrawer registered as the scafolds endDrawe
    void openCreateDrawer() => Scaffold.of(context).openEndDrawer();

    if (compact) {
      return ElevatedButton(
        onPressed: openCreateDrawer,
        style: style,
        child: const Icon(Icons.add, color: Colors.white, size: 16),
      );
    }

    return ElevatedButton(
      onPressed: openCreateDrawer,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text('Create event', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}