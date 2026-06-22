import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';

enum AttachmentKind { image, text, other }

abstract final class AttachmentService {
  const AttachmentService._();

  static const Set<String> _imageExtensions = { 'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp' };
  static const Set<String> _textExtensions = { 'txt', 'csv', 'json', 'md', 'log', 'xml', 'yaml', 'yml'};

  static String extensionOf(EventAttachment attachment) {
    final name = attachment.name;
    final dot = name.lastIndexOf('.');
    
    if (dot < 0 || dot == name.length - 1){ 
      return '';
    }

    return name.substring(dot + 1).toLowerCase();
  }

  static AttachmentKind kindOf(EventAttachment attachment) {
    final ext = extensionOf(attachment);
    if (_imageExtensions.contains(ext)) {
      return AttachmentKind.image;
    }

    if (_textExtensions.contains(ext)) { 
      return AttachmentKind.text;
    }

    return AttachmentKind.other;
  }


  static Future<File?> resolveFile(EventAttachment attachment) async {
    if (kIsWeb) {
      return null;
    }

    final path = attachment.path;
    if (path == null || path.isEmpty) { 
      return null;
    }

    final direct = File(path);
    if (await direct.exists()) {
      return direct;
    }

    final dir = await getApplicationDocumentsDirectory();
    final resolved = File('${dir.path}/$path');
    if (await resolved.exists()){
      return resolved;
    }

    return null;
  }

  static Future<String?> download(EventAttachment attachment) async {
    final file = await resolveFile(attachment);
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save attachment',
      fileName: attachment.name,
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
