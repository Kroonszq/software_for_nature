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
          ? WidgetStateProperty.all(const EdgeInsets.all(12))
          : null,
    );

    // Opens the EventCreationDrawer registered as the Scaffold's endDrawer.
    void openCreateDrawer() => Scaffold.of(context).openEndDrawer();

    if (compact) {
      return ElevatedButton(
        onPressed: openCreateDrawer,
        style: style,
        child: Icon(Icons.add, color: Colors.white, size: 18),
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