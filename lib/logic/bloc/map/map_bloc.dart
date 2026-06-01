import 'package:bloc/bloc.dart';
import '../../../data/models/event_post.dart';
import '../../../data/repositories/event_post_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventPostRepository repository;

  MapBloc(this.repository) : super(MapInitial()) {
    on<LoadMapEvents>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMapEvents event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    final posts = await repository.getEventPosts();

    final mapPosts = posts
        .where((e) => e.coordinates != null)
        .toList();

    emit(MapLoaded(mapPosts));
  }
}