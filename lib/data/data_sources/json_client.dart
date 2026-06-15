import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:software_for_nature/data/data_sources/interfaces/json_client_interface.dart';
import 'package:software_for_nature/data/models/json_model.dart';

/// Generic reader/writer for a JSON array.
class JsonClient<T extends JsonModel> implements JsonClientInterface<T> {
  final String _assetPath;
  final Logger _logger;
  final T Function(Map<String, dynamic>) _fromJson; 

  JsonClient({required this._assetPath, required this._logger, required this._fromJson});

  @override
  Future<List<T>?> readJson() async {
    try
    {
        if(!await File(_assetPath).exists())
        {
          throw Exception("Could not find path $_assetPath");
        }

        var rawContent = await File(_assetPath).readAsString();
        final content = jsonDecode(rawContent) as List<dynamic>;

        final items = <T>[];
        for(final item in content)
        {
            items.add(_fromJson(item as Map<String, dynamic>));
        }

        return items;
    }
    catch(e) 
    {
      _logger.e("Something unexpected happend while trying to read json file: $_assetPath", error: e);
      return null;
    }
  }
  
  @override
  Future<void> writeJson(List<T> items) async {
    try
    {
      final file = File(_assetPath);
      if (!await file.exists()) {
        throw Exception("Could not find path $_assetPath");
      }

      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    }
    catch(e) 
    {
      _logger.e("Something unexpected happend while trying to write json file: $_assetPath", error: e);
    }
  }

}
