import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/pages/groups_page.dart';
import 'package:software_for_nature/presentation/pages/hybrid_page.dart';
import 'package:software_for_nature/presentation/pages/map_page.dart';
import 'package:software_for_nature/presentation/pages/timeline_page.dart';
import 'package:software_for_nature/presentation/pages/user_page.dart';

class AppRoutes {

  static const String timeline = '/timeline';
  static const String map = '/map';
  static const String hybrid = '/hybrid';
  static const String groups = '/groups';
  static const String user = '/user';

  static const Map<String, String> navRoutes = {
    'Timeline': timeline,
    'Map': map,
    'Hybrid' : hybrid,
    'Groups' : groups
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
        return buildRoute(const TimelinePage());
      case map:
        return buildRoute(const MapPage());
      case hybrid:
        return buildRoute(const HybridPage());
      case groups:
        return buildRoute(const GroupsPage());
      case user:
        return buildRoute(const UserPage());
      default:
        return buildRoute(const TimelinePage());
    }
  }

}