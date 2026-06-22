import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:software_for_nature/data/models/event_post.dart';

enum ExportFormat {
  json('JSON', 'json'),
  csv('CSV', 'csv');

  const ExportFormat(this.label, this.extension);

  final String label;
  final String extension;
}

abstract final class EventExporter {
  const EventExporter._();

  /// Serializes [events] to a UTF-8 string in the given [format].
  static String serialize(List<EventPost> events, ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(events.map((e) => e.toJson()).toList());
      case ExportFormat.csv:
        return _toCsv(events);
    }
  }

  static String _toCsv(List<EventPost> events) {
    final rows = <List<dynamic>>[
      [
        'id',
        'title',
        'description',
        'createdAt',
        'timestamp',
        'startDuration',
        'endDuration',
        'groupId',
        'userId',
        'lat',
        'lng',
        'tags',
      ],
      for (final e in events)
        [
          e.id,
          e.title,
          e.description,
          e.createdAt.toIso8601String(),
          e.timestamp?.toIso8601String() ?? '',
          e.startDuration.toIso8601String(),
          e.endDuration.toIso8601String(),
          e.groupId,
          e.userId,
          e.coordinates?.lat ?? '',
          e.coordinates?.lng ?? '',
          e.tags.map((t) => t.label).join('|'),
        ],
    ];
    return const CsvEncoder().convert(rows);
  }


  static Future<String?> save(List<EventPost> events, ExportFormat format) async {
    final content = serialize(events, format);
    final bytes = Uint8List.fromList(utf8.encode(content));
    final fileName =
        'events_export_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export events',
      fileName: fileName,
      bytes: bytes,
    );

    if (path == null) {
      return null;
    }

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return path;
  }
}
