import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/routes/route_matcher.dart';

void main() {
  const route = [
    RouteCoordinate(-34.60, -58.40),
    RouteCoordinate(-34.60, -58.39),
    RouteCoordinate(-34.59, -58.39),
    RouteCoordinate(-34.59, -58.38),
  ];

  test('matches a repeated complete trace with nearby GPS noise', () {
    const repeated = [
      RouteCoordinate(-34.60001, -58.40002),
      RouteCoordinate(-34.60002, -58.39001),
      RouteCoordinate(-34.59001, -58.39002),
      RouteCoordinate(-34.59002, -58.38001),
    ];

    final result = evaluateRouteMatch(
      candidateTrack: route,
      candidateDistanceMeters: 3500,
      newTrack: repeated,
      newDistanceMeters: 3560,
    );

    expect(result, isNotNull);
    expect(result!.similarityScore, greaterThan(0.9));
    expect(result.distanceDifferenceMeters, 60);
  });

  test('rejects matching endpoints when the complete trace differs', () {
    const differentRoute = [
      RouteCoordinate(-34.60, -58.40),
      RouteCoordinate(-34.60, -58.39),
      RouteCoordinate(-34.55, -58.39),
      RouteCoordinate(-34.55, -58.38),
      RouteCoordinate(-34.59, -58.38),
    ];

    final result = evaluateRouteMatch(
      candidateTrack: route,
      candidateDistanceMeters: 3500,
      newTrack: differentRoute,
      newDistanceMeters: 3500,
    );

    expect(result, isNull);
  });

  test('rejects similar-looking tracks outside the distance tolerance', () {
    final result = evaluateRouteMatch(
      candidateTrack: route,
      candidateDistanceMeters: 3500,
      newTrack: route,
      newDistanceMeters: 4200,
    );

    expect(result, isNull);
  });

  test('compares the GPS trace without joining paused segments', () {
    const interruptedRoute = [
      RouteCoordinate(-34.60, -58.40),
      RouteCoordinate(-34.60, -58.39),
      RouteCoordinate(-34.59, -58.39, startsNewSegment: true),
      RouteCoordinate(-34.59, -58.38),
    ];
    const repeatedRoute = [
      RouteCoordinate(-34.60001, -58.40002),
      RouteCoordinate(-34.60002, -58.39001),
      RouteCoordinate(-34.59001, -58.39002, startsNewSegment: true),
      RouteCoordinate(-34.59002, -58.38001),
    ];

    final result = evaluateRouteMatch(
      candidateTrack: interruptedRoute,
      candidateDistanceMeters: 3500,
      newTrack: repeatedRoute,
      newDistanceMeters: 3560,
    );

    expect(result, isNotNull);
    expect(result!.similarityScore, greaterThan(0.9));
  });
}
