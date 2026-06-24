import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/presentation/widgets/export/export_drawer.dart';


class ExportButton extends StatelessWidget {
  final bool isCompact;

  const ExportButton({super.key, this.isCompact = false});

  Future<void> _open(BuildContext context) async {
    final wrapperState = context.read<TimeLinesWrapperBloc>().state;
    final currentQueryEvents = wrapperState is TimeLinesWrapperLoaded
        ? wrapperState.allEvents
        : const <EventPost>[];
    final allEvents = await context.read<EventPostRepository>().getAll();

    if (!context.mounted) {
      return;
    }

    final double width = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.9
        : 440;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Export events',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: Material(
              elevation: 16,
              child: ExportDrawer(
                currentQueryEvents: currentQueryEvents,
                allEvents: allEvents,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return IconButton(
        icon: const Icon(Icons.download),
        tooltip: 'Export',
        onPressed: () => _open(context),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _open(context),
      icon: const Icon(Icons.download),
      label: const Text('Export'),
    );
  }
}
