import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';

import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';
import 'package:software_for_nature/presentation/widgets/filter.dart';
import 'package:software_for_nature/presentation/widgets/map/event_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/map.dart';
import 'package:software_for_nature/presentation/widgets/map/map_marker.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/map/zoom_button.dart';
import 'package:software_for_nature/presentation/widgets/timeline_navigator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  Map<String, Color> _categoryColors = const {};

  @override
  void initState() {
    super.initState();
    _loadCategoryColors();
  }

  Future<void> _loadCategoryColors() async {
    final categories = await context.read<CategoryServiceInterface>().getAllCategories();
    if (!mounted) {
      return;
    }

    setState(() {
      _categoryColors = {for (final c in categories) c.id: c.color};
    });
  }

  void _zoom(double delta) {
    final camera = mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(1.0, 18.0);
    mapController.move(camera.center, newZoom);

    context.read<MapBloc>().add(
      UpdateMapBounds(mapController.camera.visibleBounds.toDomain()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EventInteractionCubit()),
        BlocProvider(
          create: (context) =>
              MapBloc(context.read<EventPostRepository>())
                ..add(LoadMapEvents()),
        ),
        BlocProvider(
          create: (context) => FilterBloc(
            categoryService: context.read<CategoryServiceInterface>(),
            eventService: context.read<EventServiceInterface>(),
          )..add(FilterStarted()),
        ),
      ],

      child: BlocListener<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterLoaded) {
            context.read<MapBloc>().add(
              MapFilterChanged(
                categoryIds: (state.activeCategories ?? const []).map((c) => c.id).toSet(),
                tagLabels: (state.activeTags ?? const []).map((t) => t.label).toSet(),
                startDate: state.startDate,
                endDate: state.endDate,
                search: state.searchQuery,
              ),
            );
          }
        },
        child: Layout(
          child: Column(
            children: [
              const Filter(),
              Expanded(
                child: BlocBuilder<MapBloc, MapState>(
                  builder: (context, mapState) {
                    if (mapState is! MapLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final TimeWindow window = mapState.timeWindow;

                    final markers = mapState.visiblePosts.map((e) {
                      return EventMarker(
                        event: e,
                        point: e.coordinates!.latLng,
                        width: MapMarker.markerWidth,
                        height: MapMarker.markerHeight,
                        alignment: Alignment.topCenter,
                        child: MapMarker(
                          event: e,
                          timeWindow: window,
                          color: _categoryColors[e.categoryId] ?? Colors.blue,
                        ),
                      );
                    }).toList();

                    return Stack(
                      children: [
                        
                        // Map
                        EventMap(
                          mapController: mapController,
                          markers: markers,
                          categoryColors: _categoryColors,
                          timeWindow: window,
                          initialCenter: const LatLng(52.09, 5.12),
                          onBoundsChanged: (bounds) => context
                              .read<MapBloc>()
                              .add(UpdateMapBounds(bounds)),
                        ),

                        // Navigatior
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: TimelineNavigator(
                              minTime: mapState.earliest.startDuration,
                              maxTime: mapState.latest.endDuration,
                              window: window,
                              onChanged: (newWindow) {
                                context.read<MapBloc>().add(UpdateTimeWindow(newWindow));
                              },
                            ),
                          ),
                        ),

                        // Zoom controls
                        Positioned(
                          right: 12,
                          bottom: 90,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ZoomButton(
                                icon: Icons.add,
                                heroTag: 'map_zoom_in',
                                onPressed: () => _zoom(1),
                              ),
                              const SizedBox(height: 8),
                              ZoomButton(
                                icon: Icons.remove,
                                heroTag: 'map_zoom_out',
                                onPressed: () => _zoom(-1),
                              ),
                            ],
                          ),
                        ),
                        //const EventViewDrawer(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
