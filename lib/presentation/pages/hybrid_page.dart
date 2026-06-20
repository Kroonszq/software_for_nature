import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';

import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';

import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/minimized_events/minimized_events_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

import 'package:software_for_nature/presentation/widgets/filter.dart';
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

    context.read<HybridBloc>().add(HybridBoundsChanged(bounds));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
          )..add(FilterStarted()),
        ),
      ],
      // Forward filter changes to BOTH the timeline wrapper and the map's
      // HybridBloc so the two stay in sync when something is filtered.
      child: BlocListener<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterLoaded) {
            final activeGroups = state.activeGroups ?? const <Group>[];

            context.read<TimeLinesWrapperBloc>().add(
              FilterChanged(
                activeGroups: activeGroups,
                startDate: state.startDate,
                endDate: state.endDate,
                searchQuery: state.searchQuery ?? '',
              ),
            );

            context.read<HybridBloc>().add(
              HybridFilterChanged(
                groupIds: activeGroups.map((g) => g.id).toSet(),
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
                child: Row(
                  children: [
                    // ================= TIMELINE =================
                    Expanded(
                      flex: 1,
                      child:
                          BlocListener<
                            TimeLinesWrapperBloc,
                            TimeLinesWrapperState
                          >(
                            listener: (context, state) {
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
                            child: const TimelineView(overlaySidebar: true),
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
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          // Hovering a pin highlights the
                                          // matching card in the timeline and
                                          // scrolls it into view.
                                          onEnter: (_) => context
                                              .read<TimelineBloc>()
                                              .add(FocusTimelineEvent(event)),
                                          onExit: (_) => context
                                              .read<TimelineBloc>()
                                              .add(UnSelectTimelineEvent()),
                                          child: GestureDetector(
                                            // Clicking a pin opens the event in
                                            // the drawer and selects it on the
                                            // map.
                                            onTap: () {
                                              context.read<HybridBloc>().add(
                                                HybridEventSelected(event),
                                              );
                                              context
                                                  .read<MinimizedEventsBloc>()
                                                  .add(OpenEvent(event));
                                              Scaffold.of(context).openDrawer();
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
                                    })
                                    .toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
