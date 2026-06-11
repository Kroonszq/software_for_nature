import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/data/models/time_window.dart';

import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_state.dart';

import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';

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
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! MapLoaded) {
            return const Center(child: Text("No map data"));
          }

          final minTime = state.earliest!.startDuration;
          final maxTime = state.latest!.endDuration;

          final window = state.timeWindow ??
              TimeWindow(start: minTime, end: maxTime);

          return Stack(
            children: [
              // MAP
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(52.0907, 5.1214),
                  initialZoom: 10,
                  onPositionChanged: (position, hasGesture) {
                    final bounds = mapController.camera.visibleBounds;

                    context.read<MapBloc>().add(
                      UpdateMapBounds(bounds.toDomain()),
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.myapp',
                  ),

                  MarkerLayer(
                    markers: state.visiblePosts.map((event) {
                      return Marker(
                        point: event.coordinates!.latLng,
                        width: 60,
                        height: 60,
                        child: MapMarker(event: event),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // HOVER POPUP
              BlocBuilder<EventSelectionBloc, EventSelectionState>(
                builder: (context, selectionState) {
                  if (selectionState.hovered == null) {
                    return const SizedBox();
                  }

                  return Positioned(
                    left: 20,
                    top: 20,
                    child: Material(
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(selectionState.hovered!.title),
                      ),
                    ),
                  );
                },
              ),

              // TIMELINE NAVIGATOR
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TimelineNavigator(
                    minTime: minTime,
                    maxTime: maxTime,
                    window: window,
                    onChanged: (newWindow) {
                      context.read<MapBloc>().add(
                        UpdateTimeWindow(newWindow),
                      );
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