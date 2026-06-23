
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/interfaces/base_repository_interface.dart';

abstract interface class EventPostRepositoryInterface implements BaseRepositoryInterface<EventPost>  {

   /// Returns the events matching every criterion given in [query] argument
  Future<List<EventPost>> queryEvents(EventQuery query);

  /// The event that starts first [EventPost.startDuration]
  Future<EventPost> getEarliestEvent();

  /// The event that ends last [EventPost.endDuration]
  Future<EventPost> getLatestEvent();

  Future<List<EventPost>?> getAllByCategoryId(String categoryId);
}