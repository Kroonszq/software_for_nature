import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';

import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_state.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';

import 'package:software_for_nature/presentation/widgets/map/map_marker.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/timeline_navigator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  bool spiderfyMode = false;
  bool clusterSelected = false;
  Set<EventPost> spiderfiedEvents = {};

  void _resetSpiderfy() {
    setState(() {
      spiderfyMode = false;
      spiderfiedEvents.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is! MapLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = mapState.visiblePosts;

          final markers = posts.map((e) {
            final isSpiderfied = spiderfiedEvents.contains(e);

            return Marker(
              point: e.coordinates!.latLng,
              width: MapMarker.markerWidth,
              height: MapMarker.markerHeight,
              child: MapMarker(
                event: e,
                spiderfied: isSpiderfied,
              ),
            );
          }).toList();

          return Stack(
            children: [
              Listener(
                onPointerDown: (_) {
                  if (spiderfyMode) {
                    setState(() {
                      spiderfyMode = false;
                      spiderfiedEvents.clear();
                    });
                  }
                },
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(52.09, 5.12),
                    initialZoom: 10,
                    onTap: (_, __) => _resetSpiderfy(),
                
                    onMapEvent: (event) {
                      if (event is MapEventMoveStart) {
                        debugPrint('AAAAAAAAAAAAAAAAAAAAAAA');
                        _resetSpiderfy();
                        setState(() {
                          // rebuild triggers full recluster
                        });
                      }
                    },
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture) _resetSpiderfy();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.software_for_nature.app',
                    ),
                
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        markers: markers,
                        maxClusterRadius: 70,
                        size: const Size(46, 46),
                
                        spiderfyCluster: true,
                        zoomToBoundsOnClick: false,
                
                        onClusterTap: (cluster) {
                          setState(() {
                            spiderfyMode = true;
                            spiderfiedEvents = cluster.markers
                                .map((m) => mapState.visiblePosts.firstWhere(
                                      (p) =>
                                          p.coordinates!.latLng == m.point,
                                    ))
                                .toSet();
                          });
                        },
                              
                        builder: (context, clusterMarkers) {
                          return _ClusterMarker(
                            count: clusterMarkers.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /// 🟡 SPIDERFY HALO (FIXED: local, not full-screen)
              if (spiderfyMode)
                _ClusterHalo(
                  mapController: mapController,
                  events: spiderfiedEvents.toList(),
                ),

              /// 🟣 HOVER POPUP (RESTORED)
              BlocBuilder<EventSelectionBloc, EventSelectionState>(
                builder: (context, state) {
                  final hovered = state.hovered;

                  if (hovered == null || hovered.coordinates == null) {
                    return const SizedBox();
                  }

                  final pos = mapController.camera
                      .latLngToScreenOffset(hovered.coordinates!.latLng);

                  return Positioned(
                    left: pos.dx + 12,
                    top: pos.dy - 40,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(hovered.title),
                      ),
                    ),
                  );
                },
              ),

              /// TIMELINE
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TimelineNavigator(
                    minTime: mapState.earliest.startDuration,
                    maxTime: mapState.latest.endDuration,
                    window: mapState.timeWindow,
                    onChanged: (w) {
                      context.read<MapBloc>().add(UpdateTimeWindow(w));
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  final int count;

  const _ClusterMarker({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}


class _ClusterHalo extends StatelessWidget {
  final MapController mapController;
  final List<EventPost> events;

  const _ClusterHalo({
    required this.mapController,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox();

    final center = _computeCenter(events);
    final screen = mapController.camera.latLngToScreenOffset(center);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: screen.dx - 120,
            top: screen.dy - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _computeCenter(List<EventPost> events) {
    final lat = events
            .map((e) => e.coordinates!.latLng.latitude)
            .reduce((a, b) => a + b) /
        events.length;

    final lng = events
            .map((e) => e.coordinates!.latLng.longitude)
            .reduce((a, b) => a + b) /
        events.length;

    return LatLng(lat, lng);
  }
}