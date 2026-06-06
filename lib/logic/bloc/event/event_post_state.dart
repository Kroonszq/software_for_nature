import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/geobounds.dart';

import '../../../data/models/event_post.dart';

sealed class EventPostState {}

class EventPostInitial extends EventPostState {}

class EventPostLoading extends EventPostState {}

class EventPostLoaded extends EventPostState {
  final List<EventPost> posts;
  final EventPost? selectedPost;

  final GeoBounds? bounds;
  final DateTimeRange? timeRange;

  EventPostLoaded({
    required this.posts,
    this.selectedPost,
    this.bounds,
    this.timeRange,
  });

  EventPostLoaded copyWith({
    List<EventPost>? posts,
    EventPost? selectedPost,
    GeoBounds? bounds,
    DateTimeRange? timeRange,
  }) {
    return EventPostLoaded(
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      bounds: bounds ?? this.bounds,
      timeRange: timeRange ?? this.timeRange,
    );
  }
}

class EventPostError extends EventPostState {
  final String message;

  EventPostError(this.message);
}