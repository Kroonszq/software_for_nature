import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_widget.dart';

class TimelineSelector extends StatelessWidget {

  const TimelineSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      builder: (context, state) {
        if (state is! TimeLinesWrapperLoaded) {
          return const Expanded(
            flex: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.all(15),
            scrollDirection: Axis.vertical,
            children: [
              for (final entry in state.timelines.entries) ...[
                GestureDetector(
                  onTap: () {
                    context.read<TimeLinesWrapperBloc>().add(
                      SetTimelineActive(
                        entry.key
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─── Label bar ───
                        Container(
                          color: Colors.blueGrey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: Text(
                            'Col ${entry.key}  ·  expand',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // ─── Scaled widget preview ───
                        Expanded(
                          child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            border: Border.all(
                              color: entry.value.active ? Colors.blue : Colors.transparent,
                              width: 5,
                            ),
                          ),
                          child: ClipRect(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const double scale = 0.18;

                                return OverflowBox(
                                  alignment: Alignment.topLeft,
                                  maxWidth: constraints.maxWidth / scale,
                                  maxHeight: constraints.maxHeight / scale,
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.topLeft,
                                    child: IgnorePointer(
                                      child: entry.value.timelineWidget,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ],
          ),
        );
      },
    );
  }
}