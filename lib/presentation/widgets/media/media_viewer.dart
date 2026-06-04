import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/media.dart';
import 'image_viewer.dart';
import 'video_viewer.dart';
import 'pdf_viewer.dart';

class MediaViewer extends StatelessWidget {
  final Media media;

  const MediaViewer({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return switch (media) {
      ImageMedia() => ImageViewer(
          source: media.source
        ),

      VideoMedia() => VideoViewer(
          source: media.source
        ),

      PdfMedia() => PdfViewer(
          source: media.source
        ),

      _ => const SizedBox(),
    };
  }
}