import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';

import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

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

    context.read<HybridBloc>().add(
      HybridBoundsChanged(bounds),
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
              child: BlocListener<TimeLinesWrapperBloc, TimeLinesWrapperState>(
                listener: (context, state) {
                  // OPTIONAL BRIDGE:
                  // sync selection into HybridBloc if needed
                  if (state is TimeLinesWrapperLoaded &&
                      state.timelines.isNotEmpty) {
                    final selected = state.allEvents.firstOrNull;

                    if (selected != null) {
                      context.read<HybridBloc>().add(
                        HybridEventSelected(selected),
                      );
                    }
                  }
                },
                child: const TimelineView(),
              ),
            ),
          ),

          // ================= MAP =================
          Expanded(
            flex: 1,
            child: BlocBuilder<HybridBloc, HybridState>(
              builder: (context, state) {
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
                      markers: state.events
                          .where((e) => e.coordinates != null)
                          .map((event) {
                        final isSelected =
                            state.selectedEvent == event;

                        return Marker(
                          point: event.coordinates!.latLng,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_pin,
                            color: isSelected ? Colors.red : Colors.blue,
                          ),
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