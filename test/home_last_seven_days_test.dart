import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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

  test('returns completed rides from the seven local calendar days', () async {
    final now = DateTime.now();
    final firstLocalDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    final firstIncludedInstant = firstLocalDay.toUtc();
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: firstIncludedInstant,
            distanceMeters: const Value(12000),
            status: const Value(RideStatus.completed),
          ),
        );
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: firstIncludedInstant.subtract(
              const Duration(seconds: 1),
            ),
            distanceMeters: const Value(24000),
            status: const Value(RideStatus.completed),
          ),
        );
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: now.subtract(const Duration(days: 2)),
            status: const Value(RideStatus.paused),
          ),
        );

    final rides = await database.watchLastSevenDaysRides().first;

    expect(rides, hasLength(1));
    expect(rides.single.distanceMeters, 12000);
  });
}
