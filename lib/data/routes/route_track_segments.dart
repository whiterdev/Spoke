const routeTrackMaximumGap = Duration(seconds: 30);

bool isRouteTrackGap(DateTime previous, DateTime current) =>
    current.difference(previous) > routeTrackMaximumGap;

bool startsNewRouteTrackSegment({
  required int previousSequence,
  required int currentSequence,
  required DateTime previousRecordedAt,
  required DateTime currentRecordedAt,
}) =>
    currentSequence != previousSequence + 1 ||
    isRouteTrackGap(previousRecordedAt, currentRecordedAt);

List<List<T>> splitRouteTrackAtGaps<T>(
  List<T> points, {
  required int Function(T point) sequence,
  required DateTime Function(T point) recordedAt,
}) {
  if (points.isEmpty) return const [];

  final segments = <List<T>>[];
  var segment = <T>[];
  for (final point in points) {
    if (segment.isNotEmpty &&
        startsNewRouteTrackSegment(
          previousSequence: sequence(segment.last),
          currentSequence: sequence(point),
          previousRecordedAt: recordedAt(segment.last),
          currentRecordedAt: recordedAt(point),
        )) {
      segments.add(segment);
      segment = <T>[];
    }
    segment.add(point);
  }
  if (segment.isNotEmpty) segments.add(segment);
  return segments;
}
