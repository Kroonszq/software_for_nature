import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: BlocBuilder<TimelineBloc, TimelineState>(
        builder: (context, state) {
          if (state is TimelineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TimelineLoaded) {
            return ListView(
              children: state.posts.map((post) {
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.timestamp.toString()),
                  onTap: () {
                    context.read<TimelineBloc>().add(
                          SelectTimelineEvent(post),
                        );
                  },
                );
              }).toList(),
            );
          }

          return const Center(child: Text("No timeline data"));
        },
      ),
    );
  }
}