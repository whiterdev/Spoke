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
    'editing a bike preserves its odometer and seeds its new type',
    () async {
      final originalBaselineAt = DateTime.utc(2025, 1, 1);
      final bikeId = await database.createBike(
        BikesCompanion.insert(
          brand: 'Marca anterior',
          model: 'Modelo anterior',
          type: const Value(BikeType.road),
          odometerBaselineMeters: const Value(10000),
          odometerBaselineAt: Value(originalBaselineAt),
        ),
      );
      await database
          .into(database.rides)
          .insert(
            RidesCompanion.insert(
              startedAt: DateTime.utc(2025, 1, 2),
              distanceMeters: const Value(4000),
              status: const Value(RideStatus.completed),
              bikeId: Value(bikeId),
            ),
          );

      expect(await database.bikeOdometerMeters(bikeId), 14000);

      final updatedRows = await database.updateBike(
        bikeId,
        BikesCompanion(
          type: const Value(BikeType.gravel),
          brand: const Value('Nueva marca'),
          model: const Value('Nuevo modelo'),
          nickname: const Value('La gravel'),
          photoPath: const Value('/local/bike.jpg'),
          odometerBaselineMeters: const Value(14000),
          odometerBaselineAt: Value(DateTime.utc(2025, 1, 3)),
        ),
      );

      expect(updatedRows, 1);
      expect(await database.bikeOdometerMeters(bikeId), 14000);

      await database
          .into(database.rides)
          .insert(
            RidesCompanion.insert(
              startedAt: DateTime.utc(2025, 1, 4),
              distanceMeters: const Value(2500),
              status: const Value(RideStatus.completed),
              bikeId: Value(bikeId),
            ),
          );
      expect(await database.bikeOdometerMeters(bikeId), 16500);

      final updatedBike = (await database.watchBikes().first).single;
      expect(updatedBike.brand, 'Nueva marca');
      expect(updatedBike.model, 'Nuevo modelo');
      expect(updatedBike.type, BikeType.gravel);
      expect(updatedBike.nickname, 'La gravel');
      expect(updatedBike.photoPath, '/local/bike.jpg');
      expect(updatedBike.odometerBaselineAt, DateTime.utc(2025, 1, 3));

      final gravelServices = await database
          .watchMaintenanceTemplates(BikeType.gravel)
          .first;
      expect(
        gravelServices.map((service) => service.serviceName),
        contains('Sistema tubeless'),
      );
    },
  );

  test('updating a bike that no longer exists reports zero rows', () async {
    final updatedRows = await database.updateBike(
      999,
      const BikesCompanion(brand: Value('Marca')),
    );

    expect(updatedRows, 0);
  });

  test(
    'editing profile fields without changing the odometer preserves it',
    () async {
      final baselineAt = DateTime.utc(2025, 1, 1);
      final bikeId = await database.createBike(
        BikesCompanion.insert(
          brand: 'Marca',
          model: 'Modelo',
          odometerBaselineMeters: const Value(10000),
          odometerBaselineAt: Value(baselineAt),
        ),
      );
      await database
          .into(database.rides)
          .insert(
            RidesCompanion.insert(
              startedAt: DateTime.utc(2025, 1, 2),
              distanceMeters: const Value(4000),
              status: const Value(RideStatus.completed),
              bikeId: Value(bikeId),
            ),
          );

      await database.updateBike(
        bikeId,
        const BikesCompanion(nickname: Value('Mi bici')),
      );

      final bike = (await database.watchBikes().first).single;
      expect(bike.odometerBaselineAt, baselineAt);
      expect(await database.bikeOdometerMeters(bikeId), 14000);
    },
  );
}
