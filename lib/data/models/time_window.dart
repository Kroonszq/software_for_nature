class TimeWindow {
  final DateTime start;
  final DateTime end;

  const TimeWindow({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime time) {
    return !time.isBefore(start) && !time.isAfter(end);
  }
}