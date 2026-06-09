import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/group.dart';

class EventPost {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final DateTime startDuration;
  final DateTime endDuration;

  final Group group;


  final Coordinates? coordinates;

  const EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.startDuration,
    required this.endDuration,
    required this.group,
    this.coordinates,
  });

  EventPost copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    DateTime? startDuration,
    DateTime? endDuration,
    Group? group,
    Coordinates? coordinates,
  }) {
    return EventPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      startDuration: startDuration ?? this.startDuration,
      endDuration: endDuration ?? this.endDuration,
      group: group ?? this.group,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
