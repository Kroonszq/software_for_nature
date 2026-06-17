import 'package:software_for_nature/data/models/event_attachment.dart';

abstract interface class AttachmentStorageInterface {
  
  Future<List<EventAttachment>> persistAll(List<EventAttachment> attachments, String eventId);

  Future<String> resolve(String relativePath);
}
