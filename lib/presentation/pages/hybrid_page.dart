import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:software_for_nature/data/adapters/coordinates_latlng_adapter.dart';
import 'package:software_for_nature/data/adapters/geobounds_latlngbounds_adapter.dart';

import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';

import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';

import 'package:software_for_nature/presentation/widgets/filter.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/map/event_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/hybrid_map_marker.dart';
import 'package:software_for_nature/presentation/widgets/map/map.dart';
import 'package:software_for_nature/presentation/widgets/map/zoom_button.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_view.dart';

class HybridPage extends StatefulWidget {
  const HybridPage({super.key});

  @override
  State<HybridPage> createState() => _HybridPageState();
}

class _HybridPageState extends State<HybridPage> {
  final MapController mapController = MapController();
  Map<String, Color> _categoryColors = const {};

  @override
  void initState() {
    super.initState();
    _loadCategoryColors();
  }

  Future<void> _loadCategoryColors() async {
    final categories = await context.read<CategoryServiceInterface>().getAllCategories();
    if (!mounted) {
      return;
    }

    setState(() {
      _categoryColors = {for (final c in categories) c.id: c.color};
    });
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
            categoryService: context.read<CategoryServiceInterface>(),
          ),
        ),
        BlocProvider(
          create: (context) => FilterBloc(
            categoryService: context.read<CategoryServiceInterface>(),
            eventService: context.read<EventServiceInterface>(),
          )..add(FilterStarted()),
        ),
      ],
      // Forward filter changes to BOTH the timeline wrapper and the map's
      // HybridBloc so the two stay in sync when something is filtered.
      child: BlocListener<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterLoaded) {
            final activeCategories = state.activeCategories ?? const <Category>[];
            final tagLabels = (state.activeTags ?? const []).map((t) => t.label).toSet();

            context.read<TimeLinesWrapperBloc>().add(
              FilterChanged(
                activeCategories: activeCategories,
                tagLabels: tagLabels,
                startDate: state.startDate,
                endDate: state.endDate,
                searchQuery: state.searchQuery ?? '',
              ),
            );

            context.read<HybridBloc>().add(
              HybridFilterChanged(
                categoryIds: activeCategories.map((c) => c.id).toSet(),
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

        final visibleCategoryIds = state.timelines.values
            .where((t) => t.active)
            .expand((t) => t.events.map((e) => e.categoryId))
            .toSet();
        context
            .read<HybridBloc>()
            .add(HybridVisibleCategoriesChanged(visibleCategoryIds));

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
                  color: _categoryColors[event.categoryId] ?? Colors.blue,
                ),
              );
            })
            .toList();

        return Stack(
          children: [
            EventMap(
              mapController: mapController,
              markers: markers,
              categoryColors: _categoryColors,
              timeWindow: timeWindow,
              onBoundsChanged: (bounds) =>
                  context.read<HybridBloc>().add(HybridBoundsChanged(bounds)),
            ),

            // Zoom controls in the bottom-right corner.
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZoomButton(
                    icon: Icons.add,
                    heroTag: 'hybrid_zoom_in',
                    onPressed: () => _zoom(1),
                  ),
                  const SizedBox(height: 8),
                  ZoomButton(
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
