import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';

class TimelineWidget extends StatelessWidget {

  static const double pixelsPerMinute = 2.0;
  final List<EventPost> listOfEvents;
  Map<int, List<EventPost>> listOfRows = {};

  TimelineWidget({super.key, required this.listOfEvents})
  {
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
                  for (EventPost event in entry.value)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        border: Border.all(color: Colors.blue),
                      ),
                      padding: const EdgeInsets.all(4),
                      width: 100,
                      height: getHeight(event),
                      child: Text(event.title),
                    ),
                ],
              ),
          ],
        ),
    );
  }

  void calculateRows() {
    for (EventPost event in listOfEvents) {
      bool placed = false;

      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
            event.startDuration.isBefore(existing.endDuration) &&
            event.endDuration.isAfter(existing.startDuration) &&
            event.startDuration != existing.startDuration,
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
  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * pixelsPerMinute;
  }


  @override initState(){
    // super.initState();
    calculateRows();

  }
}

