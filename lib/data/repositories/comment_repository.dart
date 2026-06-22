import 'package:software_for_nature/data/models/comment.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/comment_repository_interface.dart';

class CommentRepository  extends BaseRepository<Comment> implements CommentRepositoryInterface {

  CommentRepository({ required super.jsonClient });

  /// Returns the comments for a single event, oldest first.
  @override
  Future<List<Comment>> getForEvent(String eventId) async {
    final all = await getAll();
    return all.where((c) => c.eventId == eventId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Creates  a new comment on [eventId] the created [Comment] is returned
  @override
  Future<Comment> addComment({required String eventId, required String author, required String text}) {
    final comment = Comment(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      eventId: eventId,
      author: author,
      text: text.trim(),
      timestamp: DateTime.now(),
    );
    return create(comment);
  }
}
