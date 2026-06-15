/// A single (x, y) data point for an [EventChart]. The x value is kept as a
/// label so categorical CSV columns (names, dates, …) render correctly; the y
/// value is numeric.
class ChartPoint {
  final String x;
  final double y;

  const ChartPoint({required this.x, required this.y});
}

/// A chart derived from an uploaded CSV file: the user picks which column maps
/// to the x axis and which maps to the y axis at event-creation time, and the
/// resulting series is stored here so the event view can render it.
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
}
