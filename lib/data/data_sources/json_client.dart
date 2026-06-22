import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:software_for_nature/data/data_sources/interfaces/json_client_interface.dart';
import 'package:software_for_nature/data/models/json_model.dart';


class JsonClient<T extends JsonModel> implements JsonClientInterface<T> {
  final String _assetPath;
  final Logger _logger;
  final T Function(Map<String, dynamic>) _fromJson;

  final int _seedVersion;

  File? _cachedFile;

  JsonClient({
    required this._assetPath,
    required this._logger,
    required this._fromJson,
    this._seedVersion = 0,
  });

  Future<File> _localFile() async {
    if (_cachedFile != null) return _cachedFile!;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = _assetPath.split('/').last;
    final file = File('${dir.path}/$fileName');

    final marker = File('${dir.path}/$fileName.seedversion');

    final bool needsSeed = !await file.exists() ||
        !await marker.exists() ||
        (await marker.readAsString()).trim() != '$_seedVersion';

    if (needsSeed) {
      final seed = await rootBundle.loadString(_assetPath);
      await file.writeAsString(seed);
      await marker.writeAsString('$_seedVersion');
    }

    return _cachedFile = file;
  }

  @override
  Future<List<T>?> readJson() async {
    try {
      final file = await _localFile();
      final rawContent = await file.readAsString();
      final content = jsonDecode(rawContent) as List<dynamic>;

      final items = <T>[];
      for (final item in content) {
        items.add(_fromJson(item as Map<String, dynamic>));
      }

      return items;
    } catch (e) {
      _logger.e("Something unexpected happend while trying to read json file: $_assetPath", error: e);
      return null;
    }
  }

  @override
  Future<void> writeJson(List<T> items) async {
    try {
      final file = await _localFile();
      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    } catch (e) {
      _logger.e("Something unexpected happend while trying to write json file: $_assetPath", error: e);
    }
  }
}
