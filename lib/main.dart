import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:software_for_nature/app_routes.dart';
import 'package:software_for_nature/data/data_sources/json_client.dart';
import 'package:software_for_nature/data/models/comment.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/comment_repository.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/data/repositories/group_repository.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/bloc/minimized_events/minimized_events_bloc.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/observer.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const Observer();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EventPostRepository>(
          create: (_) => EventPostRepository(
            jsonClient: JsonClient<EventPost>(
              assetPath: 'assets/data/event.json',
              fromJson: EventPost.fromJson,
              logger: Logger(printer: PrettyPrinter()),
            ),
          ),
        ),
        RepositoryProvider<CommentRepository>(
          create: (_) => CommentRepository(
            jsonClient: JsonClient<Comment>(
              assetPath: 'assets/data/comment.json',
              fromJson: Comment.fromJson,
              logger: Logger(printer: PrettyPrinter()),
            ),
          ),
        ),
        RepositoryProvider<GroupRepository>(
          create: (_) => GroupRepository(
            jsonClient: JsonClient<Group>(
              assetPath: 'assets/data/group.json',
              fromJson: Group.fromJson,
              logger: Logger(printer: PrettyPrinter()),
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => TimelineBloc()),
          BlocProvider(create: (_) => NavigationBloc()),
          BlocProvider(create: (_) => MinimizedEventsBloc()),
          BlocProvider(
            create: (context) =>
            MapBloc(context.read<EventPostRepository>())
            ..add(LoadMapEvents()),
          ),
        ], 
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Software for nature',
          initialRoute: AppRoutes.timeline,
          onGenerateRoute: AppRoutes.onGeneratedRoute
        ),
      )
    );
  }
}

