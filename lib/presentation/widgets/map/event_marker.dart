import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:software_for_nature/data/models/event_post.dart';

class EventMarker extends Marker {
  final EventPost event;

  EventMarker({
    required this.event,
    required LatLng point,
    required Widget child,
    double width = 40,
    double height = 52,
  }) : super(
          point: point,
          width: width,
          height: height,
          child: child,
        );
}