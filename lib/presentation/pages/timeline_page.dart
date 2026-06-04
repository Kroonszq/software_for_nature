import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/pages/mediaviewer_page.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';
import 'package:software_for_nature/presentation/widgets/media/media_viewer.dart';

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
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];

                final media = post.media;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.timestamp.toString()),

                    // 🖼 MEDIA PREVIEW (first item if exists)
                    leading: media != null && media.isNotEmpty
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: MediaViewer(media: media.first),
                          )
                        : const Icon(Icons.event),

                    onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaViewerPage(media: post.media!)
                        ),
                      );
                    }
                  ),
                );
              },
            );
          }

          return const Center(child: Text("No timeline data"));
        },
      ),
    );
  }
}