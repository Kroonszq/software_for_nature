import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';

import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is! MapLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final markers = mapState.visiblePosts.map((e) {
            return Marker(
              point: e.coordinates!.latLng,
              width: MapMarker.markerWidth,
              height: MapMarker.markerHeight,
              child: MapMarker(event: e),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: const LatLng(52.09, 5.12),
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
                      size: const Size(45, 45),

                      spiderfyCluster: true,
                      zoomToBoundsOnClick: false,

                      builder: (context, clusterMarkers) {
                        return _ClusterMarker(
                          count: clusterMarkers.length,
                        );
                      },
                    ),
                  ),
                ],
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
