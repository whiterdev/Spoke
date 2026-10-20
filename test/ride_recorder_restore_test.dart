import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/local/app_database.dart';
import 'package:spoke_app/data/local/app_database_provider.dart';
import 'package:spoke_app/features/record/ride_recorder.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'restores an interrupted ride paused with its saved GPS points',
    () async {
      final startedAt = DateTime.utc(2026, 10, 20, 12);
      final rideId = await database.startRide(
        RidesCompanion.insert(
          startedAt: startedAt,
          status: const Value(RideStatus.recording),
        ),
      );
      await database.appendTrackPoints(rideId, [
        RideTrackPointsCompanion.insert(
          rideId: rideId,
          sequence: 0,
          latitude: -34.6035,
          longitude: -58.4350,
          recordedAt: startedAt.add(const Duration(seconds: 30)),
        ),
      ]);

      await container.read(rideRecorderProvider.notifier).initialize();

      final restored = container.read(rideRecorderProvider);
      final storedRide = await database.activeRide();
      expect(restored.phase, RideRecordingPhase.paused);
      expect(restored.rideId, rideId);
      expect(restored.trackPoints, hasLength(1));
      expect(restored.elapsedSeconds, 30);
      expect(storedRide?.status, RideStatus.paused);
      expect(storedRide?.pausedAt != null, isTrue);
    },
  );
}
