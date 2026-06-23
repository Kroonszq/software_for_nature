import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_chart.dart';


class EventChartView extends StatelessWidget {
  final EventChart chart;
  final double height;

  const EventChartView({super.key, required this.chart, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final points = chart.points;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].y),
    ];

    final color = Theme.of(context).colorScheme.primary;

    final labelEvery = (points.length / 6).ceil().clamp(1, points.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${chart.yLabel} by ${chart.xLabel}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: points.length <= 30),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black12),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: labelEvery.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          points[index].x,
                          style: const TextStyle(fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
