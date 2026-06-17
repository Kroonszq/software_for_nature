import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/json_model.dart';
import 'package:software_for_nature/data/models/user.dart';

class EventPost implements JsonModel<EventPost> {
  @override
  final String id;

  final String title;
  final String description;
  final DateTime timestamp;
  final DateTime startDuration;
  final DateTime endDuration;
  final String groupId;
  final String userId;
  final Coordinates? coordinates;
  final List<EventAttachment> attachments;
  final List<EventChart> charts;

  // Hydrated externally after fetch (mirrors [group]). Not serialized.
  Group? group;
  User? user;


  EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.startDuration,
    required this.endDuration,
    required this.groupId,
    required this.userId,
    this.coordinates,
    this.attachments = const [],
    this.charts = const [],
  });

  EventPost copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    DateTime? startDuration,
    DateTime? endDuration,
    String? groupId,
    String? userId,
    Group? group,
    User? user,
    Coordinates? coordinates,
    List<EventAttachment>? attachments,
    List<EventChart>? charts,
  }) {
    return EventPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      startDuration: startDuration ?? this.startDuration,
      endDuration: endDuration ?? this.endDuration,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      coordinates: coordinates ?? this.coordinates,
      attachments: attachments ?? this.attachments,
      charts: charts ?? this.charts,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'startDuration': startDuration.toIso8601String(),
      'endDuration': endDuration.toIso8601String(),
      'groupId': groupId,
      'userId': userId,
      if (coordinates != null)
        'coordinates': {
          'lat': coordinates!.lat,
          'lng': coordinates!.lng,
        },
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory EventPost.fromJson(Map<String, dynamic> json) {
    Coordinates? coordinates;
    final coord = json['coordinates'];
    if (coord is Map<String, dynamic>) {
      coordinates = Coordinates(
        lat: (coord['lat'] as num).toDouble(),
        lng: (coord['lng'] as num).toDouble(),
      );
    }

    final rawAttachments = json['attachments'];
    final attachments = rawAttachments is List
        ? rawAttachments
            .map((a) => EventAttachment.fromJson(a as Map<String, dynamic>))
            .toList()
        : <EventAttachment>[];

    return EventPost(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      startDuration: DateTime.parse(json['startDuration'] as String),
      endDuration: DateTime.parse(json['endDuration'] as String),
      groupId: json['groupId']?.toString() ?? '',
      // Defaults to the test user ('1') for legacy records that predate userId.
      userId: json['userId']?.toString() ?? '1',
      coordinates: coordinates,
      attachments: attachments,
    );
  }
}
