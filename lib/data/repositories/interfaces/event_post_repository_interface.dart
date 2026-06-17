
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/repositories/interfaces/base_repository_interface.dart';

abstract interface class EventPostRepositoryInterface implements BaseRepositoryInterface<EventPost>  {

  Future<List<EventPost>?> getAllByGroupId(String id);

  /// Returns the events matching every supplied criterion. A `null`/empty
  /// criterion is ignored (i.e. it does not filter anything out).
  Future<List<EventPost>> query({
    Set<String>? groupIds,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  });
}