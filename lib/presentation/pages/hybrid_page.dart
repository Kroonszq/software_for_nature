import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/logic/bloc/event/event_post_bloc.dart';
import 'package:software_for_nature/logic/bloc/event/event_post_event.dart';
import 'package:software_for_nature/logic/bloc/event/event_post_state.dart';

import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';

import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_view.dart';

class HybridPage extends StatefulWidget {
  const HybridPage({super.key});

  @override
  State<HybridPage> createState() => _HybridPageState();
}

class _HybridPageState extends State<HybridPage> {
  final MapController mapController = MapController();

  void _onMapMove(MapCamera camera) {
    final bounds = mapController.camera.visibleBounds.toDomain();

    context.read<EventPostBloc>().add(
          SetMapBounds(bounds),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Row(
        children: [
          // ================= TIMELINE =================
          Expanded(
            flex: 1,
            child: BlocProvider(
              create: (context) => TimeLinesWrapperBloc(
                context.read(),
              ),
              child: BlocProvider(
                create: (_) => TimelineBloc(),
                child: const TimelineView(),
              ),
            ),
          ),

          // ================= MAP =================
          Expanded(
            flex: 1,
            child: BlocBuilder<EventPostBloc, EventPostState>(
              builder: (context, state) {
                if (state is! EventPostLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mapEvents = state.posts.where((e) {
                  final c = e.coordinates;
                  if (c == null) return false;

                  final bounds = state.bounds;
                  if (bounds == null) return true;

                  return bounds.contains(c);
                }).toList();

                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(52.0907, 5.1214),
                    initialZoom: 10,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) _onMapMove(position);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.myapp',
                    ),

                    MarkerLayer(
                      markers: mapEvents.map((event) {
                        return Marker(
                          point: event.coordinates!.latLng,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}