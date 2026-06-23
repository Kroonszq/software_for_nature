import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

/// A callback that re-fetches event data on the blocs it captured.
typedef EventRefresher = void Function();

/// Captures the event-displaying blocs currently in scope and returns a
/// callback that reloads them. Capturing the bloc references up-front means the
/// refresh still works even if [context] is later unmounted (e.g. because the
/// originating drawer/panel closed). Each page wires up only some of these
/// blocs, so missing ones are skipped.
EventRefresher captureEventRefresh(BuildContext context) {
  final actions = <void Function()>[];

  final timeline = _tryRead<TimeLinesWrapperBloc>(context);
  if (timeline != null) {
    actions.add(() {
      if (!timeline.isClosed) timeline.add(LoadTimelineEvents());
    });
  }

  final hybrid = _tryRead<HybridBloc>(context);
  if (hybrid != null) {
    actions.add(() {
      if (!hybrid.isClosed) hybrid.add(HybridReloadRequested());
    });
  }

  final map = _tryRead<MapBloc>(context);
  if (map != null) {
    actions.add(() {
      if (!map.isClosed) map.add(LoadMapEvents());
    });
  }

  return () {
    for (final action in actions) {
      action();
    }
  };
}

T? _tryRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } on ProviderNotFoundException {
    return null;
  }
}
