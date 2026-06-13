import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';

import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';

import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_state.dart';

import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/map/map_marker.dart';
import 'package:software_for_nature/presentation/widgets/timeline_navigator.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return Layout(
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mapState is! MapLoaded) {
            return const Center(child: Text("No map data"));
          }

          final minTime = mapState.earliest.startDuration;
          final maxTime = mapState.latest.endDuration;

          return Stack(
            children: [
              /// ---------------- MAP ----------------
              MouseRegion(
                onExit: (_) { //to not show popup when cursor leaves map
                  context.read<EventSelectionBloc>().add(ClearHoverEvent());
                },
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(52.0907, 5.1214),
                    initialZoom: 10,
                
                    onPositionChanged: (position, hasGesture) {
                      final bounds =
                          mapController.camera.visibleBounds;
                
                      context.read<MapBloc>().add(
                        UpdateMapBounds(bounds.toDomain()),
                      );
                      if (hasGesture) { //to not show pop-up while dragging the map
                        context.read<EventSelectionBloc>().add(ClearHoverEvent());
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.myapp',
                    ),
                
                    /// ---------------- MARKERS ----------------
                    MarkerLayer(
                      markers: mapState.visiblePosts.map((event) {
                        final latLng = event.coordinates!.latLng;
                
                        return Marker(
                          point: latLng,
                          width: 60,
                          height: 60,
                          child: MouseRegion(
                            onEnter: (_) {
                              context
                                  .read<EventSelectionBloc>()
                                  .add(HoverEvent(event));
                            },
                            onExit: (_) {
                              context
                                  .read<EventSelectionBloc>()
                                  .add(ClearHoverEvent());
                            },
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<EventSelectionBloc>()
                                    .add(SelectEvent(event));
                              },
                              child: MapMarker(event: event),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              /// ---------------- HOVER / POPUP ----------------
              BlocBuilder<EventSelectionBloc, EventSelectionState>(
                builder: (context, selectionState) {
                  final hovered = selectionState.hovered;

                  if (hovered == null ||
                      hovered.coordinates == null) {
                    return const SizedBox();
                  }

                  final screenPos = mapController.camera
                      .latLngToScreenOffset(
                        hovered.coordinates!.latLng,
                      );

                  return Positioned(
                    left: screenPos.dx + 12,
                    top: screenPos.dy - 40,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(hovered.title),
                      ),
                    ),
                  );
                },
              ),

              /// ---------------- TIMELINE ----------------
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TimelineNavigator(
                    minTime: minTime,
                    maxTime: maxTime,
                    window: mapState.timeWindow,
                    onChanged: (newWindow) {
                      context
                          .read<MapBloc>()
                          .add(UpdateTimeWindow(newWindow));
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