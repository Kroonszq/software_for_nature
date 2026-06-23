import 'dart:io';

import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/attachment_service.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/presentation/widgets/event/attachment_preview_dialog.dart';

class EventContent extends StatelessWidget {

  final EventPost event;

  const EventContent({super.key, required this.event});
  
  @override
  Widget build(BuildContext context) {



    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description.
          const SizedBox(height: 16),
            Text('Description', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            event.description.isEmpty ? '—' : event.description,
          ),

          // Attachments.
          if (event.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Attachments (${event.attachments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            ...event.attachments.map(
              (a) => _AttachmentTile(attachment: a),
            ),
          ],

          // Charts.
          if (event.charts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Charts (${event.charts.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

            const SizedBox(height: 4),
            ...event.charts.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.fileName} · ${c.xLabel}/${c.yLabel} '
                        '(${c.points.length} points)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}


class _AttachmentTile extends StatelessWidget {
  final EventAttachment attachment;

  const _AttachmentTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    // Attachments whose contents we can render (images, text) are shown inline
    // right here in the details; everything else stays a plain row.
    final kind = AttachmentService.kindOf(attachment);
    final canPreviewInline =
        kind == AttachmentKind.image || kind == AttachmentKind.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(attachment.name, overflow: TextOverflow.ellipsis),
              ),
              if (attachment.size != null) ...[
                const SizedBox(width: 8),
                Text(
                  TimeUtils.formatSize(attachment.size!),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
              // Expand to a full-screen-ish modal for a closer look.
              IconButton(
                icon: const Icon(Icons.open_in_full, size: 18),
                tooltip: 'Open preview',
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    AttachmentPreviewDialog.show(context, attachment),
              ),
              IconButton(
                icon: const Icon(Icons.download, size: 18),
                tooltip: 'Download',
                visualDensity: VisualDensity.compact,
                onPressed: () => _download(context),
              ),
            ],
          ),
          if (canPreviewInline) ...[
            const SizedBox(height: 4),
            _InlineAttachmentPreview(attachment: attachment),
          ],
        ],
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    String? savedPath;
    Object? error;

    try {
      savedPath = await AttachmentService.download(attachment);
    } catch (e) {
      error = e;
    }

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Download failed: $error')),
      );
    } else if (savedPath != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Saved to $savedPath')),
      );
    }
  }
}

/// Renders an image or text attachment inline within the event details. The
/// file is resolved asynchronously; while it loads it shows a small spinner,
/// and if it can't be resolved/displayed it falls back to a short notice.
class _InlineAttachmentPreview extends StatelessWidget {
  final EventAttachment attachment;

  const _InlineAttachmentPreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: AttachmentService.resolveFile(attachment),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final file = snapshot.data;
        if (file == null) {
          return _notice('This file is not available on this device.');
        }

        switch (AttachmentService.kindOf(attachment)) {
          case AttachmentKind.image:
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: Image.file(
                  file,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (context, error, stackTrace) =>
                      _notice('Could not display this image.'),
                ),
              ),
            );
          case AttachmentKind.text:
            return FutureBuilder<String>(
              future: file.readAsString(),
              builder: (context, textSnapshot) {
                if (textSnapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (textSnapshot.hasError) {
                  return _notice('This file can\'t be previewed as text.');
                }
                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      textSnapshot.data ?? '',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            );
          case AttachmentKind.other:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _notice(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
    );
  }
}