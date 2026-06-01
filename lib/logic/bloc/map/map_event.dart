part of 'map_bloc.dart';

sealed class MapEvent {}

class LoadMapEvents extends MapEvent {}

class SelectMapEvent extends MapEvent {
  final EventPost post;

  SelectMapEvent(this.post);
}

class UpdateMapBounds extends MapEvent {
  final GeoBounds bounds;

  UpdateMapBounds(this.bounds);
}