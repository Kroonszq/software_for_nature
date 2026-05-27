part of 'navigation_bloc.dart';

@immutable
sealed class NavigationEvent {}

final class NavigateToRoute extends NavigationEvent {
  final String route;

  NavigateToRoute(this.route);

}