import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewer extends StatefulWidget {
  final String source;

  const PdfViewer({super.key, required this.source});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late PdfController controller;

  @override
  void initState() {
    super.initState();

    controller = PdfController(
      document: PdfDocument.openFile(widget.source),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(controller: controller);
  }
}