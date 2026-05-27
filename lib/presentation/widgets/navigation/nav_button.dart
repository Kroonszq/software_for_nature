import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';

class NavButton extends StatelessWidget {
  final String label;
  final String route;
  final bool isActive;

  const NavButton({super.key, required this.label, required this.route, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isActive
            ? BorderSide(color:  Color(0xFFFF5900), width: 2)
            : BorderSide.none,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<NavigationBloc>().add(
            NavigateToRoute(route),
          );
        },
        style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Color(0xFFFF5900).withOpacity(0.1); 
              }
              return Colors.black;
            }),
          elevation: WidgetStateProperty.all(0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Color(0xFFFF5900) : Colors.white,
          ),
        ),
      ),
    );
  }
}