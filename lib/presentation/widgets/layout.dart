import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/minimized_events/minimized_events_bloc.dart';
import 'package:software_for_nature/presentation/widgets/event_drawer.dart';
import 'package:software_for_nature/presentation/widgets/navigation.dart';

@immutable
class Layout extends StatelessWidget {

  final Widget child;
  final String? title;

  const Layout({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigation(),
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          context.read<MinimizedEventsBloc>().add(MinimizeAllOpen());
        }
      },
      body: child,
      drawer: const EventDrawer(),
    );
  }
}
