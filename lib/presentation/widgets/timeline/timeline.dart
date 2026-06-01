import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event.dart';

class TimeLine extends StatefulWidget {
  TimeLine({super.key, required this.listOfEvents});


  final List<Event> listOfEvents;

  @override
  State<StatefulWidget> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {

  static const double pixelsPerMinute = 2.0; // ← tweak this to scale up/down

  double getHeight(Event event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * pixelsPerMinute;
  }

  Map<int, List<Event>> listOfRows = {};

  @override initState(){
    super.initState();
    calculateRows();

  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var entry in listOfRows.entries)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (Event event in entry.value)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        border: Border.all(color: Colors.blue),
                      ),
                      padding: const EdgeInsets.all(4),
                      width: 100,
                      height: getHeight(event),
                      child: Text(event.name),
                    ),
                ],
              ),
          ],
        ),
    );
  }

  void calculateRows() {
    for (Event event in widget.listOfEvents) {
      bool placed = false;

      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
            event.startDuration.isBefore(existing.endDuration) &&
            event.endDuration.isAfter(existing.startDuration) &&
            event.startDuration != existing.startDuration, // ← same time = no overlap
        );

        if (!overlaps) {
          listOfRows[row]!.add(event);
          placed = true;
          break;
        }
      }

      if (!placed) {
        listOfRows[listOfRows.length] = [event];
      }
    }
  }
}
