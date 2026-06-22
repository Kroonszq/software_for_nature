import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';

import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';

import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';

import 'package:software_for_nature/presentation/widgets/filter.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/map/cluster_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/event_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/hybrid_map_marker.dart';
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

    context.read<HybridBloc>().add(HybridBoundsChanged(bounds));
  }

  /// Zoom in/out
  void _zoom(double delta) {
    final camera = mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(1.0, 18.0);

    mapController.move(camera.center, newZoom);

    context.read<HybridBloc>().add(
          HybridBoundsChanged(
            mapController.camera.visibleBounds.toDomain(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EventInteractionCubit()),
        BlocProvider(
          create: (context) => TimeLinesWrapperBloc(
            eventPostRepository: context.read<EventPostRepository>(),
            groupRepository: context.read<GroupRepositoryInterface>(),
            userRepository: context.read<UserRepositoryInterface>(),
          ),
        ),
        BlocProvider(
          create: (context) => FilterBloc(
            groupRepositoryInterface: context.read<GroupRepositoryInterface>(),
            eventPostRepositoryInterface: context.read<EventPostRepository>(),
          )..add(FilterStarted()),
        ),
      ],
      // Forward filter changes to BOTH the timeline wrapper and the map's
      // HybridBloc so the two stay in sync when something is filtered.
      child: BlocListener<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterLoaded) {
            final activeGroups = state.activeGroups ?? const <Group>[];
            final tagLabels =
                (state.activeTags ?? const []).map((t) => t.label).toSet();

            context.read<TimeLinesWrapperBloc>().add(
              FilterChanged(
                activeGroups: activeGroups,
                tagLabels: tagLabels,
                startDate: state.startDate,
                endDate: state.endDate,
                searchQuery: state.searchQuery ?? '',
              ),
            );

            context.read<HybridBloc>().add(
              HybridFilterChanged(
                groupIds: activeGroups.map((g) => g.id).toSet(),
                tagLabels: tagLabels,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 700;

                    // On mobile stack the map above the timeline; on wider
                    // screens show them side by side.
                    if (isCompact) {
                      return Column(
                        children: [
                          Expanded(flex: 1, child: _buildMap(context)),
                          Expanded(flex: 1, child: _buildTimeline(context)),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 1, child: _buildTimeline(context)),
                        Expanded(flex: 1, child: _buildMap(context)),
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

  // ================= TIMELINE =================
  Widget _buildTimeline(BuildContext context) {
    return BlocListener<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      listener: (context, state) {
        if (state is! TimeLinesWrapperLoaded) return;

        final visibleGroupIds = state.timelines.values
            .where((t) => t.active)
            .expand((t) => t.events.map((e) => e.groupId))
            .toSet();
        context
            .read<HybridBloc>()
            .add(HybridVisibleGroupsChanged(visibleGroupIds));

        final selected = state.allEvents.firstOrNull;
        if (selected != null) {
          context.read<HybridBloc>().add(HybridEventSelected(selected));
        }
      },
      child: const TimelineView(overlaySidebar: true),
    );
  }

  // ================= MAP =================
  Widget _buildMap(BuildContext context) {
    return BlocBuilder<HybridBloc, HybridState>(
      builder: (context, state) {
        final timeWindow = state.timeWindow;

        final markers = state.events
            .where((e) => e.coordinates != null)
            .map((event) {
              final isSelected = state.selectedEvent == event;

              return EventMarker(
                event: event,
                point: event.coordinates!.latLng,
                width: HybridMapMarker.width,
                height: HybridMapMarker.height,
                alignment: Alignment.topCenter,
                child: HybridMapMarker(
                  event: event,
                  isSelected: isSelected,
                ),
              );
            })
            .toList();

        return Stack(
          children: [
            FlutterMap(
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

                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    markers: markers,
                    maxClusterRadius: 70,
                    size: const Size(60, 60),
                    spiderfyCluster: true,
                    zoomToBoundsOnClick: false,
                    builder: (context, clusterMarkers) {
                      final eventMarkers = clusterMarkers.cast<EventMarker>();

                      // Fall back to a plain count bubble until the HybridBloc
                      // has initialised its time window.
                      if (timeWindow == null) {
                        return _ClusterCountBubble(
                          count: eventMarkers.length,
                        );
                      }

                      return ClusterMarker(
                        count: eventMarkers.length,
                        events: eventMarkers.map((m) => m.event).toList(),
                        timeWindow: timeWindow,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Zoom controls in the bottom-right corner.
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    heroTag: 'hybrid_zoom_in',
                    onPressed: () => _zoom(1),
                  ),
                  const SizedBox(height: 8),
                  _ZoomButton(
                    icon: Icons.remove,
                    heroTag: 'hybrid_zoom_out',
                    onPressed: () => _zoom(-1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A plain circular bubble showing the number of events in a cluster, used as
/// a fallback before the time window (and therefore the richer [ClusterMarker])
/// is available.
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

/// A small circular map control button used for the zoom in/out actions.
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String heroTag;
  final VoidCallback onPressed;

  const _ZoomButton({
    required this.icon,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 2,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
