import 'package:software_for_nature/data/models/json_model.dart';

/// A comment left by someone under an event.
class Comment implements JsonModel {
  @override
  final String id;
  final String eventId;
  final String author;
  final String text;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.eventId,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      eventId: json['eventId'].toString(),
      author: json['author'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'author': author,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };
}
