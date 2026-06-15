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
}
