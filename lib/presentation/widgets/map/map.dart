import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/presentation/widgets/map/cluster_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/event_marker.dart';

class EventMap extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;

  final Map<String, Color> categoryColors;
  final TimeWindow? timeWindow;
  final ValueChanged<GeoBounds> onBoundsChanged;

  final LatLng initialCenter;
  final double initialZoom;

  const EventMap({
    super.key,
    required this.mapController,
    required this.markers,
    required this.onBoundsChanged,
    this.categoryColors = const {},
    this.timeWindow,
    this.initialCenter = const LatLng(52.0907, 5.1214),
    this.initialZoom = 10,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            onBoundsChanged(mapController.camera.visibleBounds.toDomain());
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.software_for_nature.app',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            markers: markers,
            maxClusterRadius: 70,
            size: const Size(60, 60),
            spiderfyCluster: true,
            zoomToBoundsOnClick: true,
            spiderfyCircleRadius: 110,
            spiderfySpiralDistanceMultiplier: 2,
            markerChildBehavior: true,
            builder: (context, clusterMarkers) {
              final eventMarkers = clusterMarkers.cast<EventMarker>();
              final window = timeWindow;
              if (window == null) {
                return _ClusterCountBubble(count: eventMarkers.length);
              }

              return ClusterMarker(
                count: eventMarkers.length,
                events: eventMarkers.map((m) => m.event).toList(),
                timeWindow: window,
                categoryColors: categoryColors,
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ClusterCountBubble extends StatelessWidget {
  final int count;

  const _ClusterCountBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
