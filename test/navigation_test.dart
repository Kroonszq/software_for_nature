import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/app_routes.dart';
import 'package:software_for_nature/logic/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:software_for_nature/presentation/widgets/navigation.dart';
import 'package:software_for_nature/presentation/widgets/navigation/nav_button.dart';

void main()
{
    Widget buildSubject() {
      return MaterialApp(
        onGenerateRoute: AppRoutes.onGeneratedRoute,
        home: BlocProvider(
          create: (_) => NavigationBloc(),
          child: Scaffold(
            appBar: Navigation(),
            body: Container(),
          ),
        ),
      );
    }

    group('Navigation', () {
    
      testWidgets('renders all route buttons', (tester) async {
        await tester.pumpWidget(buildSubject());

        for(final label in AppRoutes.navRoutes.keys) {
          expect(find.text(label), findsOneWidget);
        }
      });

      testWidgets('renders create event button', (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.text('Create event'), findsOneWidget);
      });

      testWidgets('timeline is active by default', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Retrieve the widget from the application
        final NavButton timelineButton = tester.widget(
          find.byWidgetPredicate(
            (widget) => widget is NavButton && widget.route == AppRoutes.timeline
          )
        );

        expect(timelineButton.isActive, true);
      });

      // Check if the state changes when NavigateToRoute event is fired
      blocTest(
        'changes state when event is fired', 
        build: () => NavigationBloc(),
        act: (bloc) => bloc.add(NavigateToRoute(AppRoutes.timeline)),
        expect: () => [
          isA<NavigationRouteChanged>().having(
            (state) => state.route,
            'route',
            AppRoutes.timeline
          )
        ]
      );


    });


   

    
}