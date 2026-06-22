import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/json_model.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/data/models/user.dart';

class EventPost implements JsonModel<EventPost> {
  @override
  final String id;

  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? timestamp;
  final DateTime startDuration;
  final DateTime endDuration;
  final String groupId;
  final String userId;
  final Coordinates? coordinates;
  final List<EventAttachment> attachments;
  final List<EventChart> charts;
  final List<Tag> tags;

  Group? group;
  User? user;


  EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.timestamp,
    required this.startDuration,
    required this.endDuration,
    required this.groupId,
    required this.userId,
    this.coordinates,
    this.attachments = const [],
    this.charts = const [],
    this.tags = const [],
  });

  bool get isMoment => timestamp != null;

  DateTime get occurredAt => timestamp ?? startDuration;

  EventPost copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
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
    List<Tag>? tags,
  }) {
    return EventPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
      startDuration: startDuration ?? this.startDuration,
      endDuration: endDuration ?? this.endDuration,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      coordinates: coordinates ?? this.coordinates,
      attachments: attachments ?? this.attachments,
      charts: charts ?? this.charts,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      // An event is either a moment (timestamp) or a range (start/end).
      if (isMoment)
        'timestamp': timestamp!.toIso8601String()
      else ...{
        'startDuration': startDuration.toIso8601String(),
        'endDuration': endDuration.toIso8601String(),
      },
      'groupId': groupId,
      'userId': userId,
      if (coordinates != null)
        'coordinates': {
          'lat': coordinates!.lat,
          'lng': coordinates!.lng,
        },
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
      if (tags.isNotEmpty) 'tags': tags.map((t) => t.toJson()).toList(),
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

    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags
            .map((t) => Tag.fromJson(t as Map<String, dynamic>))
            .toList()
        : <Tag>[];


    final hasRange =json['startDuration'] != null && json['endDuration'] != null;
    final rawTimestamp = json['timestamp'];
    final DateTime? parsedTimestamp = rawTimestamp != null ? DateTime.parse(rawTimestamp as String) : null;
    final DateTime? momentTimestamp = (!hasRange) ? parsedTimestamp : null;
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final DateTime createdAt = rawCreatedAt != null
        ? DateTime.parse(rawCreatedAt as String)
        : (parsedTimestamp ?? DateTime.now());

    final DateTime startDuration = hasRange
        ? DateTime.parse(json['startDuration'] as String)
        : (momentTimestamp ?? createdAt);
    final DateTime endDuration = hasRange
        ? DateTime.parse(json['endDuration'] as String)
        : (momentTimestamp ?? createdAt);

    return EventPost(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: createdAt,
      timestamp: momentTimestamp,
      startDuration: startDuration,
      endDuration: endDuration,
      groupId: json['groupId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '1',
      coordinates: coordinates,
      attachments: attachments,
      tags: tags,
    );
  }
}
