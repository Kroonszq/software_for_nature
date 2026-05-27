import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/pages/map_page.dart';
import 'package:software_for_nature/presentation/pages/timeline_page.dart';

class AppRoutes {

  static const String timeline = '/timeline';
  static const String map = '/map';

  static const Map<String, String> navRoutes = {
    'Timeline': timeline,
    'Map': map
  };

  static Route buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero
    );
  }

  static Route onGeneratedRoute(RouteSettings settings)
  {
    switch(settings.name) {
      case timeline:
        return buildRoute(const TimeLinePage());
      case map:
        return buildRoute(const MapPage());
      default:
        return buildRoute(const TimeLinePage());
    }
  }

}