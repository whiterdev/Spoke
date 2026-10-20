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

  test('returns every completed ride in a local calendar day', () async {
    final localDay = DateTime(2026, 10, 20);
    final start = DateTime(localDay.year, localDay.month, localDay.day).toUtc();
    final end = DateTime(
      localDay.year,
      localDay.month,
      localDay.day + 1,
    ).toUtc();

    for (var index = 0; index < 12; index++) {
      await database
          .into(database.rides)
          .insert(
            RidesCompanion.insert(
              startedAt: start.add(Duration(minutes: index * 30)),
              status: const Value(RideStatus.completed),
            ),
          );
    }
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: start.subtract(const Duration(seconds: 1)),
            status: const Value(RideStatus.completed),
          ),
        );
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: end,
            status: const Value(RideStatus.completed),
          ),
        );

    final rides = await database.watchRidesForLocalDay(localDay).first;

    expect(rides, hasLength(12));
    expect(rides.every((ride) => ride.status == RideStatus.completed), isTrue);
  });
}
