import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';

final bikesProvider = StreamProvider.autoDispose<List<Bike>>(
  (ref) => ref.watch(appDatabaseProvider).watchBikes(),
);

final bikeRidesRevisionProvider = StreamProvider.autoDispose<List<Ride>>(
  (ref) => ref.watch(appDatabaseProvider).watchRides(),
);

final bikeOdometerProvider = FutureProvider.autoDispose.family<int, int>((
  ref,
  bikeId,
) {
  ref.watch(bikeRidesRevisionProvider);
  return ref.watch(appDatabaseProvider).bikeOdometerMeters(bikeId);
});

final maintenanceTemplatesProvider = StreamProvider.autoDispose
    .family<List<MaintenanceTemplate>, String>(
      (ref, bikeType) =>
          ref.watch(appDatabaseProvider).watchMaintenanceTemplates(bikeType),
    );

final bikeMaintenanceEventsProvider = StreamProvider.autoDispose
    .family<List<MaintenanceEvent>, int>(
      (ref, bikeId) =>
          ref.watch(appDatabaseProvider).watchMaintenanceEvents(bikeId),
    );

final bikeMaintenanceForecastsProvider = FutureProvider.autoDispose
    .family<List<MaintenanceForecast>, int>((ref, bikeId) {
      ref.watch(bikeOdometerProvider(bikeId));
      return ref.watch(appDatabaseProvider).maintenanceForecasts(bikeId);
    });
