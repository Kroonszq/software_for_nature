import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/comment.dart';
import 'package:software_for_nature/data/repositories/comment_repository.dart';

class EventComments extends StatefulWidget {
  final String eventId;

  const EventComments({super.key, required this.eventId});

  @override
  State<EventComments> createState() => _EventCommentsState();
}

class _EventCommentsState extends State<EventComments> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _load();
  }

  @override
  void didUpdateWidget(covariant EventComments oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // reload when the panel switches to a different event.
    if (oldWidget.eventId != widget.eventId) {
      setState(() {
        _commentsFuture = _load();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Comment>> _load() => context.read<CommentRepository>().getForEvent(widget.eventId);

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting){
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<CommentRepository>().addComment(
            eventId: widget.eventId,
            author: 'You',
            text: text,
          );

      _controller.clear();
      if (!mounted) {
        return;
      }

      setState(() {
        _commentsFuture = _load();
      });

    } finally {
      if (mounted){ 
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final comments = snapshot.data ?? const <Comment>[];
            if (comments.isEmpty) {
              return const Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
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
        ),
        const Divider(height: 16),
        _Composer(
          controller: _controller,
          submitting: _submitting,
          onSubmit: _submit,
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  const _Composer({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              hintText: 'Write a comment…',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        submitting
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton.filled(
                icon: const Icon(Icons.send),
                tooltip: 'Post comment',
                onPressed: onSubmit,
              ),
      ],
    );
  }
}
