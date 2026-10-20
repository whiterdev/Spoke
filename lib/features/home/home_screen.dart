import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../app/spoke_brand_mark.dart';
import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyRides = ref.watch(homeLastSevenDaysRidesProvider);
    final recentRides = ref.watch(homeRecentRidesProvider);
    final riderProfile = ref.watch(riderProfileProvider).asData?.value;
    final recentItems = recentRides.asData?.value ?? const <Ride>[];
    final latestDay = recentItems.isEmpty
        ? _localDay(DateTime.now())
        : _localDay(recentItems.first.startedAt);
    final latestDayRides = ref.watch(homeRidesForDayProvider(latestDay));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            sliver: SliverList.list(
              children: [
                _DashboardHeader(displayName: riderProfile?.displayName),
                const SizedBox(height: 16),
                _WeekSummary(rides: weeklyRides),
                const SizedBox(height: 18),
                _LatestRideSection(
                  recentRides: recentRides,
                  dayRides: latestDayRides,
                ),
                const SizedBox(height: 18),
                _RecentRidesSection(rides: recentRides),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.displayName});

  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SpokeBrandMark(size: 38),
            const SizedBox(width: 10),
            Text(
              'SPOKE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              _dateLabel(today, includeWeekday: true).toUpperCase(),
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          displayName?.trim().isNotEmpty == true
              ? 'Hola, ${displayName!.trim()}'
              : 'Tu actividad',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({required this.rides});

  final AsyncValue<List<Ride>> rides;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.divider),
    ),
    child: rides.when(
      data: (items) {
        final totalDistance = items.fold<int>(
          0,
          (total, ride) => total + ride.distanceMeters,
        );
        final totalElevation = items.fold<double>(
          0,
          (total, ride) => total + (ride.elevationGainMeters ?? 0),
        );
        final totalDuration = items.fold<int>(
          0,
          (total, ride) => total + ride.durationSeconds,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'ÚLTIMOS 7 DÍAS',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDistance(totalDistance),
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 7, bottom: 3),
                  child: Text(
                    'km',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            _WeekDistanceChart(rides: items),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: _WeekMetric(
                    value: '${items.length}',
                    label: 'Salidas',
                  ),
                ),
                Expanded(
                  child: _WeekMetric(
                    value: _formatDuration(totalDuration),
                    label: 'En bici',
                  ),
                ),
                Expanded(
                  child: _WeekMetric(
                    value: '${totalElevation.round()} m',
                    label: 'Desnivel',
                  ),
                ),
              ],
            ),
          ],
        );
      },
      error: (error, stackTrace) => const _SummaryMessage(
        icon: Icons.cloud_off_rounded,
        label: 'No se pudo cargar el resumen.',
      ),
      loading: () => const SizedBox(
        height: 185,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    ),
  );
}

class _WeekDistanceChart extends StatelessWidget {
  const _WeekDistanceChart({required this.rides});

  final List<Ride> rides;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final firstDate = todayDate.subtract(const Duration(days: 6));
    final distances = List<double>.filled(7, 0);

    for (final ride in rides) {
      final date = ride.startedAt.toLocal();
      final day = DateTime(date.year, date.month, date.day);
      final index = day.difference(firstDate).inDays;
      if (index >= 0 && index < distances.length) {
        distances[index] += ride.distanceMeters / 1000;
      }
    }

    final maxDistance = distances.fold<double>(
      0,
      (maximum, distance) => math.max(maximum, distance),
    );
    final maxBarHeight = maxDistance == 0 ? 4.0 : 28.0;
    const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return SizedBox(
      height: maxDistance == 0 ? 32 : 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < distances.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 13,
                          height: distances[index] == 0
                              ? 4
                              : math.max(
                                  9,
                                  maxBarHeight * distances[index] / maxDistance,
                                ),
                          decoration: BoxDecoration(
                            color: distances[index] == 0
                                ? AppColors.raisedSurface
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayLabels[(firstDate.add(Duration(days: index)).weekday -
                          1)],
                      style: TextStyle(
                        color: index == 6
                            ? AppColors.accent
                            : AppColors.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekMetric extends StatelessWidget {
  const _WeekMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w800),
  );
}

class _LatestRideSection extends StatelessWidget {
  const _LatestRideSection({required this.recentRides, required this.dayRides});

  final AsyncValue<List<Ride>> recentRides;
  final AsyncValue<List<Ride>> dayRides;

  @override
  Widget build(BuildContext context) => recentRides.when(
    data: (items) => items.isEmpty
        ? const _NoRideCard()
        : dayRides.when(
            data: (items) => items.isEmpty
                ? const _NoRideCard()
                : _LatestDayCard(rides: items),
            error: (error, stackTrace) => const _SummaryMessage(
              icon: Icons.cloud_off_rounded,
              label: 'No se pudo cargar la actividad.',
            ),
            loading: () => const _LoadingRideCard(),
          ),
    error: (error, stackTrace) => const _SummaryMessage(
      icon: Icons.cloud_off_rounded,
      label: 'No se pudo cargar la actividad.',
    ),
    loading: () => const _LoadingRideCard(),
  );
}

class _LatestDayCard extends StatelessWidget {
  const _LatestDayCard({required this.rides});

  final List<Ride> rides;

  @override
  Widget build(BuildContext context) {
    final firstRide = rides.first;
    final distanceMeters = rides.fold<int>(
      0,
      (total, ride) => total + ride.distanceMeters,
    );
    final durationSeconds = rides.fold<int>(
      0,
      (total, ride) => total + ride.durationSeconds,
    );
    final elevationMeters = rides.fold<double>(
      0,
      (total, ride) => total + (ride.elevationGainMeters ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ÚLTIMO DÍA ACTIVO',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _dateLabel(firstRide.startedAt.toLocal()),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                rides.length == 1 ? '1 salida' : '${rides.length} salidas',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _RideMetric(
                  value: '${_formatDistance(distanceMeters)} km',
                  label: 'Distancia',
                ),
              ),
              Expanded(
                child: _RideMetric(
                  value: _formatDuration(durationSeconds),
                  label: 'Tiempo',
                ),
              ),
              Expanded(
                child: _RideMetric(
                  value: '${elevationMeters.round()} m',
                  label: 'Desnivel',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RideMetric extends StatelessWidget {
  const _RideMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 9),
      ),
    ],
  );
}

class _RecentRidesSection extends StatelessWidget {
  const _RecentRidesSection({required this.rides});

  final AsyncValue<List<Ride>> rides;

  @override
  Widget build(BuildContext context) => rides.when(
    data: (items) {
      if (items.isEmpty) return const SizedBox.shrink();

      final recentRides = items.take(3).toList(growable: false);
      if (recentRides.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Últimas salidas'),
          const SizedBox(height: 11),
          for (final ride in recentRides) ...[
            _RecentRideCard(ride: ride),
            if (ride != recentRides.last) const SizedBox(height: 9),
          ],
        ],
      );
    },
    error: (error, stackTrace) => const SizedBox.shrink(),
    loading: () => const SizedBox.shrink(),
  );
}

class _RecentRideCard extends StatelessWidget {
  const _RecentRideCard({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.raisedSurface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: AppColors.accent,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.title?.trim().isNotEmpty == true
                        ? ride.title!.trim()
                        : 'Salida en bici',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _dateLabel(ride.startedAt.toLocal()),
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_formatDistance(ride.distanceMeters)} km',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _RideMetric(
                value: _formatDuration(ride.durationSeconds),
                label: 'Tiempo',
              ),
            ),
            Expanded(
              child: _RideMetric(
                value: ride.averageSpeedMetersPerSecond == null
                    ? '—'
                    : '${_formatDecimal(ride.averageSpeedMetersPerSecond! * 3.6)} km/h',
                label: 'Velocidad media',
              ),
            ),
            Expanded(
              child: _RideMetric(
                value: ride.elevationGainMeters == null
                    ? '—'
                    : '${ride.elevationGainMeters!.round()} m',
                label: 'Desnivel',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _NoRideCard extends StatelessWidget {
  const _NoRideCard();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.divider),
    ),
    child: const Row(
      children: [
        Icon(Icons.pedal_bike_rounded, color: AppColors.accent, size: 23),
        SizedBox(width: 12),
        Text(
          'Aún no hay salidas',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _LoadingRideCard extends StatelessWidget {
  const _LoadingRideCard();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 88,
    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondaryText, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatDistance(int meters) =>
    (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');

String _formatDecimal(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

DateTime _localDay(DateTime dateTime) {
  final date = dateTime.toLocal();
  return DateTime(date.year, date.month, date.day);
}

String _formatDuration(int seconds) {
  if (seconds > 0 && seconds < 60) return '<1 min';
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) return '$hours h ${minutes.toString().padLeft(2, '0')} m';
  return '$minutes min';
}

String _dateLabel(DateTime date, {bool includeWeekday = false}) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  const weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  final prefix = includeWeekday ? '${weekdays[date.weekday - 1]} · ' : '';
  final year = date.year == DateTime.now().year ? '' : ' ${date.year}';
  return '$prefix${date.day} ${months[date.month - 1]}$year';
}
