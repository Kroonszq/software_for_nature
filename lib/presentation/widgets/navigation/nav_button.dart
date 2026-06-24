import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';

class NavButton extends StatelessWidget {
  final String label;
  final String route;
  final bool isActive;
  final bool isCompact;

  const NavButton({
    super.key,
    required this.label,
    required this.route,
    required this.isActive,
    this.isCompact = false,
  });

  IconData _getIconForRoute(String label) {
    switch (label.toLowerCase()) {
      case 'timeline':
        return Icons.timeline;
      case 'map':
        return Icons.map;
      case 'hybrid':
        return Icons.layers;
      case 'groups':
        return Icons.group;
      default:
        return Icons.dashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
        : EdgeInsets.zero;

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
            padding: WidgetStateProperty.all(buttonPadding),
            minimumSize: isCompact
                ? WidgetStateProperty.all(const Size(40, 40))
                : null,
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Color(0xFFFF5900).withValues(alpha: 0.1);
              }
              return Colors.black;
            }),
          elevation: WidgetStateProperty.all(0),
        ),
        child: isCompact
            ? Icon(
                _getIconForRoute(label),
                color: isActive ? Color(0xFFFF5900) : Colors.white,
                size: 20,
              )
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Color(0xFFFF5900) : Colors.white,
                ),
              ),
      ),
    );
  }
}