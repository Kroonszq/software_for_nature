//import 'package:software_for_nature/data/models/coordinates.dart';
//import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/media.dart';

class EventPost {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  //final DateTime startDuration;
  //final DateTime endDuration;

  //final Group group;
  final Coordinates? coordinates;

  final List<Media>? media;

  const EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    //required this.startDuration,
    //required this.endDuration,
    //required this.group,
    this.coordinates,
    this.media
  });

  factory EventPost.fromJson(Map<String, dynamic> json) {
  return EventPost(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    coordinates: json['lat'] != null
        ? Coordinates(lat: json['lat'], lng: json['lng'])
        : null,
    media: (json['media'] as List?)
        ?.map((m) => Media.fromJson(m))
        .toList(),
  );
}
}


