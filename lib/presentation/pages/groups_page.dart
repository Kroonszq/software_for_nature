import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_cubit.dart';
import 'package:software_for_nature/logic/cubit/group/group_cubit.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/group_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';
import 'package:software_for_nature/presentation/widgets/group/groups_body.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EventInteractionCubit()),
        BlocProvider(
          create: (context) => GroupCubit(
            groupService: context.read<GroupServiceInterface>(),
            categoryService: context.read<CategoryServiceInterface>(),
            userService: context.read<UserServiceInterface>(),
          )..load(),
        ),
      ],
      child: Layout(
        child: const GroupsBody(),
      ),
    );
  }
}
