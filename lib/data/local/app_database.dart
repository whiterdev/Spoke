import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../routes/route_matcher.dart';
import '../routes/route_track_segments.dart';

part 'app_database.g.dart';

abstract final class RideStatus {
  static const recording = 'recording';
  static const paused = 'paused';
  static const completed = 'completed';
  static const discarded = 'discarded';
}

abstract final class RouteSuggestionStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const dismissed = 'dismissed';
}

abstract final class BikeType {
  static const mountain = 'mountain';
  static const road = 'road';
  static const gravel = 'gravel';
  static const urban = 'urban';
  static const other = 'other';

  static const values = [mountain, road, gravel, urban, other];

  static String label(String value) => switch (value) {
    mountain => 'Montaña',
    road => 'Ruta',
    gravel => 'Gravel',
    urban => 'Urbana',
    _ => 'Otra',
  };

  // Editable reminders in meters, not manufacturer service specifications.
  static Map<String, int> suggestedIntervalsMeters(String value) =>
      switch (value) {
        mountain => const {
          'Inspección general': 500000,
          'Transmisión': 300000,
          'Frenos': 500000,
          'Neumáticos': 500000,
          'Suspensión': 500000,
        },
        gravel => const {
          'Inspección general': 750000,
          'Transmisión': 400000,
          'Frenos': 750000,
          'Neumáticos': 1000000,
          'Sistema tubeless': 500000,
        },
        road => const {
          'Inspección general': 1000000,
          'Transmisión': 500000,
          'Frenos': 1000000,
          'Neumáticos': 1000000,
        },
        urban => const {
          'Inspección general': 1000000,
          'Transmisión': 750000,
          'Frenos': 1000000,
          'Neumáticos': 1500000,
        },
        _ => const {
          'Inspección general': 1000000,
          'Transmisión': 500000,
          'Frenos': 1000000,
          'Neumáticos': 1000000,
        },
      };

  static List<String> defaultServices(String value) =>
      suggestedIntervalsMeters(value).keys.toList(growable: false);
}

@DataClassName('SavedRoute')
class Routes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get distanceMeters => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}

@TableIndex(name: 'rides_started_at_idx', columns: {#startedAt})
@TableIndex(
  name: 'rides_bike_status_started_at_idx',
  columns: {#bikeId, #status, #startedAt},
)
@DataClassName('Ride')
class Rides extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get pausedDurationSeconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  IntColumn get distanceMeters => integer().withDefault(const Constant(0))();
  RealColumn get elevationGainMeters => real().nullable()();
  RealColumn get averageSpeedMetersPerSecond => real().nullable()();
  RealColumn get maxSpeedMetersPerSecond => real().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant(RideStatus.recording))();
  IntColumn get routeId => integer().nullable().references(
    Routes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get bikeId => integer().nullable().references(
    Bikes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}

@DataClassName('RideTrackPoint')
@TableIndex(
  name: 'ride_track_points_ride_recorded_at_idx',
  columns: {#rideId, #recordedAt},
)
class RideTrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rideId =>
      integer().references(Rides, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequence => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitudeMeters => real().nullable()();
  RealColumn get horizontalAccuracyMeters => real().nullable()();
  RealColumn get speedMetersPerSecond => real().nullable()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {rideId, sequence},
  ];
}

@TableIndex(name: 'bikes_archived_idx', columns: {#isArchived})
@DataClassName('Bike')
class Bikes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type =>
      text().withDefault(const Constant(BikeType.mountain))();
  TextColumn get brand => text().withLength(min: 1, max: 60)();
  TextColumn get model => text().withLength(min: 1, max: 80)();
  TextColumn get nickname => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get odometerBaselineMeters =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get odometerBaselineAt =>
      dateTime().clientDefault(DateTime.now)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}

@DataClassName('MaintenanceTemplate')
@TableIndex(
  name: 'maintenance_templates_type_enabled_idx',
  columns: {#bikeType, #isEnabled},
)
class MaintenanceTemplates extends Table {
  TextColumn get bikeType => text()();
  TextColumn get serviceName => text().withLength(min: 1, max: 80)();
  IntColumn get intervalMeters => integer().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {bikeType, serviceName},
  ];
}

@DataClassName('MaintenanceEvent')
@TableIndex(
  name: 'maintenance_bike_service_date_idx',
  columns: {#bikeId, #serviceName, #servicedAt},
)
class MaintenanceEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bikeId =>
      integer().references(Bikes, #id, onDelete: KeyAction.cascade)();
  TextColumn get serviceName => text().withLength(min: 1, max: 80)();
  DateTimeColumn get servicedAt => dateTime()();
  IntColumn get odometerMeters => integer()();
  IntColumn get serviceIntervalMeters => integer().nullable()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('RouteMatchSuggestion')
@TableIndex(
  name: 'route_suggestions_ride_status_idx',
  columns: {#rideId, #status},
)
class RouteMatchSuggestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rideId =>
      integer().references(Rides, #id, onDelete: KeyAction.cascade)();
  IntColumn get routeId =>
      integer().references(Routes, #id, onDelete: KeyAction.cascade)();
  RealColumn get similarityScore => real()();
  IntColumn get distanceDifferenceMeters => integer().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant(RouteSuggestionStatus.pending))();
  DateTimeColumn get suggestedAt => dateTime().clientDefault(DateTime.now)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {rideId, routeId},
  ];
}

@DataClassName('RiderProfile')
class RiderProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withLength(min: 1, max: 60)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
}

class MaintenanceForecast {
  const MaintenanceForecast({
    required this.event,
    required this.currentOdometerMeters,
    required this.intervalMeters,
  });

  final MaintenanceEvent event;
  final int currentOdometerMeters;
  final int intervalMeters;

  int get dueAtOdometerMeters => event.odometerMeters + intervalMeters;

  int get remainingMeters => dueAtOdometerMeters - currentOdometerMeters;

  bool get isDue => remainingMeters <= 0;
}

class PendingRouteMatch {
  const PendingRouteMatch({
    required this.suggestion,
    required this.route,
    required this.ride,
  });

  final RouteMatchSuggestion suggestion;
  final SavedRoute route;
  final Ride ride;
}

@DriftDatabase(
  tables: [
    Routes,
    Rides,
    RideTrackPoints,
    Bikes,
    MaintenanceTemplates,
    MaintenanceEvents,
    RouteMatchSuggestions,
    RiderProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'spoke_local'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(rides, rides.pausedDurationSeconds);
        await migrator.addColumn(rides, rides.pausedAt);
      }
      if (from < 3) {
        for (final bikeType in BikeType.values) {
          for (final entry in BikeType.suggestedIntervalsMeters(
            bikeType,
          ).entries) {
            await customStatement(
              'UPDATE maintenance_templates '
              'SET interval_meters = ? '
              'WHERE bike_type = ? AND service_name = ? '
              'AND interval_meters IS NULL',
              [entry.value, bikeType, entry.key],
            );
          }
        }
      }
      if (from < 4) {
        await migrator.createTable(riderProfiles);
      }
      if (from < 5) {
        final requiredTables = await customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name IN ('rides', 'routes')",
        ).get();
        if (requiredTables.length == 2) {
          final completedRides =
              await (select(rides)..where(
                    (ride) =>
                        ride.status.equals(RideStatus.completed) &
                        ride.routeId.isNull(),
                  ))
                  .get();
          for (final ride in completedRides) {
            await _ensureRouteForRideInTransaction(ride.id);
          }
        }
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<List<Ride>> watchRides() => (select(
    rides,
  )..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)])).watch();

  Stream<List<Ride>> watchCompletedRides() =>
      (select(rides)
            ..where((ride) => ride.status.equals(RideStatus.completed))
            ..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)]))
          .watch();

  Stream<RiderProfile?> watchRiderProfile() =>
      (select(riderProfiles)..limit(1)).watchSingleOrNull();

  Future<void> saveRiderName(String displayName) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre no puede quedar vacío.');
    }

    final profile = await (select(riderProfiles)..limit(1)).getSingleOrNull();
    if (profile == null) {
      await into(riderProfiles)
          .insert(RiderProfilesCompanion.insert(displayName: normalizedName));
      return;
    }

    await (update(
      riderProfiles,
    )..where((row) => row.id.equals(profile.id))).write(
      RiderProfilesCompanion(
        displayName: Value(normalizedName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<PendingRouteMatch>> watchPendingRouteMatches() {
    final query =
        select(routeMatchSuggestions).join([
            innerJoin(
              routes,
              routes.id.equalsExp(routeMatchSuggestions.routeId),
            ),
            innerJoin(rides, rides.id.equalsExp(routeMatchSuggestions.rideId)),
          ])
          ..where(
            routeMatchSuggestions.status.equals(RouteSuggestionStatus.pending),
          )
          ..orderBy([
            OrderingTerm.desc(routeMatchSuggestions.similarityScore),
            OrderingTerm.desc(routeMatchSuggestions.suggestedAt),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          PendingRouteMatch(
            suggestion: row.readTable(routeMatchSuggestions),
            route: row.readTable(routes),
            ride: row.readTable(rides),
          ),
      ],
    );
  }

  Future<int?> _ensureRouteForRide(int rideId) =>
      transaction(() => _ensureRouteForRideInTransaction(rideId));

  Future<int?> _ensureRouteForRideInTransaction(int rideId) async {
    final ride = await (select(
      rides,
    )..where((row) => row.id.equals(rideId))).getSingleOrNull();
    if (ride == null || ride.status != RideStatus.completed) return null;
    if (ride.routeId != null) return ride.routeId;

    final title = ride.title?.trim();
    final localDate = ride.startedAt.toLocal();
    final defaultName =
        '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
    final routeName = (title == null || title.isEmpty)
        ? 'Salida $defaultName'
        : title.length > 80
        ? title.substring(0, 80)
        : title;
    final routeId = await into(routes).insert(
      RoutesCompanion.insert(
        name: routeName,
        distanceMeters: Value(ride.distanceMeters),
      ),
    );
    await (update(rides)..where((row) => row.id.equals(rideId))).write(
      RidesCompanion(routeId: Value(routeId)),
    );
    return routeId;
  }

  Stream<List<Ride>> watchRecentRides({int limit = 3}) =>
      (select(rides)
            ..where((ride) => ride.status.equals(RideStatus.completed))
            ..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)])
            ..limit(limit))
          .watch();

  Stream<List<Ride>> watchRidesForLocalDay(DateTime localDay) {
    final start = DateTime(localDay.year, localDay.month, localDay.day).toUtc();
    final end = DateTime(
      localDay.year,
      localDay.month,
      localDay.day + 1,
    ).toUtc();

    return (select(rides)
          ..where(
            (ride) =>
                ride.status.equals(RideStatus.completed) &
                ride.startedAt.isBiggerOrEqualValue(start) &
                ride.startedAt.isSmallerThanValue(end),
          )
          ..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)]))
        .watch();
  }

  Stream<List<Bike>> watchBikes() =>
      (select(bikes)
            ..where((bike) => bike.isArchived.equals(false))
            ..orderBy([
              (bike) => OrderingTerm.asc(bike.brand),
              (bike) => OrderingTerm.asc(bike.model),
            ]))
          .watch();

  Future<int> createBike(BikesCompanion bike) => transaction(() async {
    final bikeId = await into(bikes).insert(bike);
    final createdBike = await (select(
      bikes,
    )..where((row) => row.id.equals(bikeId))).getSingle();

    await _ensureDefaultMaintenanceTemplates(createdBike.type);
    return bikeId;
  });

  Future<int> updateBike(int bikeId, BikesCompanion changes) =>
      transaction(() async {
        final updatedRows = await (update(
          bikes,
        )..where((row) => row.id.equals(bikeId))).write(changes);
        if (updatedRows == 0) return 0;

        final updatedBike = await (select(
          bikes,
        )..where((row) => row.id.equals(bikeId))).getSingle();
        await _ensureDefaultMaintenanceTemplates(updatedBike.type);
        return updatedRows;
      });

  Future<void> _ensureDefaultMaintenanceTemplates(String bikeType) async {
    for (final serviceName in BikeType.defaultServices(bikeType)) {
      final existing =
          await (select(maintenanceTemplates)..where(
                (template) =>
                    template.bikeType.equals(bikeType) &
                    template.serviceName.equals(serviceName),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await into(maintenanceTemplates).insert(
          MaintenanceTemplatesCompanion(
            bikeType: Value(bikeType),
            serviceName: Value(serviceName),
            intervalMeters: Value(
              BikeType.suggestedIntervalsMeters(bikeType)[serviceName],
            ),
          ),
        );
      }
    }
  }

  Stream<List<Ride>> watchLastSevenDaysRides() {
    final today = DateTime.now();
    final firstLocalDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final sevenDaysAgo = firstLocalDay.toUtc();

    return (select(rides)
          ..where(
            (ride) =>
                ride.status.equals(RideStatus.completed) &
                ride.startedAt.isBiggerOrEqualValue(sevenDaysAgo),
          )
          ..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)]))
        .watch();
  }

  Future<int> startRide(RidesCompanion ride) => into(rides).insert(ride);

  Future<Ride?> activeRide() =>
      (select(rides)
            ..where(
              (ride) =>
                  ride.status.equals(RideStatus.recording) |
                  ride.status.equals(RideStatus.paused),
            )
            ..orderBy([(ride) => OrderingTerm.desc(ride.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<RideTrackPoint>> getRideTrackPoints(int rideId) =>
      (select(rideTrackPoints)
            ..where((point) => point.rideId.equals(rideId))
            ..orderBy([(point) => OrderingTerm.asc(point.sequence)]))
          .get();

  Future<void> pauseRide({
    required int rideId,
    required DateTime pausedAt,
  }) async {
    await (update(rides)..where(
          (ride) =>
              ride.id.equals(rideId) & ride.status.equals(RideStatus.recording),
        ))
        .write(
          RidesCompanion(
            status: const Value(RideStatus.paused),
            pausedAt: Value(pausedAt.toUtc()),
          ),
        );
  }

  Future<void> resumeRide({
    required int rideId,
    required DateTime resumedAt,
  }) async {
    final ride = await (select(
      rides,
    )..where((row) => row.id.equals(rideId))).getSingleOrNull();
    if (ride == null || ride.status != RideStatus.paused) {
      throw StateError('La salida no está pausada.');
    }

    final pausedAt = ride.pausedAt ?? resumedAt;
    final pausedSeconds = resumedAt.difference(pausedAt).inSeconds;
    await (update(rides)..where((row) => row.id.equals(rideId))).write(
      RidesCompanion(
        status: const Value(RideStatus.recording),
        pausedAt: const Value(null),
        pausedDurationSeconds: Value(
          ride.pausedDurationSeconds + (pausedSeconds > 0 ? pausedSeconds : 0),
        ),
      ),
    );
  }

  Future<void> discardRide(int rideId) async {
    await (delete(rides)..where((ride) => ride.id.equals(rideId))).go();
  }

  Future<void> appendTrackPoints(
    int rideId,
    Iterable<RideTrackPointsCompanion> points,
  ) async {
    final rows = points
        .map((point) => point.copyWith(rideId: Value(rideId)))
        .toList(growable: false);
    if (rows.isEmpty) return;

    await transaction(() async {
      await batch((batch) {
        batch.insertAll(rideTrackPoints, rows);
      });
    });
  }

  Future<void> completeRide({
    required int rideId,
    required DateTime finishedAt,
    required int durationSeconds,
    required int distanceMeters,
    double? elevationGainMeters,
    double? averageSpeedMetersPerSecond,
    double? maxSpeedMetersPerSecond,
  }) async {
    await transaction(() async {
      await (update(rides)..where((ride) => ride.id.equals(rideId))).write(
        RidesCompanion(
          finishedAt: Value(finishedAt),
          durationSeconds: Value(durationSeconds),
          pausedAt: const Value(null),
          distanceMeters: Value(distanceMeters),
          elevationGainMeters: Value(elevationGainMeters),
          averageSpeedMetersPerSecond: Value(averageSpeedMetersPerSecond),
          maxSpeedMetersPerSecond: Value(maxSpeedMetersPerSecond),
          status: const Value(RideStatus.completed),
        ),
      );
      await _ensureRouteForRideInTransaction(rideId);
    });
  }

  Future<int> suggestRouteMatchesForRide(int rideId) async {
    var ride = await (select(
      rides,
    )..where((row) => row.id.equals(rideId))).getSingleOrNull();
    if (ride == null || ride.status != RideStatus.completed) return 0;

    await _ensureRouteForRide(rideId);
    ride = await (select(
      rides,
    )..where((row) => row.id.equals(rideId))).getSingleOrNull();
    if (ride == null || ride.routeId == null) return 0;

    final ridePoints = await getRideTrackPoints(rideId);
    if (ridePoints.length < 2) return 0;

    final previousRides =
        await (select(rides)
              ..where(
                (row) =>
                    row.status.equals(RideStatus.completed) &
                    row.id.isSmallerThanValue(rideId),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.startedAt)]))
            .get();
    for (final previousRide in previousRides) {
      if (previousRide.routeId == null) {
        await _ensureRouteForRide(previousRide.id);
      }
    }

    final candidateRides =
        await (select(rides)
              ..where(
                (row) =>
                    row.status.equals(RideStatus.completed) &
                    row.id.isSmallerThanValue(rideId) &
                    row.routeId.isNotNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.startedAt)]))
            .get();
    if (candidateRides.isEmpty) return 0;

    final existingSuggestions = await (select(
      routeMatchSuggestions,
    )..where((row) => row.rideId.equals(rideId))).get();
    final existingRouteIds = existingSuggestions
        .map((suggestion) => suggestion.routeId)
        .toSet();
    final candidatesByRoute = <int, List<Ride>>{};
    for (final candidateRide in candidateRides) {
      final routeId = candidateRide.routeId;
      if (routeId == null ||
          routeId == ride.routeId ||
          existingRouteIds.contains(routeId)) {
        continue;
      }
      candidatesByRoute.putIfAbsent(routeId, () => []).add(candidateRide);
    }

    final newTrack = [
      for (var index = 0; index < ridePoints.length; index++)
        RouteCoordinate(
          ridePoints[index].latitude,
          ridePoints[index].longitude,
          startsNewSegment:
              index > 0 &&
              startsNewRouteTrackSegment(
                previousSequence: ridePoints[index - 1].sequence,
                currentSequence: ridePoints[index].sequence,
                previousRecordedAt: ridePoints[index - 1].recordedAt,
                currentRecordedAt: ridePoints[index].recordedAt,
              ),
        ),
    ];
    final matches = <int, RouteMatchEvaluation>{};
    for (final entry in candidatesByRoute.entries) {
      RouteMatchEvaluation? bestMatch;
      for (final candidateRide in entry.value) {
        final points = await getRideTrackPoints(candidateRide.id);
        if (points.length < 2) continue;
        final evaluation = evaluateRouteMatch(
          candidateTrack: [
            for (var index = 0; index < points.length; index++)
              RouteCoordinate(
                points[index].latitude,
                points[index].longitude,
                startsNewSegment:
                    index > 0 &&
                    startsNewRouteTrackSegment(
                      previousSequence: points[index - 1].sequence,
                      currentSequence: points[index].sequence,
                      previousRecordedAt: points[index - 1].recordedAt,
                      currentRecordedAt: points[index].recordedAt,
                    ),
              ),
          ],
          candidateDistanceMeters: candidateRide.distanceMeters,
          newTrack: newTrack,
          newDistanceMeters: ride.distanceMeters,
        );
        if (evaluation != null &&
            (bestMatch == null ||
                evaluation.similarityScore > bestMatch.similarityScore)) {
          bestMatch = evaluation;
        }
      }
      if (bestMatch != null) matches[entry.key] = bestMatch;
    }

    final rankedMatches = matches.entries.toList()
      ..sort(
        (first, second) =>
            second.value.similarityScore.compareTo(first.value.similarityScore),
      );
    final suggestions = rankedMatches.take(3).toList();
    if (suggestions.isEmpty) return 0;

    await batch((batch) {
      batch.insertAll(routeMatchSuggestions, [
        for (final entry in suggestions)
          RouteMatchSuggestionsCompanion(
            rideId: Value(rideId),
            routeId: Value(entry.key),
            similarityScore: Value(entry.value.similarityScore),
            distanceDifferenceMeters: Value(
              entry.value.distanceDifferenceMeters,
            ),
          ),
      ]);
    });
    return suggestions.length;
  }

  Future<void> confirmRouteSuggestion(int suggestionId) =>
      transaction(() async {
        final suggestion = await (select(
          routeMatchSuggestions,
        )..where((row) => row.id.equals(suggestionId))).getSingle();
        if (suggestion.status != RouteSuggestionStatus.pending) {
          throw StateError('La sugerencia ya fue resuelta.');
        }

        await (update(rides)
              ..where((ride) => ride.id.equals(suggestion.rideId)))
            .write(RidesCompanion(routeId: Value(suggestion.routeId)));
        await (update(
          routeMatchSuggestions,
        )..where((row) => row.rideId.equals(suggestion.rideId))).write(
          const RouteMatchSuggestionsCompanion(
            status: Value(RouteSuggestionStatus.dismissed),
          ),
        );
        await (update(
          routeMatchSuggestions,
        )..where((row) => row.id.equals(suggestionId))).write(
          const RouteMatchSuggestionsCompanion(
            status: Value(RouteSuggestionStatus.confirmed),
          ),
        );
      });

  Future<void> dismissRouteSuggestion(int suggestionId) async {
    await (update(
      routeMatchSuggestions,
    )..where((row) => row.id.equals(suggestionId))).write(
      const RouteMatchSuggestionsCompanion(
        status: Value(RouteSuggestionStatus.dismissed),
      ),
    );
  }

  Future<int> bikeOdometerMeters(int bikeId) async {
    final bike = await (select(
      bikes,
    )..where((row) => row.id.equals(bikeId))).getSingleOrNull();
    if (bike == null) throw StateError('No existe la bicicleta $bikeId.');

    final totalDistance = rides.distanceMeters.sum();
    final result =
        await (selectOnly(rides)
              ..addColumns([totalDistance])
              ..where(
                rides.bikeId.equals(bikeId) &
                    rides.status.equals(RideStatus.completed) &
                    rides.startedAt.isBiggerOrEqualValue(
                      bike.odometerBaselineAt,
                    ),
              ))
            .getSingle();

    return bike.odometerBaselineMeters + (result.read(totalDistance) ?? 0);
  }

  Future<List<MaintenanceForecast>> maintenanceForecasts(int bikeId) async {
    final bike = await (select(
      bikes,
    )..where((row) => row.id.equals(bikeId))).getSingleOrNull();
    if (bike == null) throw StateError('No existe la bicicleta $bikeId.');

    final currentOdometerMeters = await bikeOdometerMeters(bikeId);
    final templates = await (select(
      maintenanceTemplates,
    )..where((template) => template.bikeType.equals(bike.type))).get();
    final templateByService = {
      for (final template in templates) template.serviceName: template,
    };
    final history =
        await (select(maintenanceEvents)
              ..where((event) => event.bikeId.equals(bikeId))
              ..orderBy([
                (event) => OrderingTerm.desc(event.odometerMeters),
                (event) => OrderingTerm.desc(event.servicedAt),
              ]))
            .get();

    final latestByService = <String, MaintenanceEvent>{};
    for (final event in history) {
      latestByService.putIfAbsent(event.serviceName, () => event);
    }

    final forecasts = <MaintenanceForecast>[];
    for (final event in latestByService.values) {
      final template = templateByService[event.serviceName];
      if (template != null && !template.isEnabled) continue;

      final intervalMeters = template == null
          ? event.serviceIntervalMeters
          : template.intervalMeters;
      if (intervalMeters == null) continue;

      forecasts.add(
        MaintenanceForecast(
          event: event,
          currentOdometerMeters: currentOdometerMeters,
          intervalMeters: intervalMeters,
        ),
      );
    }
    return forecasts;
  }

  Stream<List<MaintenanceEvent>> watchMaintenanceEvents(int bikeId) =>
      (select(maintenanceEvents)
            ..where((event) => event.bikeId.equals(bikeId))
            ..orderBy([(event) => OrderingTerm.desc(event.servicedAt)])
            ..limit(10))
          .watch();

  Future<int> recordMaintenanceEvent({
    required int bikeId,
    required String serviceName,
    required DateTime servicedAt,
    required int odometerMeters,
    String? notes,
  }) async {
    final bike = await (select(
      bikes,
    )..where((row) => row.id.equals(bikeId))).getSingleOrNull();
    if (bike == null) throw StateError('No existe la bicicleta $bikeId.');

    final template =
        await (select(maintenanceTemplates)..where(
              (row) =>
                  row.bikeType.equals(bike.type) &
                  row.serviceName.equals(serviceName) &
                  row.isEnabled.equals(true),
            ))
            .getSingleOrNull();
    if (template == null) {
      throw StateError('El servicio no está habilitado en la plantilla.');
    }
    if (odometerMeters < 0) {
      throw ArgumentError.value(odometerMeters, 'odometerMeters');
    }
    final currentOdometerMeters = await bikeOdometerMeters(bikeId);
    if (odometerMeters > currentOdometerMeters) {
      throw ArgumentError.value(
        odometerMeters,
        'odometerMeters',
        'No puede superar el odómetro actual de la bicicleta.',
      );
    }

    return into(maintenanceEvents).insert(
      MaintenanceEventsCompanion(
        bikeId: Value(bikeId),
        serviceName: Value(serviceName),
        servicedAt: Value(servicedAt.toUtc()),
        odometerMeters: Value(odometerMeters),
        serviceIntervalMeters: Value(template.intervalMeters),
        notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      ),
    );
  }

  Stream<List<MaintenanceTemplate>> watchMaintenanceTemplates(
    String bikeType,
  ) =>
      (select(maintenanceTemplates)
            ..where((template) => template.bikeType.equals(bikeType))
            ..orderBy([(template) => OrderingTerm.asc(template.serviceName)]))
          .watch();

  Future<void> saveMaintenanceTemplate({
    required String bikeType,
    required String serviceName,
    required int? intervalMeters,
    bool isEnabled = true,
  }) async {
    final normalizedName = serviceName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre del servicio es obligatorio.');
    }

    await transaction(() async {
      final existing =
          await (select(maintenanceTemplates)..where(
                (template) =>
                    template.bikeType.equals(bikeType) &
                    template.serviceName.equals(normalizedName),
              ))
              .getSingleOrNull();
      final updatedAt = DateTime.now().toUtc();
      if (existing == null) {
        await into(maintenanceTemplates).insert(
          MaintenanceTemplatesCompanion(
            bikeType: Value(bikeType),
            serviceName: Value(normalizedName),
            intervalMeters: Value(intervalMeters),
            isEnabled: Value(isEnabled),
            updatedAt: Value(updatedAt),
          ),
        );
      } else {
        await (update(maintenanceTemplates)..where(
              (template) =>
                  template.bikeType.equals(bikeType) &
                  template.serviceName.equals(normalizedName),
            ))
            .write(
              MaintenanceTemplatesCompanion(
                intervalMeters: Value(intervalMeters),
                isEnabled: Value(isEnabled),
                updatedAt: Value(updatedAt),
              ),
            );
      }
    });
  }
}
