
import 'package:software_for_nature/data/models/comment.dart';
import 'package:software_for_nature/data/repositories/interfaces/base_repository_interface.dart';

abstract interface class CommentRepositoryInterface implements BaseRepositoryInterface<Comment>
 {
   Future<List<Comment>> getForEvent(String eventId);

   /// Creates and persists a new comment on [eventId].
   Future<Comment> addComment({
     required String eventId,
     required String author,
     required String text,
   });
}