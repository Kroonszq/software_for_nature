import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_event.dart';
import 'package:software_for_nature/logic/bloc/event_selection/event_selection_state.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

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

          if (state is MapLoaded) {
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(52.0907, 5.1214),
                initialZoom: 10,
                onPositionChanged: (position, hasGesture) {
                  final bounds =
                      mapController.camera.visibleBounds;

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
                BlocBuilder<EventSelectionBloc, EventSelectionState>(
                  builder: (context, selectionState) {
                    return MarkerLayer(
                      markers: state.visiblePosts.map((event) {
                        final isSelected =
                            selectionState.selected.contains(event);

                        return Marker(
                          point: event.coordinates!.latLng,
                          width: 40,
                          height: 40,
                          child: MouseRegion(
                            onEnter: (_) {
                              context.read<EventSelectionBloc>().add(
                                HoverEvent(event),
                              );
                            },
                            onExit: (_) {
                              context.read<EventSelectionBloc>().add(
                                HoverEvent(null),
                              );
                            },
                            child: GestureDetector(
                              onTap: () {
                                context.read<EventSelectionBloc>().add(
                                  SelectEvent(event),
                                );
                              },
                              child: Icon(
                                Icons.location_pin,
                                color: isSelected
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                ),
                BlocBuilder<EventSelectionBloc, EventSelectionState>(
                  builder: (context, state) {
                    if (state.hovered == null) return const SizedBox();

                    return Positioned(
                      left: 20,
                      top: 20,
                      child: Material(
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(state.hovered!.title),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return const Center(child: Text("No map data"));
        },
      ),
    );
  }
}
