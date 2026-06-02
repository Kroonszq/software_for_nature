import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_widget.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_selector.dart';

class TimeLinesWrapper extends StatelessWidget {
  const TimeLinesWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      builder: (context, state) {
        // Show loading indicator until events are loaded
        if (state is! TimeLinesWrapperLoaded) {
          return const Center(child: CircularProgressIndicator());
        }


      return Row(
          children: [
            Expanded(
              flex: 10,
              child: Row(
                children: [
                  for (var entry in state.timelines.entries.where((timeline) => timeline.value.active == true)) ...[
                    Expanded(
                      child: Column(
                        children: [
                          // ─── Header / minimize button ───
                          GestureDetector(
                            onTap: () => context
                                .read<TimeLinesWrapperBloc>()
                                .add(SetTimelineInActive(entry.key)),
                            child: Container(
                              color: Colors.blue,
                              height: 50,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      Text(
                                        'Timeline ${entry.key}',
                                        overflow: TextOverflow.ellipsis,   // <-- add this
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'minimize',
                                        overflow: TextOverflow.ellipsis,   // <-- add this
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                          ),
                          // ─── The timeline itself ───
                          Expanded(child: entry.value.timelineWidget ?? const SizedBox()),
                        ],
                      ),
                    ),
                    // Divider between timelines, not after the last
                    // if (i < timelines.length - 1)
                    //   const VerticalDivider(width: 1),
                  ],
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // ─── Right sidebar ───
            TimelineSelector(),   // <-- passed from state
          ],
        );
      },
    );
  }
}