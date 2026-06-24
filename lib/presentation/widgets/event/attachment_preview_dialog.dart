import 'dart:io';

import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/attachment_service.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';


class AttachmentPreviewDialog extends StatelessWidget {
  final EventAttachment attachment;

  const AttachmentPreviewDialog({super.key, required this.attachment});

  /// Opens the preview for [attachment] as a modal dialog.
  static Future<void> show(BuildContext context, EventAttachment attachment) {
    return showDialog<void>(
      context: context,
      builder: (_) => AttachmentPreviewDialog(attachment: attachment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with name + close.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body: the resolved file, previewed by type.
            Flexible(
              child: FutureBuilder<File?>(
                future: AttachmentService.resolveFile(attachment),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final file = snapshot.data;
                  if (file == null) {
                    return _placeholder(
                      icon: Icons.broken_image_outlined,
                      message: 'This file is not available on this device.',
                    );
                  }

                  return _buildPreview(file);
                },
              ),
            ),
            const Divider(height: 1),

            // Footer: download.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: _DownloadButton(attachment: attachment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(File file) {
    switch (AttachmentService.kindOf(attachment)) {
      case AttachmentKind.image:
        return InteractiveViewer(
          child: Center(
            child: Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _placeholder(
                icon: Icons.broken_image_outlined,
                message: 'Could not display this image.',
              ),
            ),
          ),
        );
      case AttachmentKind.text:
        return FutureBuilder<String>(
          future: file.readAsString(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return _placeholder(
                icon: Icons.description_outlined,
                message: 'This file can\'t be previewed as text.',
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                snapshot.data ?? '',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            );
          },
        );
      case AttachmentKind.other:
        return _placeholder(
          icon: Icons.visibility_off_outlined,
          message: 'No inline preview for this file type.\n'
              'Use Download to open it in another app.',
        );
    }
  }

  Widget _placeholder({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button that downloads the attachment
class _DownloadButton extends StatefulWidget {
  final EventAttachment attachment;

  const _DownloadButton({required this.attachment});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _busy = false;

  Future<void> _download() async {
    setState(() => _busy = true);

    String? savedPath;
    Object? error;
    try {
      savedPath = await AttachmentService.download(widget.attachment);
    } catch (e) {
      error = e;
    }

    if (!mounted) return;
    setState(() => _busy = false);

    final messenger = ScaffoldMessenger.of(context);
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

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _busy ? null : _download,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: Text(_busy ? 'Saving…' : 'Download'),
    );
  }
}
