import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';
import 'package:software_for_nature/presentation/widgets/event/event_panel.dart';
import 'package:software_for_nature/presentation/widgets/minimized_events_stack.dart';

 
class EventViewDrawer extends StatelessWidget {
  const EventViewDrawer({super.key});

  static const double preferredPanelWidth = 500;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDrawerWidth = screenWidth * 0.95;

    return BlocBuilder<EventInteractionCubit, EventInteractionState>(
      builder: (context, state) {
        final hasStack = state.minimizedEvents.isNotEmpty;

        final stackWidth =
            hasStack ? MinimizedEventsStack.width : 0.0;

        final openEvents = state.openEvents;

        final panelCount = openEvents.isEmpty ? 1 : openEvents.length;

        final maxPanelWidth = maxDrawerWidth - stackWidth;

        final panelWidth =
            preferredPanelWidth.clamp(0.0, maxPanelWidth).toDouble();

        final desiredWidth =
            stackWidth + panelCount * panelWidth;

        final drawerWidth =
            desiredWidth.clamp(panelWidth, maxDrawerWidth).toDouble();

        return Drawer(
          width: drawerWidth,
          shape: const RoundedRectangleBorder(),
          child: SafeArea(
            child: Row(
              children: [
                const MinimizedEventsStack(),

                Expanded(
                  child: openEvents.isEmpty
                      ? const Center(child: Text('No event selected'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final event in openEvents)
                                SizedBox(
                                  width: panelWidth,
                                  child: EventPanel(event: event),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}