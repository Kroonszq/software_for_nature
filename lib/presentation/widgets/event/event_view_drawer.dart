import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/minimized_events/minimized_events_bloc.dart';
import 'package:software_for_nature/presentation/widgets/event/event_panel.dart';
import 'package:software_for_nature/presentation/widgets/minimized_events_stack.dart';

 
class EventViewDrawer extends StatelessWidget {
  const EventViewDrawer({super.key});

  static const double preferredPanelWidth = 500;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDrawerWidth = screenWidth * 0.95;

    return BlocBuilder<MinimizedEventsBloc, MinimizedEventsState>(
      builder: (context, state) {
        final hasStack = state.minimized.isNotEmpty;
        final stackWidth = hasStack ? MinimizedEventsStack.width : 0.0;
        final panelCount = state.openEvents.isEmpty ? 1 : state.openEvents.length;
        final maxPanelWidth = maxDrawerWidth - stackWidth;
        final panelWidth = preferredPanelWidth.clamp(0.0, maxPanelWidth).toDouble();
        final desiredWidth = stackWidth + panelCount * panelWidth;
        final drawerWidth = desiredWidth.clamp(panelWidth, maxDrawerWidth).toDouble();

        return Drawer(
          width: drawerWidth,
          shape: const RoundedRectangleBorder(),
          child: SafeArea(
            child: Row(
              children: [
                const MinimizedEventsStack(),
                Expanded(
                  child: state.openEvents.isEmpty
                      ? const Center(child: Text('No event selected'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final event in state.openEvents)
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
