import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/app_routes.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:software_for_nature/observer.dart';


void main() {
  Bloc.observer = const Observer();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc())
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Software for nature',
        initialRoute: AppRoutes.timeline,
        onGenerateRoute: AppRoutes.onGeneratedRoute
      ),
    );
  }
}

