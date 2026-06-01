import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline.dart';

class TimeLinesWrapper extends StatefulWidget {
  const TimeLinesWrapper({super.key});
  @override
  State<TimeLinesWrapper> createState() => _TimeLinesWrapperState();
}

class _TimeLinesWrapperState extends State<TimeLinesWrapper> {
  List<int> selectedColumns = [];
  final List<int> columnOrder = [0, 1, 2, 3, 4];

  List<Event> listOfEvents = [
    Event(
      "Event 1",
      DateTime.utc(1989, DateTime.november, 9, 15, 3, 8),
      DateTime.utc(1989, DateTime.november, 9, 16, 3, 8),
    ),
    Event(
      "Event 2",
      DateTime.utc(1989, DateTime.november, 9, 15, 3, 8),
      DateTime.utc(1989, DateTime.november, 9, 16, 3, 8),
    ),
    // Event(
    //   "Event 2",
    //   DateTime.utc(1989, DateTime.november, 10, 16, 4, 9),
    //   DateTime.utc(1989, DateTime.november, 13, 20, 8, 12),
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: Row(
            children: [
              for (int col in columnOrder.where(
                (c) => selectedColumns.contains(c),
              )) ...[
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          selectedColumns.remove(col);
                        }),
                        child: Container(
                          color: Colors.blue,
                          height: 50,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [Text('$col'), Text('minimize')],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TimeLine(listOfEvents: listOfEvents),
                      ),
                    ],
                  ),
                ),
                if (col !=
                    columnOrder
                        .where((c) => selectedColumns.contains(c))
                        .last)
                  const VerticalDivider(width: 1),
              ],
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // ─── Right sidebar with widget previews ───
        Expanded(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.all(15),
            scrollDirection: Axis.vertical,
            children: [
              for (int col in columnOrder.where(
                (c) => !selectedColumns.contains(c),
              )) ...[
                GestureDetector(
                  onTap: () => setState(() {
                    selectedColumns.insert(0, col);
                  }),
                  child: SizedBox(
                    height: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Label bar
                        Container(
                          color: Colors.blueGrey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: Text(
                            'Col ${col + 1}  ·  expand',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // ── Scaled widget preview ──
                        Expanded(
                          child: ColoredBox(
                            color: Colors.red,
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
                                    // IgnorePointer so the preview
                                    // doesn't steal taps from GestureDetector
                                    child: IgnorePointer(
                                      child: TimeLine(
                                        listOfEvents: listOfEvents,
                                      ),
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
    );
  }
}