part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState {}

final class NavigationInitial extends NavigationState {}

class NavigationRouteChanged extends NavigationState {
  final String route;
  NavigationRouteChanged(this.route);
}
