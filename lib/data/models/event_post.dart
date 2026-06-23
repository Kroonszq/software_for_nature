import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
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

  final String categoryId;
  final String userId;
  final Coordinates? coordinates;
  final List<EventAttachment> attachments;
  final List<EventChart> charts;
  final List<Tag> tags;

  Category? category;
  User? user;

  EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.timestamp,
    required this.startDuration,
    required this.endDuration,
    required this.categoryId,
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
    String? categoryId,
    String? userId,
    Category? category,
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
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      coordinates: coordinates ?? this.coordinates,
      attachments: attachments ?? this.attachments,
      charts: charts ?? this.charts,
      tags: tags ?? this.tags,
    )
      ..category = category ?? this.category
      ..user = user ?? this.user;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      if (isMoment)
        'timestamp': timestamp!.toIso8601String()
      else ...{
        'startDuration': startDuration.toIso8601String(),
        'endDuration': endDuration.toIso8601String(),
      },
      'categoryId': categoryId,
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
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    }

    String title = '';
    if (json['title'] != null) {
      title = json['title'] as String;
    }

    String categoryId = '';
    if (json['categoryId'] != null) {
      categoryId = json['categoryId'].toString();
    }

    String description = '';
    if (json['description'] != null) {
      description = json['description'] as String;
    }

    String userId = '1';
    if (json['userId'] != null) {
      userId = json['userId'].toString();
    }

    Coordinates? coordinates;
    if (json['coordinates'] is Map<String, dynamic>) {
      coordinates = Coordinates(
        lat: (json['coordinates']['lat'] as num).toDouble(),
        lng: (json['coordinates']['lng'] as num).toDouble(),
      );
    }

    List<EventAttachment> attachments;
    if (json['attachments'] is List) {
      attachments = json['attachments']
          .map((a) => EventAttachment.fromJson(a as Map<String, dynamic>))
          .toList()
          .cast<EventAttachment>();
    } else {
      attachments = const <EventAttachment>[];
    }

    List<Tag> tags;
    if (json['tags'] is List) {
      tags = json['tags']
          .map((t) => Tag.fromJson(t as Map<String, dynamic>))
          .toList()
          .cast<Tag>();
    } else {
      tags = const <Tag>[];
    }

    DateTime startDuration = DateTime.now();
    if (json['startDuration'] != null) {
      startDuration = DateTime.parse(json['startDuration'] as String);
    }

    DateTime endDuration = DateTime.now();
    if (json['endDuration'] != null) {
      endDuration = DateTime.parse(json['endDuration'] as String);
    }

    DateTime? timestamp;
    if (json['timestamp'] != null) {
      timestamp = DateTime.parse(json['timestamp'] as String);
    }

    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    }

    return EventPost(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      timestamp: timestamp,
      startDuration: startDuration,
      endDuration: endDuration,
      categoryId: categoryId,
      userId: userId,
      coordinates: coordinates,
      attachments: attachments,
      tags: tags,
    );
  }
}
