import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';

import '../models/event_post.dart';

class EventPostRepository extends BaseRepository<EventPost> implements EventPostRepositoryInterface {

  EventPostRepository({required super.jsonClient});
  
  @override
  Future<List<EventPost>?> getAllByGroupId(String id) async {
    var allEvents = await getAll();

    var filtered = allEvents.where((event) => event.groupId == id);
    return filtered.toList();
  }

  @override
  Future<List<EventPost>> query({
    Set<String>? groupIds,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) async {
    final allEvents = await getAll();

    final String? normalizedSearch =
        (search == null || search.trim().isEmpty) ? null : search.toLowerCase();

    return allEvents.where((event) {
      if (groupIds != null &&
          groupIds.isNotEmpty &&
          !groupIds.contains(event.groupId)) {
        return false;
      }

      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }

      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }

      if (normalizedSearch != null &&
          !event.title.toLowerCase().contains(normalizedSearch) &&
          !event.description.toLowerCase().contains(normalizedSearch)) {
        return false;
      }

      return true;
    }).toList();
  }

}

