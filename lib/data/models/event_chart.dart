
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

  // Value equality: two points with the same coordinates are the same point.
  // Without this, the form's chart removal (which filters by `!=`) would rely on
  // object identity and could fail to drop the intended point/chart.
  @override
  bool operator ==(Object other) =>
      other is ChartPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
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

  // Value equality: two charts built from the same file, labels and points are
  // the same chart. The event form removes a chart with
  // `state.charts.where((c) => c != chart)`; relying on object identity there is
  // fragile (a re-hydrated copy from the repository is a different instance with
  // the same data), so compare by value instead.
  @override
  bool operator ==(Object other) {
    if (other is! EventChart) return false;
    if (other.fileName != fileName ||
        other.xLabel != xLabel ||
        other.yLabel != yLabel ||
        other.points.length != points.length) {
      return false;
    }
    for (var i = 0; i < points.length; i++) {
      if (other.points[i] != points[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(fileName, xLabel, yLabel, Object.hashAll(points));
}
