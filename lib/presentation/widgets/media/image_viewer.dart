import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String source;

  const ImageViewer({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(source),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }
}