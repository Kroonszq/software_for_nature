import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';
import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/json_model.dart';

class EventPost implements JsonModel<EventPost> {
  @override
  final String id;
  
  final String title;
  final String description;
  final DateTime timestamp;
  final DateTime startDuration;
  final DateTime endDuration;
  final Group group;
  final Coordinates? coordinates;
  final List<EventAttachment> attachments;
  final List<EventChart> charts;

  const EventPost({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.startDuration,
    required this.endDuration,
    required this.group,
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
    Group? group,
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
      group: group ?? this.group,
      coordinates: coordinates ?? this.coordinates,
      attachments: attachments ?? this.attachments,
      charts: charts ?? this.charts,
    );
  }

  @override
  Map<String, dynamic> toJson()
  {
    return {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'startDuration': startDuration.toIso8601String(),
        'endDuration': endDuration.toIso8601String(),
        'group': {
          'title': group.title,
          'color': ColorUtils.toHex(group.color),
        },
        if (coordinates != null)
          'coordinates': {
            'lat': coordinates!.lat,
            'lng': coordinates!.lng,
          },
    };
  }
      
  factory EventPost.fromJson(Map<String, dynamic> json) 
  {
    final groupJson = json['group'];
    final group = groupJson is Map<String, dynamic>
        ? Group(
            id: groupJson['id']?.toString() ?? '',
            title: groupJson['title'] as String,
            color: ColorUtils.fromHex(groupJson['color']),
          )
        : const Group(id: 'ungrouped', title: 'Ungrouped', color: Colors.grey);

    Coordinates? coordinates;
    final coord = json['coordinates'];
    if (coord is Map<String, dynamic>) {
      coordinates = Coordinates(
        lat: (coord['lat'] as num).toDouble(),
        lng: (coord['lng'] as num).toDouble(),
      );
    }

    return EventPost(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      startDuration: DateTime.parse(json['startDuration'] as String),
      endDuration: DateTime.parse(json['endDuration'] as String),
      group: group,
      coordinates: coordinates,
    );
  }
}
