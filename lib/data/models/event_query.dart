import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';


class EventQuery {
  final Set<String>? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final GeoBounds? bounds;
  final DateTimeRange? timeRange;


  final Set<String>? tagLabels;

  const EventQuery({
    this.categoryIds,
    this.startDate,
    this.endDate,
    this.search,
    this.bounds,
    this.timeRange,
    this.tagLabels,
  });
}
