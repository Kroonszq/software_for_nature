import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/minimized_events_stack.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_side_bar.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_view.dart';
import 'package:software_for_nature/presentation/widgets/filter.dart';


class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

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
      child: BlocListener<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterLoaded) {
            context.read<TimeLinesWrapperBloc>().add(
                  FilterChanged(
                    activeGroups: state.activeGroups ?? const <Group>[],
                    tagLabels:
                        (state.activeTags ?? const []).map((t) => t.label).toSet(),
                    startDate: state.startDate,
                    endDate: state.endDate,
                    searchQuery: state.searchQuery ?? '',
                  ),
                );
          }
        },
        child: Layout(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 700;

              return Column(
                children: [
                  const Filter(),
                  if (isCompact)
                    const Expanded(
                      child: Column(
                        children: [
                          Expanded(child: TimelineView()),
                          TimelineSideBar(axis: Axis.horizontal),
                          MinimizedEventsStack(axis: Axis.horizontal),
                        ],
                      ),
                    )
                  else
                    const Expanded(child: TimelineView()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}