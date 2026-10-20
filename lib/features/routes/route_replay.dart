import 'dart:math' as math;

typedef ReplayCoordinate = ({double latitude, double longitude});

class RouteReplayTimeline {
  RouteReplayTimeline(Iterable<List<ReplayCoordinate>> segments) {
    final legs = <_ReplayLeg>[];
    ReplayCoordinate? firstPoint;
    var distance = 0.0;

    for (final segment in segments) {
      if (segment.isEmpty) continue;
      firstPoint ??= segment.first;
      for (var index = 1; index < segment.length; index++) {
        final start = segment[index - 1];
        final end = segment[index];
        final length = _distanceMeters(start, end);
        if (length <= 0) continue;
        legs.add(
          _ReplayLeg(
            start: start,
            end: end,
            startDistanceMeters: distance,
            lengthMeters: length,
          ),
        );
        distance += length;
      }
    }

    _legs = List.unmodifiable(legs);
    _firstPoint = firstPoint;
    totalDistanceMeters = distance;
  }

  late final List<_ReplayLeg> _legs;
  late final ReplayCoordinate? _firstPoint;
  late final double totalDistanceMeters;

  ReplayCoordinate? positionAt(double progress) {
    if (_firstPoint == null || _legs.isEmpty) return _firstPoint;
    final normalizedProgress = progress.isNaN
        ? 0.0
        : progress.clamp(0.0, 1.0).toDouble();
    final targetDistance = totalDistanceMeters * normalizedProgress;

    var low = 0;
    var high = _legs.length - 1;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      final leg = _legs[middle];
      if (targetDistance <= leg.startDistanceMeters + leg.lengthMeters) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }

    final leg = _legs[low];
    final legProgress =
        ((targetDistance - leg.startDistanceMeters) / leg.lengthMeters)
            .clamp(0.0, 1.0)
            .toDouble();
    return (
      latitude:
          leg.start.latitude +
          (leg.end.latitude - leg.start.latitude) * legProgress,
      longitude:
          leg.start.longitude +
          (leg.end.longitude - leg.start.longitude) * legProgress,
    );
  }

  RouteMatchPosition? matchPosition(ReplayCoordinate position) {
    final firstPoint = _firstPoint;
    if (firstPoint == null) return null;
    if (_legs.isEmpty) {
      return RouteMatchPosition(
        progress: 0,
        distanceFromRouteMeters: _distanceMeters(firstPoint, position),
      );
    }

    var nearestDistanceMeters = double.infinity;
    var nearestProgress = 0.0;
    for (final leg in _legs) {
      final projection = _projectOntoLeg(position, leg.start, leg.end);
      if (projection.distanceMeters >= nearestDistanceMeters) continue;
      nearestDistanceMeters = projection.distanceMeters;
      nearestProgress =
          (leg.startDistanceMeters + leg.lengthMeters * projection.fraction) /
          totalDistanceMeters;
    }
    return RouteMatchPosition(
      progress: nearestProgress.clamp(0.0, 1.0).toDouble(),
      distanceFromRouteMeters: nearestDistanceMeters,
    );
  }
}

class RouteMatchPosition {
  const RouteMatchPosition({
    required this.progress,
    required this.distanceFromRouteMeters,
  });

  final double progress;
  final double distanceFromRouteMeters;
}

class _ReplayLeg {
  const _ReplayLeg({
    required this.start,
    required this.end,
    required this.startDistanceMeters,
    required this.lengthMeters,
  });

  final ReplayCoordinate start;
  final ReplayCoordinate end;
  final double startDistanceMeters;
  final double lengthMeters;
}

class _LegProjection {
  const _LegProjection({required this.fraction, required this.distanceMeters});

  final double fraction;
  final double distanceMeters;
}

_LegProjection _projectOntoLeg(
  ReplayCoordinate position,
  ReplayCoordinate start,
  ReplayCoordinate end,
) {
  const earthRadiusMeters = 6371000.0;
  final referenceLatitude = _radians(
    (position.latitude + start.latitude + end.latitude) / 3,
  );
  final startX =
      _radians(start.longitude - position.longitude) *
      earthRadiusMeters *
      math.cos(referenceLatitude);
  final startY =
      _radians(start.latitude - position.latitude) * earthRadiusMeters;
  final endX =
      _radians(end.longitude - position.longitude) *
      earthRadiusMeters *
      math.cos(referenceLatitude);
  final endY = _radians(end.latitude - position.latitude) * earthRadiusMeters;
  final deltaX = endX - startX;
  final deltaY = endY - startY;
  final lengthSquared = deltaX * deltaX + deltaY * deltaY;
  final fraction = lengthSquared == 0
      ? 0.0
      : (-(startX * deltaX + startY * deltaY) / lengthSquared)
            .clamp(0.0, 1.0)
            .toDouble();
  final nearestX = startX + deltaX * fraction;
  final nearestY = startY + deltaY * fraction;
  return _LegProjection(
    fraction: fraction,
    distanceMeters: math.sqrt(nearestX * nearestX + nearestY * nearestY),
  );
}

double _distanceMeters(ReplayCoordinate first, ReplayCoordinate second) {
  const earthRadiusMeters = 6371000.0;
  final firstLatitude = _radians(first.latitude);
  final secondLatitude = _radians(second.latitude);
  final latitudeDelta = secondLatitude - firstLatitude;
  final longitudeDelta = _radians(second.longitude - first.longitude);
  final haversine =
      math.pow(math.sin(latitudeDelta / 2), 2) +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.pow(math.sin(longitudeDelta / 2), 2);
  return earthRadiusMeters *
      2 *
      math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
}

double _radians(double degrees) => degrees * math.pi / 180;
