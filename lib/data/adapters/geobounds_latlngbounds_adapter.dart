import 'package:flutter_map/flutter_map.dart';
import 'package:software_for_nature/data/models/geobounds.dart';

extension LatLngBoundsMapper on LatLngBounds {
  GeoBounds toDomain() {
    return GeoBounds(
      north: north,
      south: south,
      east: east,
      west: west,
    );
  }
}