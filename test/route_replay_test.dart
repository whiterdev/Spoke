import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/features/routes/route_replay.dart';

void main() {
  test('replays a recorded route from its start through its finish', () {
    final timeline = RouteReplayTimeline([
      [
        (latitude: 0.0, longitude: 0.0),
        (latitude: 0.0, longitude: 1.0),
        (latitude: 0.0, longitude: 2.0),
      ],
    ]);

    expect(timeline.positionAt(0), (latitude: 0.0, longitude: 0.0));
    expect(timeline.positionAt(0.5)!.longitude, closeTo(1.0, 0.0001));
    expect(timeline.positionAt(1), (latitude: 0.0, longitude: 2.0));
  });

  test('clamps replay seeking to the recorded route', () {
    final timeline = RouteReplayTimeline([
      [
        (latitude: -34.6, longitude: -58.4),
        (latitude: -34.59, longitude: -58.39),
      ],
    ]);

    expect(timeline.positionAt(-1), (latitude: -34.6, longitude: -58.4));
    expect(timeline.positionAt(2), (latitude: -34.59, longitude: -58.39));
  });

  test('does not animate across GPS gaps between route segments', () {
    final timeline = RouteReplayTimeline([
      [(latitude: 0.0, longitude: 0.0), (latitude: 0.0, longitude: 0.01)],
      [(latitude: 20.0, longitude: 20.0), (latitude: 20.0, longitude: 20.01)],
    ]);

    expect(timeline.positionAt(0.5)!.latitude, closeTo(0, 0.001));
    expect(timeline.positionAt(0.75)!.latitude, closeTo(20, 0.1));
  });

  test('returns no position for an empty GPS track', () {
    expect(RouteReplayTimeline(const []).positionAt(0.5), isNull);
  });

  test(
    'estimates progress and distance to the nearest recorded route segment',
    () {
      final timeline = RouteReplayTimeline([
        [(latitude: 0.0, longitude: 0.0), (latitude: 0.0, longitude: 0.02)],
      ]);

      final onRoute = timeline.matchPosition((latitude: 0, longitude: 0.01));
      expect(onRoute!.progress, closeTo(0.5, 0.001));
      expect(onRoute.distanceFromRouteMeters, closeTo(0, 0.1));

      final awayFromRoute = timeline.matchPosition((
        latitude: 0.01,
        longitude: 0.01,
      ));
      expect(awayFromRoute!.distanceFromRouteMeters, greaterThan(1000));
    },
  );

  test('matches GPS position to segments without bridging route gaps', () {
    final timeline = RouteReplayTimeline([
      [(latitude: 0.0, longitude: 0.0), (latitude: 0.0, longitude: 0.01)],
      [(latitude: 20.0, longitude: 20.0), (latitude: 20.0, longitude: 20.01)],
    ]);

    final match = timeline.matchPosition((latitude: 10, longitude: 10));
    expect(match!.distanceFromRouteMeters, greaterThan(1000000));
  });
}
