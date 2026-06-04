import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/media.dart';
import 'package:software_for_nature/presentation/widgets/media/image_viewer.dart';
import 'package:software_for_nature/presentation/widgets/media/media_viewer.dart';
import 'package:software_for_nature/presentation/widgets/media/pdf_viewer.dart';
import 'package:software_for_nature/presentation/widgets/media/video_viewer.dart';

class MediaViewerPage extends StatelessWidget {
  final List<Media> media;

  const MediaViewerPage({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView(
        children: media.map((m) {
          return switch (m) {
            ImageMedia() => ImageViewer(source: m.source),
            VideoMedia() => VideoViewer(source: m.source),
            PdfMedia() => PdfViewer(source: m.source),
          };
        }).toList(),
      )
    );
  }
}