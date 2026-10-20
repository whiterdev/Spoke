import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('suggests and confirms a route for a matching completed ride', () async {
    const track = [
      (-34.60, -58.40),
      (-34.60, -58.39),
      (-34.59, -58.39),
      (-34.59, -58.38),
    ];
    final firstRideId = await _insertCompletedRide(database, track, 3500);
    final firstRide = await (database.select(
      database.rides,
    )..where((ride) => ride.id.equals(firstRideId))).getSingle();
    final routeId = firstRide.routeId;
    expect(routeId, isA<int>());
    final repeatedRideId = await _insertCompletedRide(database, track, 3560);

    expect(await database.suggestRouteMatchesForRide(repeatedRideId), 1);
    final pendingMatches = await database.watchPendingRouteMatches().first;
    expect(pendingMatches, hasLength(1));
    expect(pendingMatches.single.route.id, routeId);
    expect(pendingMatches.single.ride.id, repeatedRideId);

    await database.confirmRouteSuggestion(pendingMatches.single.suggestion.id);
    final assignedRide = await (database.select(
      database.rides,
    )..where((ride) => ride.id.equals(repeatedRideId))).getSingle();
    expect(assignedRide.routeId, routeId);
    expect(await database.watchPendingRouteMatches().first, isEmpty);
  });

  test('does not suggest or re-show a dismissed match', () async {
    const track = [
      (-34.60, -58.40),
      (-34.60, -58.39),
      (-34.59, -58.39),
      (-34.59, -58.38),
    ];
    await _insertCompletedRide(database, track, 3500);
    final repeatedRideId = await _insertCompletedRide(database, track, 3560);

    expect(await database.suggestRouteMatchesForRide(repeatedRideId), 1);
    final pendingMatch =
        (await database.watchPendingRouteMatches().first).single;
    await database.dismissRouteSuggestion(pendingMatch.suggestion.id);

    expect(await database.suggestRouteMatchesForRide(repeatedRideId), 0);
    expect(await database.watchPendingRouteMatches().first, isEmpty);
  });

  test(
    'creates a route for each completed outing and suggests repeats',
    () async {
      const track = [
        (-34.60, -58.40),
        (-34.60, -58.39),
        (-34.59, -58.39),
        (-34.59, -58.38),
      ];
      final olderRideId = await _insertCompletedRide(database, track, 3500);
      final newerRideId = await _insertCompletedRide(database, track, 3560);
      final rides = await database.select(database.rides).get();
      final olderRide = rides.singleWhere((ride) => ride.id == olderRideId);
      final newerRide = rides.singleWhere((ride) => ride.id == newerRideId);
      expect(olderRide.routeId, isA<int>());
      expect(newerRide.routeId, isA<int>());
      expect(olderRide.routeId, isNot(newerRide.routeId));

      expect(await database.suggestRouteMatchesForRide(newerRideId), 1);
      final pendingMatches = await database.watchPendingRouteMatches().first;
      expect(pendingMatches, hasLength(1));
      expect(pendingMatches.single.ride.id, newerRideId);
      expect(pendingMatches.single.route.id, olderRide.routeId);
    },
  );

  test('backfills routes for completed outings during v4 upgrade', () async {
    final directory = await Directory.systemTemp.createTemp(
      'spoke-history-migration-',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}history.sqlite',
    );
    AppDatabase? previousDatabase;
    AppDatabase? upgradedDatabase;

    try {
      previousDatabase = AppDatabase(NativeDatabase(file));
      const track = [(-34.60, -58.40), (-34.60, -58.39), (-34.59, -58.39)];
      final rideId = await _insertCompletedRide(previousDatabase, track, 2500);
      final completedRide = await (previousDatabase.select(
        previousDatabase.rides,
      )..where((ride) => ride.id.equals(rideId))).getSingle();
      final oldRouteId = completedRide.routeId!;

      await (previousDatabase.update(previousDatabase.rides)
            ..where((ride) => ride.id.equals(rideId)))
          .write(const RidesCompanion(routeId: Value(null)));
      await (previousDatabase.delete(
        previousDatabase.routes,
      )..where((route) => route.id.equals(oldRouteId))).go();
      await previousDatabase.customStatement('PRAGMA user_version = 4');
      await previousDatabase.close();
      previousDatabase = null;

      upgradedDatabase = AppDatabase(NativeDatabase(file));
      final upgradedRide = await (upgradedDatabase.select(
        upgradedDatabase.rides,
      )..where((ride) => ride.id.equals(rideId))).getSingle();
      expect(upgradedRide.routeId, isA<int>());
    } finally {
      await previousDatabase?.close();
      await upgradedDatabase?.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<int> _insertCompletedRide(
  AppDatabase database,
  List<(double, double)> coordinates,
  int distanceMeters,
) async {
  final startedAt = DateTime.utc(2026, 10, 19);
  final rideId = await database
      .into(database.rides)
      .insert(
        RidesCompanion.insert(
          startedAt: startedAt,
          finishedAt: Value(startedAt.add(const Duration(hours: 1))),
          distanceMeters: Value(distanceMeters),
          status: const Value(RideStatus.completed),
        ),
      );
  await database.appendTrackPoints(rideId, [
    for (var index = 0; index < coordinates.length; index++)
      RideTrackPointsCompanion.insert(
        rideId: rideId,
        sequence: index,
        latitude: coordinates[index].$1,
        longitude: coordinates[index].$2,
        recordedAt: startedAt.add(Duration(seconds: index * 3)),
      ),
  ]);
  await database.completeRide(
    rideId: rideId,
    finishedAt: startedAt.add(const Duration(hours: 1)),
    durationSeconds: 3600,
    distanceMeters: distanceMeters,
  );
  return rideId;
}
