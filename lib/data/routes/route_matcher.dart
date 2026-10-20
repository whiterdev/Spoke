import 'dart:math' as math;

class RouteCoordinate {
  const RouteCoordinate(
    this.latitude,
    this.longitude, {
    this.startsNewSegment = false,
  });

  final double latitude;
  final double longitude;
  final bool startsNewSegment;
}

class RouteMatchEvaluation {
  const RouteMatchEvaluation({
    required this.similarityScore,
    required this.distanceDifferenceMeters,
    required this.startDifferenceMeters,
    required this.finishDifferenceMeters,
    required this.trackDeviationMeters,
  });

  final double similarityScore;
  final int distanceDifferenceMeters;
  final double startDifferenceMeters;
  final double finishDifferenceMeters;
  final double trackDeviationMeters;
}

const _endpointToleranceMeters = 350.0;
const _trackToleranceMeters = 220.0;
const _minimumDistanceToleranceMeters = 400;
const _distanceToleranceRatio = 0.10;
const _minimumSimilarityScore = 0.50;
const _sampleCount = 32;

/// Compares two rides in the same direction using their endpoints, distance,
/// and the shape/order of the complete GPS traces.
RouteMatchEvaluation? evaluateRouteMatch({
  required List<RouteCoordinate> candidateTrack,
  required int candidateDistanceMeters,
  required List<RouteCoordinate> newTrack,
  required int newDistanceMeters,
}) {
  if (candidateTrack.length < 2 || newTrack.length < 2) return null;
  if (candidateDistanceMeters <= 0 || newDistanceMeters <= 0) return null;

  final startDifference = _distanceMeters(candidateTrack.first, newTrack.first);
  final finishDifference = _distanceMeters(candidateTrack.last, newTrack.last);
  final distanceDifference = (candidateDistanceMeters - newDistanceMeters)
      .abs();
  final allowedDistanceDifference = math.max(
    _minimumDistanceToleranceMeters,
    (candidateDistanceMeters * _distanceToleranceRatio).round(),
  );

  if (startDifference > _endpointToleranceMeters ||
      finishDifference > _endpointToleranceMeters ||
      distanceDifference > allowedDistanceDifference) {
    return null;
  }

  final candidateSamples = _resample(candidateTrack, _sampleCount);
  final newSamples = _resample(newTrack, _sampleCount);
  if (candidateSamples == null || newSamples == null) return null;

  final trackDeviation = _discreteFrechetDistance(candidateSamples, newSamples);
  if (trackDeviation > _trackToleranceMeters) return null;

  final score =
      0.2 * (1 - startDifference / _endpointToleranceMeters) +
      0.2 * (1 - finishDifference / _endpointToleranceMeters) +
      0.2 * (1 - distanceDifference / allowedDistanceDifference) +
      0.4 * (1 - trackDeviation / _trackToleranceMeters);
  if (score < _minimumSimilarityScore) return null;

  return RouteMatchEvaluation(
    similarityScore: score.clamp(0.0, 1.0),
    distanceDifferenceMeters: distanceDifference,
    startDifferenceMeters: startDifference,
    finishDifferenceMeters: finishDifference,
    trackDeviationMeters: trackDeviation,
  );
}

List<RouteCoordinate>? _resample(List<RouteCoordinate> track, int count) {
  final edges =
      <
        ({
          RouteCoordinate start,
          RouteCoordinate end,
          double distanceFrom,
          double distanceTo,
        })
      >[];
  var totalDistance = 0.0;
  for (var index = 1; index < track.length; index++) {
    final start = track[index - 1];
    final end = track[index];
    if (end.startsNewSegment) continue;
    final edgeDistance = _distanceMeters(start, end);
    if (!edgeDistance.isFinite || edgeDistance <= 0) continue;
    edges.add((
      start: start,
      end: end,
      distanceFrom: totalDistance,
      distanceTo: totalDistance + edgeDistance,
    ));
    totalDistance += edgeDistance;
  }
  if (totalDistance < 1 || edges.isEmpty) return null;

  final samples = <RouteCoordinate>[];
  var edgeIndex = 0;
  for (var sampleIndex = 0; sampleIndex < count; sampleIndex++) {
    final target = totalDistance * sampleIndex / (count - 1);
    while (edgeIndex < edges.length - 1 &&
        edges[edgeIndex].distanceTo < target) {
      edgeIndex++;
    }
    final edge = edges[edgeIndex];
    final edgeDistance = edge.distanceTo - edge.distanceFrom;
    final fraction = ((target - edge.distanceFrom) / edgeDistance).clamp(
      0.0,
      1.0,
    );
    samples.add(
      RouteCoordinate(
        edge.start.latitude +
            (edge.end.latitude - edge.start.latitude) * fraction,
        edge.start.longitude +
            (edge.end.longitude - edge.start.longitude) * fraction,
      ),
    );
  }
  return samples;
}

double _discreteFrechetDistance(
  List<RouteCoordinate> first,
  List<RouteCoordinate> second,
) {
  final previous = List<double>.filled(second.length, double.infinity);
  for (var firstIndex = 0; firstIndex < first.length; firstIndex++) {
    var diagonal = double.infinity;
    for (var secondIndex = 0; secondIndex < second.length; secondIndex++) {
      final oldValue = previous[secondIndex];
      final pointDistance = _distanceMeters(
        first[firstIndex],
        second[secondIndex],
      );
      if (firstIndex == 0 && secondIndex == 0) {
        previous[secondIndex] = pointDistance;
      } else if (firstIndex == 0) {
        previous[secondIndex] = math.max(
          previous[secondIndex - 1],
          pointDistance,
        );
      } else if (secondIndex == 0) {
        previous[secondIndex] = math.max(oldValue, pointDistance);
      } else {
        previous[secondIndex] = math.max(
          math.min(diagonal, math.min(oldValue, previous[secondIndex - 1])),
          pointDistance,
        );
      }
      diagonal = oldValue;
    }
  }
  return previous.last;
}

double _distanceMeters(RouteCoordinate first, RouteCoordinate second) {
  const earthRadiusMeters = 6371000.0;
  final latitudeDelta = _radians(second.latitude - first.latitude);
  final longitudeDelta = _radians(second.longitude - first.longitude);
  final firstLatitude = _radians(first.latitude);
  final secondLatitude = _radians(second.latitude);
  final haversine =
      math.pow(math.sin(latitudeDelta / 2), 2) +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.pow(math.sin(longitudeDelta / 2), 2);
  return 2 * earthRadiusMeters * math.asin(math.sqrt(haversine));
}

double _radians(double degrees) => degrees * math.pi / 180;
