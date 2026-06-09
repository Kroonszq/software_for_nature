import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

class TimelineSideBar extends StatefulWidget {

  const TimelineSideBar({super.key});

  @override
  State<TimelineSideBar> createState() => _TimelineSideBarState();
}

class _TimelineSideBarState extends State<TimelineSideBar> {
  bool _minimized = false;

  @override
  Widget build(BuildContext context) {
    // Minimized content
    if (_minimized) {
      return SizedBox(
        width: 40,
        child: Container(
          color: Colors.blueGrey.shade50,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Show previews',
                onPressed: () => setState(() => _minimized = false),
              ),
              const RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'Previews',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Expanded content
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
          child: Column(
            children: [
              // Header with minimize button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_outlined),
                    tooltip: 'Hide previews',
                    onPressed: () => setState(() => _minimized = true),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      'Previews',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                
                ],
              ),
              // Previeuws
              Expanded(
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
                              // label
                              Container(
                                color: Colors.blueGrey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 3,
                                ),
                                child: Center(
                                  child: Text(
                                  entry.value.events.isNotEmpty
                                      ? entry.value.events.first.group.title
                                      : 'Col ${entry.key}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                )
                              ),
                              // Scaled timeline
                              Expanded(
                                child: Container(
                                decoration: BoxDecoration(
                                  color: entry.value.events.isNotEmpty
                                      ? entry.value.events.first.group.color
                                          .withValues(alpha: 0.15)
                                      : Colors.blueGrey.shade50,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
