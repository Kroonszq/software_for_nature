
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/comment.dart';
import 'package:software_for_nature/data/repositories/comment_repository.dart';

class EventComments extends StatelessWidget {

  final String eventId;

  const EventComments({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: context.read<CommentRepository>().getForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final comments = snapshot.data ?? const <Comment>[];
        if (comments.isEmpty) {
          return const Center(
            child: Text('No comments yet', style: TextStyle(color: Colors.black54)),
          );
        }
        return ListView.separated(
          itemCount: comments.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, i) {
            final c = comments[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      TimeUtils.formatDateTime(c.timestamp),
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.text),
              ],
            );
          },
        );
      },
    );
  }
}