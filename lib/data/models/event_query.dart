import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/time_window.dart';


class EventQuery {
  final Set<String>? groupIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final GeoBounds? bounds;
  final TimeWindow? timeWindow;


  final Set<String>? tagLabels;

  const EventQuery({
    this.groupIds,
    this.startDate,
    this.endDate,
    this.search,
    this.bounds,
    this.timeWindow,
    this.tagLabels,
  });
}
