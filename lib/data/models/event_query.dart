import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';

class EventQuery {
  final GeoBounds? bounds;
  final DateTimeRange? timeRange;

  const EventQuery({
    this.bounds,
    this.timeRange,
  });
}
