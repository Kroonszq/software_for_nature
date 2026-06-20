import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';
import 'package:software_for_nature/presentation/widgets/event_drawer.dart';
import 'package:software_for_nature/presentation/widgets/navigation.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String? title;

  Layout({super.key, required this.child, this.title});

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventInteractionCubit, EventInteractionState>(
      listenWhen: (prev, curr) =>
        prev.selectedEvent != curr.selectedEvent &&
        curr.selectedEvent == null &&
        curr.minimizedEvents.isEmpty &&
        curr.openEvents.isEmpty,
      listener: (context, state) {
        _scaffoldKey.currentState?.closeDrawer();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: Navigation(),
        body: child,
        drawer: const EventDrawer(),

        onDrawerChanged: (isOpened) {
          if (!isOpened) {
            context.read<EventInteractionCubit>().minimizeAllIfNeeded();
          }
        },
      ),
    );
  }
}