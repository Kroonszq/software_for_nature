import 'package:software_for_nature/data/models/coordinates.dart';

class EventPost {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;

  final Coordinates? coordinates;

  const EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.coordinates,
  });
}

