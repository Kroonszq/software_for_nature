/// A file attached to an event. Holds enough metadata to display the file in
/// the UI and (when available) the on-disk path to open or read it.
class EventAttachment {
  final String name;
  final String? path;
  final int? size;

  const EventAttachment({
    required this.name,
    this.path,
    this.size,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (path != null) 'path': path,
        if (size != null) 'size': size,
      };

  factory EventAttachment.fromJson(Map<String, dynamic> json) {
    return EventAttachment(
      name: json['name'] as String,
      path: json['path'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );
  }
}
