import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';

import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/presentation/widgets/map/cluster_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/event_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/map_marker.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/timeline_navigator.dart';
import 'package:software_for_nature/presentation/widgets/event/event_view_drawer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

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
      ],
      child: Layout(
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
                child: MapMarker(
                  event: e,
                  timeWindow: window,
                ),
              );
            }).toList();

            return Stack(
              children: [
                // 1. MAP (always bottom)
                FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(52.09, 5.12),
                    initialZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.software_for_nature.app',
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        markers: markers,
                        maxClusterRadius: 70,
                        size: const Size(60, 60),
                        spiderfyCluster: true,
                        zoomToBoundsOnClick: false,
                        builder: (context, clusterMarkers) {
                          final eventMarkers =
                              clusterMarkers.cast<EventMarker>();

                          return ClusterMarker(
                            count: eventMarkers.length,
                            events: eventMarkers.map((m) => m.event).toList(),
                            timeWindow: window,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // 2. TIMELINE NAVIGATOR (kept low priority)
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
                // 3. EVENT DRAWER (MUST BE ABOVE EVERYTHING UI-RELATED)
                const EventViewDrawer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
