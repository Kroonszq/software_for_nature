
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
    return InkWell(
      onTap: () => AttachmentPreviewDialog.show(context, attachment),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              tooltip: 'Preview',
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