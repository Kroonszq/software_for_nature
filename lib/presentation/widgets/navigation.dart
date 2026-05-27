import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/app_routes.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:software_for_nature/presentation/widgets/navigation/create_event_button.dart';
import 'package:software_for_nature/presentation/widgets/navigation/nav_button.dart';

@immutable
class Navigation extends StatelessWidget implements PreferredSizeWidget {
  const Navigation({super.key});

  final double _height = 68;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {
        if (state is NavigationRouteChanged) {
          Navigator.pushReplacementNamed(context, state.route);
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: 
          Stack(alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final entry in AppRoutes.navRoutes.entries)
                          BlocBuilder<NavigationBloc, NavigationState>(
                            builder: (context, state) {
                              final currentRoute = state is NavigationRouteChanged ? state.route : AppRoutes.timeline;
                              final isActive = currentRoute == entry.value;
                              return NavButton(label: entry.key, route: entry.value, isActive: isActive);
                            },
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.person, color: Colors.white, size: 18),

                  )
                ],
              ),
              CreateEventButton()
            ],
          )
        
        
      ),
    );
  }
}