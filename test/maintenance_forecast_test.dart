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

  test(
    'forecasts service distance from last service and completed rides',
    () async {
      final baselineAt = DateTime.utc(2025, 1, 1);
      final bikeId = await database.createBike(
        BikesCompanion.insert(
          brand: 'Prueba',
          model: 'Ruta',
          type: const Value(BikeType.road),
          odometerBaselineMeters: const Value(50000),
          odometerBaselineAt: Value(baselineAt),
        ),
      );
      await database.saveMaintenanceTemplate(
        bikeType: BikeType.road,
        serviceName: 'Transmisión',
        intervalMeters: 10000,
      );
      await database
          .into(database.rides)
          .insert(
            RidesCompanion.insert(
              startedAt: DateTime.utc(2026, 1, 1),
              distanceMeters: const Value(15000),
              status: const Value(RideStatus.completed),
              bikeId: Value(bikeId),
            ),
          );
      await database.recordMaintenanceEvent(
        bikeId: bikeId,
        serviceName: 'Transmisión',
        servicedAt: DateTime.utc(2026, 1, 1),
        odometerMeters: 60000,
      );

      final firstForecasts = await database.maintenanceForecasts(bikeId);
      expect(firstForecasts, hasLength(1));
      expect(firstForecasts.single.currentOdometerMeters, 65000);
      expect(firstForecasts.single.dueAtOdometerMeters, 70000);
      expect(firstForecasts.single.remainingMeters, 5000);
      expect(firstForecasts.single.isDue, isFalse);

      await database.saveMaintenanceTemplate(
        bikeType: BikeType.road,
        serviceName: 'Transmisión',
        intervalMeters: 5000,
      );
      final editedForecast = (await database.maintenanceForecasts(bikeId))
          .single;
      expect(editedForecast.dueAtOdometerMeters, 65000);
      expect(editedForecast.isDue, isTrue);
    },
  );

  test('seeds editable maintenance intervals for each bike type', () async {
    final roadBikeId = await database.createBike(
      BikesCompanion.insert(
        brand: 'Prueba',
        model: 'Ruta',
        type: const Value(BikeType.road),
      ),
    );
    expect(roadBikeId, greaterThan(0));

    var roadTemplates = await database
        .watchMaintenanceTemplates(BikeType.road)
        .first;
    var roadByName = {
      for (final template in roadTemplates)
        template.serviceName: template.intervalMeters,
    };
    expect(roadByName['Inspección general'], 1000000);
    expect(roadByName['Transmisión'], 500000);
    expect(roadByName['Frenos'], 1000000);

    await database.saveMaintenanceTemplate(
      bikeType: BikeType.road,
      serviceName: 'Transmisión',
      intervalMeters: 420000,
    );
    await database.createBike(
      BikesCompanion.insert(
        brand: 'Otra',
        model: 'Ruta',
        type: const Value(BikeType.road),
      ),
    );
    roadTemplates = await database
        .watchMaintenanceTemplates(BikeType.road)
        .first;
    roadByName = {
      for (final template in roadTemplates)
        template.serviceName: template.intervalMeters,
    };
    expect(roadByName['Transmisión'], 420000);

    await database.createBike(
      BikesCompanion.insert(
        brand: 'Prueba',
        model: 'Montaña',
        type: const Value(BikeType.mountain),
      ),
    );
    final mountainTemplates = await database
        .watchMaintenanceTemplates(BikeType.mountain)
        .first;
    final mountainByName = {
      for (final template in mountainTemplates)
        template.serviceName: template.intervalMeters,
    };
    expect(mountainByName['Transmisión'], 300000);
    expect(mountainByName['Suspensión'], 500000);
  });

  test('rejects maintenance recorded beyond the bike odometer', () async {
    final baselineAt = DateTime.utc(2025, 1, 1);
    final bikeId = await database.createBike(
      BikesCompanion.insert(
        brand: 'Prueba',
        model: 'Ruta',
        type: const Value(BikeType.road),
        odometerBaselineMeters: const Value(50000),
        odometerBaselineAt: Value(baselineAt),
      ),
    );
    await database.saveMaintenanceTemplate(
      bikeType: BikeType.road,
      serviceName: 'Transmisión',
      intervalMeters: 10000,
    );
    await database
        .into(database.rides)
        .insert(
          RidesCompanion.insert(
            startedAt: DateTime.utc(2025, 1, 2),
            distanceMeters: const Value(15000),
            status: const Value(RideStatus.completed),
            bikeId: Value(bikeId),
          ),
        );

    await expectLater(
      database.recordMaintenanceEvent(
        bikeId: bikeId,
        serviceName: 'Transmisión',
        servicedAt: DateTime.utc(2025, 1, 2),
        odometerMeters: 65001,
      ),
      throwsArgumentError,
    );
    expect(await database.watchMaintenanceEvents(bikeId).first, isEmpty);
  });
}
