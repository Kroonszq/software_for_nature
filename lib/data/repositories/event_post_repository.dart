import 'package:software_for_nature/data/data_sources/event_post_api_client.dart';

import '../models/event_post.dart';

class EventPostRepository {
  List<EventPost>? _cache;
  final EventPostApiClient _apiClient;

  EventPostRepository({
    EventPostApiClient? apiClient,
  }) : _apiClient = apiClient ?? EventPostApiClient();

  Future<List<EventPost>> getEventPosts() async {
    // only return cache if it already has data
    if (_cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }

    final posts = await _apiClient.fetchEventPosts();

    print("REPOSITORY OUTPUT: ${posts.length}");

    _cache = posts;
    return posts;
  }
}

  //these don't work with the current 'Mock' EventPostApiClient
  // Future<void> addEventPost(EventPost post) async {
  //   _cache.add(post);
  // }

  // Future<void> updateEventPost(EventPost updated) async {
  //   final index = _cache.indexWhere((p) => p.id == updated.id);

  //   if (index != -1) {
  //     _cache[index] = updated;
  //   }
  // }

  // Future<void> deleteEventPost(String id) async {
  //   _cache.removeWhere((p) => p.id == id);
  // }
//}

