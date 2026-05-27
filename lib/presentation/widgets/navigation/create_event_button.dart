import 'package:flutter/material.dart';

class CreateEventButton extends StatelessWidget {

  const CreateEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFFFF5900)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
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