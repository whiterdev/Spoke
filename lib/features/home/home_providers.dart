import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';

final homeRecentRidesProvider = StreamProvider.autoDispose<List<Ride>>(
  (ref) => ref.watch(appDatabaseProvider).watchRecentRides(limit: 10),
);

final homeRidesForDayProvider = StreamProvider.autoDispose
    .family<List<Ride>, DateTime>(
      (ref, localDay) =>
          ref.watch(appDatabaseProvider).watchRidesForLocalDay(localDay),
    );

final homeLastSevenDaysRidesProvider = StreamProvider.autoDispose<List<Ride>>(
  (ref) => ref.watch(appDatabaseProvider).watchLastSevenDaysRides(),
);
