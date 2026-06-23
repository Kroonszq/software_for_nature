
class ChartPoint {
  final String x;
  final double y;

  const ChartPoint({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      x: json['x'].toString(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

class EventChart {
  final String fileName;
  final String xLabel;
  final String yLabel;
  final List<ChartPoint> points;

  const EventChart({
    required this.fileName,
    required this.xLabel,
    required this.yLabel,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'xLabel': xLabel,
        'yLabel': yLabel,
        'points': points.map((p) => p.toJson()).toList(),
      };

  factory EventChart.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    return EventChart(
      fileName: json['fileName']?.toString() ?? 'chart',
      xLabel: json['xLabel']?.toString() ?? 'x',
      yLabel: json['yLabel']?.toString() ?? 'y',
      points: rawPoints is List
          ? rawPoints
              .map((p) => ChartPoint.fromJson(p as Map<String, dynamic>))
              .toList()
          : const <ChartPoint>[],
    );
  }
}
