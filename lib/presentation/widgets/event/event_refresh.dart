import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_bloc.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

typedef EventRefresher = void Function();

// This makes sure it refreshes for now it fixes it :)
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
