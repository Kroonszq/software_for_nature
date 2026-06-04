import 'package:software_for_nature/data/models/coordinates.dart';

class GeoBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  const GeoBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  bool contains(Coordinates c) {
    return c.lat <= north &&
           c.lat >= south &&
           c.lng <= east &&
           c.lng >= west;
  }
}