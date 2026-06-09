import 'package:software_for_nature/data/data_sources/event_post_api_client.dart';
import 'package:software_for_nature/data/models/event_query.dart';

import '../models/event_post.dart';

import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';


class EventPostRepository {
  List<EventPost>? _cache;
  final EventPostApiClient _apiClient;

  EventPostRepository({
    EventPostApiClient? apiClient,
  }) : _apiClient = apiClient ?? EventPostApiClient();

  Future<List<EventPost>> queryEvents(EventQuery query) async {
    // 1. Load or reuse full dataset
    if (_cache == null) {
      final posts = await _apiClient.fetchEventPosts();
      _cache = posts;
    }

    var results = _cache!;

    // 2. Apply bounds filter
    if (query.bounds != null) {
      results = results.where((event) {
        final c = event.coordinates;
        if (c == null) return false;
        return query.bounds!.contains(c);
      }).toList();
    }

    // 3. Apply time filter
    if (query.timeRange != null) {
      results = results.where((event) {
        final start = event.startDuration;
        final end = event.endDuration;

        return end.isAfter(query.timeRange!.start) &&
               start.isBefore(query.timeRange!.end);
      }).toList();
    }

    return results;
  }

  Future<EventPost?> getFirstEvent() async {
    final events = await _apiClient.fetchEventPosts(
      query: const EventQuery(),
      order: "asc",
      limit: 1,
    );

    if (events.isEmpty) return null;
    return events.first;
  }

  Future<EventPost?> getLastEvent() async {
    final events = await _apiClient.fetchEventPosts(
      query: const EventQuery(),
      order: "desc",
      limit: 1,
    );

    if (events.isEmpty) return null;
    return events.first;
  }

  // Future<List<EventPost>> getEventPosts() async {
  //   // only return cache if it already has data
  //   if (_cache != null && _cache!.isNotEmpty) {
  //     return _cache!;
  //   }

  //   final posts = await _apiClient.fetchEventPosts();

  //   print("REPOSITORY OUTPUT: ${posts.length}");

  //   _cache = posts;
  //   return posts;
  // }
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

