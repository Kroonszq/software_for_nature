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
        decoration: const BoxDecoration(color: Colors.black),
        // Keep the black bar filling behind the status bar, but push its
        // content below the system status bar so it isn't overlapped.
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
          builder: (context, constraints) {
            // On narrow screens lay everything out in a single inline row
            // (scrollable nav buttons + compact create button + profile) so
            // nothing overlaps; on wider screens keep the centered create
            // button overlay design.
            final bool isCompact = constraints.maxWidth < 600;

            final navButtons = ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final entry in AppRoutes.navRoutes.entries)
                  BlocBuilder<NavigationBloc, NavigationState>(
                    builder: (context, state) {
                      final currentRoute = state is NavigationRouteChanged
                          ? state.route
                          : AppRoutes.timeline;
                      final isActive = currentRoute == entry.value;
                      return NavButton(
                        label: entry.key,
                        route: entry.value,
                        isActive: isActive,
                      );
                    },
                  ),
              ],
            );

            final profile = Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            );

            if (isCompact) {
              return Row(
                children: [
                  Expanded(child: navButtons),
                  const CreateEventButton(compact: true),
                  profile,
                ],
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    Expanded(child: navButtons),
                    profile,
                  ],
                ),
                const CreateEventButton(),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}