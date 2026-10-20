import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/routes/route_track_segments.dart';

void main() {
  test('starts a new segment at a persisted sequence gap', () {
    final start = DateTime.utc(2026, 10, 20);
    final points = [
      (sequence: 4, recordedAt: start),
      (sequence: 5, recordedAt: start.add(const Duration(seconds: 3))),
      (sequence: 7, recordedAt: start.add(const Duration(seconds: 6))),
      (sequence: 8, recordedAt: start.add(const Duration(seconds: 9))),
    ];

    final segments = splitRouteTrackAtGaps(
      points,
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    );

    expect(segments.map((segment) => segment.length), [2, 2]);
  });

  test('starts a new segment when timestamps have a long gap', () {
    final start = DateTime.utc(2026, 10, 20);
    final points = [
      (sequence: 0, recordedAt: start),
      (sequence: 1, recordedAt: start.add(const Duration(seconds: 3))),
      (sequence: 2, recordedAt: start.add(const Duration(seconds: 34))),
      (sequence: 3, recordedAt: start.add(const Duration(seconds: 37))),
    ];

    final segments = splitRouteTrackAtGaps(
      points,
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    );

    expect(segments.map((segment) => segment.length), [2, 2]);
  });
}
