import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:software_for_nature/data/models/event_chart.dart';


class ChartGenerationException implements Exception {
  final String message;
  const ChartGenerationException(this.message);

  @override
  String toString() => message;
}

/// Reads a CSV or JSON file and tries to build a chart from it
class ChartGenerator {
  static EventChart fromFile({
    required String fileName,
    required String content,
  }) {
    final name = fileName.toLowerCase();

    // check the file extension
    if (name.endsWith('.json')) {
      return _fromJson(fileName, content);
    }

    if (name.endsWith('.csv')) {
      return _fromCsv(fileName, content);
    }

    // unknown extension so we have to guess from how the content starts
    final start = content.trimLeft();
    if (start.startsWith('{') || start.startsWith('[')) {
      return _fromJson(fileName, content);
    }
    return _fromCsv(fileName, content);
  }

  static EventChart _fromCsv(String fileName, String content) {
    final rows = Csv(dynamicTyping: true).decode(content).where((row) => row.isNotEmpty).toList();

    if (rows.length < 2) {
      throw const ChartGenerationException('The CSV needs a header row and at least one data row.');
    }

    final header = rows.first.map((c) => c.toString()).toList();
    final data = rows.skip(1).toList();

    // first column is the labels for the values pick the column after the first that has the most numbers in it
    var yColumn = -1;
    var bestRatio = 0.0;
    for (var col = 1; col < header.length; col++) {
      var numeric = 0;
      for (final row in data) {
        if (col < row.length && _toNumber(row[col]) != null) numeric++;
      }

      final ratio = numeric / data.length;
      if (ratio > bestRatio) {
        bestRatio = ratio;
        yColumn = col;
      }
    
    }

    if (yColumn == -1) {
      throw const ChartGenerationException('No numeric column found to plot on the y axis',);
    }

    final points = <ChartPoint>[];
    for (final row in data) {
      if (yColumn >= row.length){
        continue;
      }

      final y = _toNumber(row[yColumn]);

      if (y == null){
        continue;
      }

      points.add(ChartPoint(x: row[0].toString(), y: y));
    }

    if (points.isEmpty) {
      throw const ChartGenerationException('No plottable rows were found');
    }

    return EventChart(
      fileName: fileName,
      xLabel: header[0],
      yLabel: header[yColumn],
      points: points,
    );
  }

  static EventChart _fromJson(String fileName, String content) {
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw const ChartGenerationException('The file is not valid JSON');
    }

    if (decoded is List){
      return _fromJsonList(fileName, decoded);
    } 

    if (decoded is Map) {
       return _fromJsonMap(fileName, decoded);
    }

    throw const ChartGenerationException('Unsupported JSON structure');
  }

  // Handles json lists
  static EventChart _fromJsonList(String fileName, List<dynamic> list) {
    if (list.isEmpty) {
      throw const ChartGenerationException('The JSON array is empty');
    }

    // Just a list of numbers plot each one against its index
    if (list.every((e) => e is num)) {
      final points = [
        for (var i = 0; i < list.length; i++)
          ChartPoint(x: '$i', y: (list[i] as num).toDouble()),
      ];

      return EventChart(
        fileName: fileName,
        xLabel: 'index',
        yLabel: 'value',
        points: points,
      );
    }

    // otherwise it's a list of objects then use the first numeric key for y and the first other key for x
    final maps = list.whereType<Map>().toList();
    if (maps.isEmpty) {
      throw const ChartGenerationException('Could not find chartable objects in the JSON array');
    }

    final keys = maps.first.keys.map((k) => k.toString()).toList();
    String? yKey;
    for (final key in keys) {
      if (_toNumber(maps.first[key]) != null) {
        yKey = key;
        break;
      }
    }

    if (yKey == null) {
      throw const ChartGenerationException('No numeric field found to plot on the y axis',);
    }
    
    final xKey = keys.firstWhere((k) => k != yKey, orElse: () => yKey!);

    final points = <ChartPoint>[];
    for (final map in maps) {
      final y = _toNumber(map[yKey]);
      if (y == null){
        continue;
      }

      final x = (map[xKey] ?? points.length).toString();
      points.add(ChartPoint(x: x, y: y));
    }
    
    if (points.isEmpty) {
      throw const ChartGenerationException('No plottable entries were found.');
    }

    return EventChart(
      fileName: fileName,
      xLabel: xKey,
      yLabel: yKey,
      points: points,
    );
  }

  // Handles json maps
  static EventChart _fromJsonMap(String fileName, Map<dynamic, dynamic> map) {
    final points = <ChartPoint>[];
    map.forEach((key, value) {
      
      final y = _toNumber(value);
      if (y != null) {
        points.add(ChartPoint(x: key.toString(), y: y));
      }

    });

    if (points.isEmpty) {
      throw const ChartGenerationException('The JSON object has no numeric values to plot');
    }

    return EventChart(
      fileName: fileName,
      xLabel: 'key',
      yLabel: 'value',
      points: points,
    );
  }

  // returns the value as a double, or null when it isnt a number
  static double? _toNumber(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }
}
