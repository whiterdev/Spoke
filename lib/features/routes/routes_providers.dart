import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';

final routesHistoryProvider = StreamProvider.autoDispose<List<Ride>>(
  (ref) => ref.watch(appDatabaseProvider).watchCompletedRides(),
);

final pendingRouteMatchesProvider =
    StreamProvider.autoDispose<List<PendingRouteMatch>>(
      (ref) => ref.watch(appDatabaseProvider).watchPendingRouteMatches(),
    );
