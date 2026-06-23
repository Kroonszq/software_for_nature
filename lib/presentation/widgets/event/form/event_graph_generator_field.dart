import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/chart_generator.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';
import 'package:software_for_nature/presentation/widgets/event/event_chart_view.dart';


class EventGraphGeneratorField extends StatelessWidget {
  const EventGraphGeneratorField({super.key});

  Future<void> _generate(BuildContext context, EventFormBloc bloc) async {
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['csv', 'json'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.first;

    try {
      // Prefer the in-memory bytes (works on web too); fall back to the path.
      String content;
      if (picked.bytes != null) {
        content = utf8.decode(picked.bytes!);
      } else if (picked.path != null) {
        content = await File(picked.path!).readAsString();
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Could not read the selected file.')));
        return;
      }

      final chart = ChartGenerator.fromFile(
        fileName: picked.name,
        content: content,
      );
      bloc.add(ChartAdded(chart));
      
      messenger.showSnackBar(SnackBar(content: Text('Graph generated from ${picked.name}')));
    } on ChartGenerationException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate a graph: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate a graph: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) => prev.charts != curr.charts,
      builder: (context, state) {
        final bloc = context.read<EventFormBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Graph generator'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _generate(context, bloc),
                  icon: const Icon(Icons.auto_graph),
                  label: const Text('Generate from CSV/JSON'),
                ),
              ],
            ),
            if (state.charts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Add a CSV or JSON file to automatically generate a graph.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ...state.charts.map(
              (chart) => _ChartPreview(
                chart: chart,
                onRemove: () => bloc.add(ChartRemoved(chart)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartPreview extends StatelessWidget {
  final EventChart chart;
  final VoidCallback onRemove;

  const _ChartPreview({required this.chart, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${chart.fileName} · ${chart.points.length} points',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Remove graph',
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 4),
          EventChartView(chart: chart, height: 160),
        ],
      ),
    );
  }
}
