import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';

final class AttachmentStorage implements AttachmentStorageInterface{
  
  Future<EventAttachment> persist(EventAttachment attachment, String eventId) async {
    final source = attachment.path;
    if (source == null) return attachment;

    final dir = await getApplicationDocumentsDirectory();
    final destDir = Directory('${dir.path}/attachments/$eventId');
    await destDir.create(recursive: true);

    final relativePath = 'attachments/$eventId/${attachment.name}';
    await File(source).copy('${dir.path}/$relativePath');

    return EventAttachment(
      name: attachment.name,
      path: relativePath,
      size: attachment.size,
    );
  }

  @override
  Future<List<EventAttachment>> persistAll(List<EventAttachment> attachments, String eventId) {
    return Future.wait(attachments.map((a) => persist(a, eventId)));
  }

  @override
  Future<String> resolve(String relativePath) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$relativePath';
  }
}
