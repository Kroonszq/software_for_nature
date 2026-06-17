
import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';

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
              (a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(a.name, overflow: TextOverflow.ellipsis),
                    ),
                    if (a.size != null)
                      Text(
                        TimeUtils.formatSize(a.size!),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                  ],
                ),
              ),
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