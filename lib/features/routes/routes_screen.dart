import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../app/app_theme.dart';
import '../../app/google_maps_preferences.dart';
import '../../app/map_provider_selection.dart';
import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';
import '../../data/routes/route_track_segments.dart';
import 'ride_route_screen.dart';
import 'route_map_markers.dart';
import 'routes_providers.dart';

const _routeTrackColors = <int>[
  0xFFC8F36D,
  0xFF56D9F2,
  0xFFFFA36B,
  0xFFD5A0FF,
  0xFFFF7594,
  0xFF73E2B1,
];
const _osmTileUrl = String.fromEnvironment(
  'OSM_TILE_URL',
  defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
);
const _osmUserAgent = 'Spoke/1.0.0 (com.spoke.spoke_app)';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rides = ref.watch(routesHistoryProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            sliver: SliverList.list(
              children: [
                const Text(
                  'TU HISTORIAL',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Historial',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 18),
                rides.when(
                  data: (items) => _RideHistory(items: items),
                  error: (error, stackTrace) => const _HistoryErrorCard(),
                  loading: () => const _HistoryLoading(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
    ),
  );
}

class _RideHistory extends ConsumerWidget {
  const _RideHistory({required this.items});

  final List<Ride> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const _EmptyHistory();

    final pendingMatches =
        ref.watch(pendingRouteMatchesProvider).asData?.value ??
        const <PendingRouteMatch>[];
    final totalMeters = items.fold<int>(
      0,
      (total, ride) => total + ride.distanceMeters,
    );
    final totalSeconds = items.fold<int>(
      0,
      (total, ride) => total + ride.durationSeconds,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingMatches.isNotEmpty) ...[
          const Text(
            'Posibles repeticiones',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final match in pendingMatches) ...[
            _RouteMatchSuggestionCard(match: match),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 15),
        ],
        Row(
          children: [
            Expanded(
              child: _HistoryStat(
                value: '${items.length}',
                label: 'SALIDAS',
                icon: Icons.route_rounded,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _HistoryStat(
                value: _formatDistance(totalMeters),
                label: 'KILÓMETROS',
                icon: Icons.straighten_rounded,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _HistoryStat(
                value: _formatHours(totalSeconds),
                label: 'EN BICI',
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Salidas',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${items.length} ${items.length == 1 ? 'salida' : 'salidas'}',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        for (final ride in items) ...[
          _RideCard(ride: ride, onTap: () => _showRideDetails(context, ride)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _showRideDetails(BuildContext context, Ride ride) {
    final database = ProviderScope.containerOf(context)
        .read(appDatabaseProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _RideDetailsSheet(ride: ride, database: database),
    );
  }
}

class _RouteMatchSuggestionCard extends ConsumerWidget {
  const _RouteMatchSuggestionCard({required this.match});

  final PendingRouteMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = (match.suggestion.similarityScore * 100).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: .55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AppColors.accent,
                size: 17,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'POSIBLE REPETICIÓN',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            match.route.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salida del ${_formatDate(match.ride.startedAt.toLocal())} · '
            '${_formatDistance(match.ride.distanceMeters)} km  '
            '(ruta ${_formatDistance(match.route.distanceMeters ?? 0)} km)',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _resolve(context, ref, confirm: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryText,
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('No es la misma'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton(
                  onPressed: () => _resolve(context, ref, confirm: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Confirmar repetición'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref, {
    required bool confirm,
  }) async {
    final database = ref.read(appDatabaseProvider);
    try {
      if (confirm) {
        await database.confirmRouteSuggestion(match.suggestion.id);
      } else {
        await database.dismissRouteSuggestion(match.suggestion.id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              confirm ? 'Repetición confirmada.' : 'Sugerencia descartada.',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar la sugerencia.')),
        );
      }
    }
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 13, 8, 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride, required this.onTap});

  final Ride ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = ride.startedAt.toLocal();
    final distance = _formatDistance(ride.distanceMeters);
    final averageSpeed = ((ride.averageSpeedMetersPerSecond ?? 0) * 3.6)
        .toStringAsFixed(1);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: AppColors.raisedSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.title?.isNotEmpty == true
                          ? ride.title!
                          : 'Salida en bicicleta',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(date)}  ·  ${_formatDuration(ride.durationSeconds)}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '$distance km',
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.speed_rounded,
                          color: AppColors.accent,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$averageSpeed km/h',
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.raisedSurface,
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(
            Icons.route_outlined,
            color: AppColors.accent,
            size: 27,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Tu primera salida empieza acá',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cuando guardes un recorrido, vas a encontrar acá sus kilómetros, duración, velocidad y trazado GPS.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => context.go('/record'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Grabar salida'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _HistoryErrorCard extends StatelessWidget {
  const _HistoryErrorCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: AppColors.divider),
    ),
    child: const Text(
      'No se pudo cargar tu historial.',
      style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
    ),
  );
}

class _RideDetailsSheet extends StatefulWidget {
  const _RideDetailsSheet({required this.ride, required this.database});

  final Ride ride;
  final AppDatabase database;

  @override
  State<_RideDetailsSheet> createState() => _RideDetailsSheetState();
}

class _RideDetailsSheetState extends State<_RideDetailsSheet> {
  late final Future<List<RideTrackPoint>> _trackPoints;

  @override
  void initState() {
    super.initState();
    _trackPoints = widget.database.getRideTrackPoints(widget.ride.id);
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final averageSpeed = (ride.averageSpeedMetersPerSecond ?? 0) * 3.6;
    final maxSpeed = (ride.maxSpeedMetersPerSecond ?? 0) * 3.6;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 21),
            Text(
              ride.title?.isNotEmpty == true
                  ? ride.title!
                  : 'Salida en bicicleta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(ride.startedAt.toLocal(), includeTime: true),
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 17),
            FutureBuilder<List<RideTrackPoint>>(
              future: _trackPoints,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const _TrackUnavailable();
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                final points = snapshot.data!;
                if (points.length < 2) return const _TrackUnavailable();
                return Column(
                  children: [
                    _HistoryTrackMap(points: points),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openRideRoute(
                              context,
                              ride,
                              points,
                              mode: RideRouteViewMode.follow,
                            ),
                            icon: const Icon(Icons.navigation_rounded),
                            label: const Text('Seguir ruta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: const BorderSide(color: AppColors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _openRideRoute(
                              context,
                              ride,
                              points,
                              mode: RideRouteViewMode.replay,
                            ),
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            label: const Text('Reproducir'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: _DetailMetric(
                    label: 'Distancia',
                    value: '${_formatDistance(ride.distanceMeters)} km',
                    icon: Icons.route_rounded,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _DetailMetric(
                    label: 'Tiempo en movimiento',
                    value: _formatDuration(ride.durationSeconds),
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _DetailMetric(
                    label: 'Velocidad media',
                    value: '${averageSpeed.toStringAsFixed(1)} km/h',
                    icon: Icons.speed_rounded,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _DetailMetric(
                    label: 'Desnivel positivo',
                    value:
                        '${(ride.elevationGainMeters ?? 0).toStringAsFixed(0)} m',
                    icon: Icons.terrain_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _DetailMetric(
              label: 'Velocidad máxima',
              value: '${maxSpeed.toStringAsFixed(1)} km/h',
              icon: Icons.bolt_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

void _openRideRoute(
  BuildContext context,
  Ride ride,
  List<RideTrackPoint> points, {
  required RideRouteViewMode mode,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RideRouteScreen(ride: ride, points: points, mode: mode),
    ),
  );
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 17),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TrackUnavailable extends StatelessWidget {
  const _TrackUnavailable();

  @override
  Widget build(BuildContext context) => Container(
    height: 138,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.raisedSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.divider),
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.route_outlined, color: AppColors.accent, size: 27),
        SizedBox(height: 7),
        Text(
          'No hay suficientes puntos GPS para mostrar el trazado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText, fontSize: 10),
        ),
      ],
    ),
  );
}

class _HistoryTrackMap extends StatefulWidget {
  const _HistoryTrackMap({required this.points});

  final List<RideTrackPoint> points;

  @override
  State<_HistoryTrackMap> createState() => _HistoryTrackMapState();
}

class _HistoryTrackMapState extends State<_HistoryTrackMap> {
  bool _useOpenStreetMap = false;
  bool _googleMapsEnabled = false;
  bool _googleMapsReady = false;
  Timer? _googleMapsLoadWatchdog;

  @override
  void initState() {
    super.initState();
    _loadGoogleMapsPreference();
  }

  @override
  void dispose() {
    _googleMapsLoadWatchdog?.cancel();
    super.dispose();
  }

  Future<void> _loadGoogleMapsPreference() async {
    try {
      final googleMapsEnabled = await shouldUseGoogleMaps();
      if (mounted) {
        setState(() => _googleMapsEnabled = googleMapsEnabled);
      }
    } catch (_) {
      if (mounted) setState(() => _googleMapsEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = savedRoutesMapProvider(
      googleMapsEnabled: _googleMapsEnabled && !_useOpenStreetMap,
    );
    if (mapProvider == MapProvider.googleMaps) {
      _startGoogleMapsLoadWatchdog();
      return _GoogleMapsTrackMap(
        tracks: [widget.points],
        label: 'TRAZADO GPS',
        height: 210,
        onMapCreated: _onGoogleMapsCreated,
      );
    }

    return _openStreetMapTrackMap(
      context,
      tracks: [widget.points],
      label: 'TRAZADO GPS',
      height: 190,
    );
  }

  void _startGoogleMapsLoadWatchdog() {
    if (_googleMapsReady || _useOpenStreetMap) return;
    _googleMapsLoadWatchdog ??= Timer(const Duration(seconds: 20), () {
      _googleMapsLoadWatchdog = null;
      if (!mounted || _googleMapsReady) return;
      setState(() => _useOpenStreetMap = true);
    });
  }

  void _onGoogleMapsCreated() {
    _googleMapsLoadWatchdog?.cancel();
    _googleMapsLoadWatchdog = null;
    _googleMapsReady = true;
  }
}

class _MapTag extends StatelessWidget {
  const _MapTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.accent,
        fontSize: 8,
        fontWeight: FontWeight.w800,
        letterSpacing: .8,
      ),
    ),
  );
}

class _MapTrackSegment {
  const _MapTrackSegment({required this.routeIndex, required this.points});

  final int routeIndex;
  final List<RideTrackPoint> points;
}

List<_MapTrackSegment> _validMapTrackSegments(
  List<List<RideTrackPoint>> tracks,
) {
  final validTracks = <_MapTrackSegment>[];
  for (var routeIndex = 0; routeIndex < tracks.length; routeIndex++) {
    for (final segment in splitRouteTrackAtGaps(
      tracks[routeIndex],
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    )) {
      final validPoints = [
        for (final point in segment)
          if (point.latitude.isFinite &&
              point.longitude.isFinite &&
              point.latitude >= -90 &&
              point.latitude <= 90 &&
              point.longitude >= -180 &&
              point.longitude <= 180)
            point,
      ];
      if (validPoints.isNotEmpty) {
        validTracks.add(
          _MapTrackSegment(routeIndex: routeIndex, points: validPoints),
        );
      }
    }
  }
  return validTracks;
}

class _GoogleMapsTrackMap extends StatefulWidget {
  const _GoogleMapsTrackMap({
    required this.tracks,
    required this.label,
    required this.height,
    required this.onMapCreated,
  });

  final List<List<RideTrackPoint>> tracks;
  final String label;
  final double height;
  final VoidCallback onMapCreated;

  @override
  State<_GoogleMapsTrackMap> createState() => _GoogleMapsTrackMapState();
}

class _GoogleMapsTrackMapState extends State<_GoogleMapsTrackMap> {
  gmaps.GoogleMapController? _controller;
  gmaps.CameraPosition? _cameraPosition;
  RouteMapMarkerIcons? _markerIcons;
  gmaps.MapType _mapType = gmaps.MapType.normal;
  bool _threeD = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMarkerIcons());
  }

  Future<void> _loadMarkerIcons() async {
    final icons = await RouteMapMarkerIcons.load();
    if (mounted) setState(() => _markerIcons = icons);
  }

  @override
  Widget build(BuildContext context) {
    final validTracks = _validMapTrackSegments(widget.tracks);
    final allPoints = validTracks.expand((track) => track.points).toList();
    final initialPoint = allPoints.isEmpty
        ? const gmaps.LatLng(-34.574, -58.418)
        : gmaps.LatLng(allPoints.first.latitude, allPoints.first.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: initialPoint,
                zoom: 14,
              ),
              mapType: _mapType,
              compassEnabled: true,
              buildingsEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              polylines: {
                for (var index = 0; index < validTracks.length; index++)
                  if (validTracks[index].points.length > 1)
                    gmaps.Polyline(
                      polylineId: gmaps.PolylineId('track-$index'),
                      points: [
                        for (final point in _sampleRouteTrack(
                          validTracks[index].points,
                        ))
                          gmaps.LatLng(point.latitude, point.longitude),
                      ],
                      color: Color(
                        _routeTrackColors[validTracks[index].routeIndex %
                            _routeTrackColors.length],
                      ),
                      width: 5,
                      zIndex: validTracks[index].routeIndex,
                    ),
              },
              markers: {
                for (var index = 0; index < validTracks.length; index++)
                  if (validTracks[index].points.length > 1) ...[
                    if (index == 0 ||
                        validTracks[index - 1].routeIndex !=
                            validTracks[index].routeIndex)
                      gmaps.Marker(
                        markerId: gmaps.MarkerId(
                          'start-${validTracks[index].routeIndex}',
                        ),
                        position: gmaps.LatLng(
                          validTracks[index].points.first.latitude,
                          validTracks[index].points.first.longitude,
                        ),
                        icon:
                            _markerIcons?.start ??
                            gmaps.BitmapDescriptor.defaultMarkerWithHue(
                              gmaps.BitmapDescriptor.hueGreen,
                            ),
                        anchor: const Offset(.5, .5),
                        infoWindow: const gmaps.InfoWindow(title: 'Inicio'),
                      ),
                    if (index == validTracks.length - 1 ||
                        validTracks[index + 1].routeIndex !=
                            validTracks[index].routeIndex)
                      gmaps.Marker(
                        markerId: gmaps.MarkerId(
                          'finish-${validTracks[index].routeIndex}',
                        ),
                        position: gmaps.LatLng(
                          validTracks[index].points.last.latitude,
                          validTracks[index].points.last.longitude,
                        ),
                        icon:
                            _markerIcons?.finish ??
                            gmaps.BitmapDescriptor.defaultMarkerWithHue(
                              gmaps.BitmapDescriptor.hueRed,
                            ),
                        anchor: const Offset(.25, .92),
                        infoWindow: const gmaps.InfoWindow(title: 'Meta'),
                      ),
                  ],
              },
              onMapCreated: _onMapCreated,
              onCameraMove: (position) => _cameraPosition = position,
            ),
            Positioned(top: 10, left: 10, child: _MapTag(label: widget.label)),
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<gmaps.MapType>(
                    tooltip: 'Estilo del mapa',
                    onSelected: (mapType) => setState(() => _mapType = mapType),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: gmaps.MapType.normal,
                        child: Text('Mapa estándar'),
                      ),
                      PopupMenuItem(
                        value: gmaps.MapType.terrain,
                        child: Text('Relieve'),
                      ),
                      PopupMenuItem(
                        value: gmaps.MapType.satellite,
                        child: Text('Satélite'),
                      ),
                      PopupMenuItem(
                        value: gmaps.MapType.hybrid,
                        child: Text('Satélite con calles'),
                      ),
                    ],
                    child: _MapControl(
                      icon: Icons.layers_rounded,
                      label: switch (_mapType) {
                        gmaps.MapType.normal => 'Mapa',
                        gmaps.MapType.terrain => 'Relieve',
                        gmaps.MapType.satellite => 'Satélite',
                        gmaps.MapType.hybrid => 'Híbrido',
                        _ => 'Mapa',
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _toggleThreeD,
                    borderRadius: BorderRadius.circular(20),
                    child: _MapControl(
                      icon: Icons.view_in_ar_rounded,
                      label: '3D',
                      selected: _threeD,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: _MapSourcesInfoButton(
                onTap: () =>
                    unawaited(_showMapSources(context, usingGoogleMaps: true)),
              ),
            ),
            if (allPoints.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sin puntos GPS para mostrar',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    _controller = controller;
    widget.onMapCreated();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitTracks());
  }

  Future<void> _fitTracks() async {
    final controller = _controller;
    if (controller == null) return;
    final points = _validMapTrackSegments(widget.tracks)
        .expand((track) => track.points)
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(points.first.latitude, points.first.longitude),
          15,
        ),
      );
      return;
    }

    var minLatitude = points
        .map((point) => point.latitude)
        .reduce((a, b) => a < b ? a : b);
    var maxLatitude = points
        .map((point) => point.latitude)
        .reduce((a, b) => a > b ? a : b);
    var minLongitude = points
        .map((point) => point.longitude)
        .reduce((a, b) => a < b ? a : b);
    var maxLongitude = points
        .map((point) => point.longitude)
        .reduce((a, b) => a > b ? a : b);
    const minimumSpan = .001;
    if (maxLatitude - minLatitude < minimumSpan) {
      minLatitude -= minimumSpan / 2;
      maxLatitude += minimumSpan / 2;
    }
    if (maxLongitude - minLongitude < minimumSpan) {
      minLongitude -= minimumSpan / 2;
      maxLongitude += minimumSpan / 2;
    }
    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(minLatitude, minLongitude),
          northeast: gmaps.LatLng(maxLatitude, maxLongitude),
        ),
        54,
      ),
    );
  }

  Future<void> _toggleThreeD() async {
    final nextThreeD = !_threeD;
    setState(() => _threeD = nextThreeD);
    final controller = _controller;
    if (controller == null) return;
    final current = _cameraPosition;
    final target = current?.target ?? const gmaps.LatLng(-34.574, -58.418);
    await controller.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: target,
          zoom: current?.zoom ?? 14,
          bearing: current?.bearing ?? 0,
          tilt: nextThreeD ? 45 : 0,
        ),
      ),
    );
  }
}

Widget _openStreetMapTrackMap(
  BuildContext context, {
  required List<List<RideTrackPoint>> tracks,
  required String label,
  required double height,
}) {
  final validTracks = _validMapTrackSegments(tracks);
  final allPoints = validTracks.expand((track) => track.points).toList();
  final initialPoint = allPoints.isEmpty
      ? const latlong.LatLng(-34.574, -58.418)
      : latlong.LatLng(allPoints.first.latitude, allPoints.first.longitude);

  fmap.CameraFit? cameraFit;
  if (allPoints.length > 1) {
    final minLatitude = allPoints
        .map((point) => point.latitude)
        .reduce((a, b) => a < b ? a : b);
    final maxLatitude = allPoints
        .map((point) => point.latitude)
        .reduce((a, b) => a > b ? a : b);
    final minLongitude = allPoints
        .map((point) => point.longitude)
        .reduce((a, b) => a < b ? a : b);
    final maxLongitude = allPoints
        .map((point) => point.longitude)
        .reduce((a, b) => a > b ? a : b);
    const minimumSpan = 0.001;
    final latitudeSpan = maxLatitude - minLatitude;
    final longitudeSpan = maxLongitude - minLongitude;
    final latitudePadding =
        (latitudeSpan < minimumSpan ? minimumSpan : latitudeSpan * .08) / 2;
    final longitudePadding =
        (longitudeSpan < minimumSpan ? minimumSpan : longitudeSpan * .08) / 2;
    cameraFit = fmap.CameraFit.bounds(
      bounds: fmap.LatLngBounds(
        latlong.LatLng(
          minLatitude - latitudePadding,
          minLongitude - longitudePadding,
        ),
        latlong.LatLng(
          maxLatitude + latitudePadding,
          maxLongitude + longitudePadding,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 36),
      maxZoom: 17,
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          fmap.FlutterMap(
            options: fmap.MapOptions(
              initialCenter: initialPoint,
              initialZoom: 14,
              initialCameraFit: cameraFit,
              minZoom: 3,
              maxZoom: 19,
              backgroundColor: const Color(0xFFE9EFEA),
            ),
            children: [
              fmap.TileLayer(
                urlTemplate: _osmTileUrl,
                userAgentPackageName: 'com.spoke.spoke_app',
                tileProvider: fmap.NetworkTileProvider(
                  headers: {'User-Agent': _osmUserAgent},
                  cachingProvider:
                      fmap.BuiltInMapCachingProvider.getOrCreateInstance(),
                ),
                maxZoom: 19,
                maxNativeZoom: 19,
              ),
              if (validTracks.any((track) => track.points.length > 1))
                fmap.PolylineLayer(
                  polylines: [
                    for (final segment in validTracks)
                      if (segment.points.length > 1)
                        fmap.Polyline(
                          points: [
                            for (final point in _sampleRouteTrack(
                              segment.points,
                            ))
                              latlong.LatLng(point.latitude, point.longitude),
                          ],
                          color: Color(
                            _routeTrackColors[segment.routeIndex %
                                _routeTrackColors.length],
                          ),
                          strokeWidth: 4.5,
                          borderColor: const Color(0xE607191D),
                          borderStrokeWidth: 1.5,
                        ),
                  ],
                ),
              if (validTracks.any((track) => track.points.length > 1))
                fmap.MarkerLayer(
                  markers: [
                    for (var index = 0; index < validTracks.length; index++)
                      if (validTracks[index].points.length > 1) ...[
                        if (index == 0 ||
                            validTracks[index - 1].routeIndex !=
                                validTracks[index].routeIndex)
                          _trackMarker(
                            validTracks[index].points.first,
                            validTracks[index].routeIndex,
                            true,
                          ),
                        if (index == validTracks.length - 1 ||
                            validTracks[index + 1].routeIndex !=
                                validTracks[index].routeIndex)
                          _trackMarker(
                            validTracks[index].points.last,
                            validTracks[index].routeIndex,
                            false,
                          ),
                      ],
                  ],
                ),
            ],
          ),
          Positioned(top: 10, left: 10, child: _MapTag(label: label)),
          Positioned(
            left: 8,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                _MapSourcesInfoButton(
                  onTap: () => unawaited(
                    _showMapSources(context, usingOpenStreetMap: true),
                  ),
                ),
              ],
            ),
          ),
          if (allPoints.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sin trazado GPS para mostrar',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

fmap.Marker _trackMarker(RideTrackPoint point, int index, bool isStart) =>
    fmap.Marker(
      key: ValueKey('track-${isStart ? 'start' : 'finish'}-$index'),
      point: latlong.LatLng(point.latitude, point.longitude),
      width: isStart ? 24 : 34,
      height: isStart ? 24 : 42,
      alignment: isStart ? Alignment.center : Alignment.bottomCenter,
      child: isStart
          ? const RouteStartMapMarker()
          : const RouteFinishMapMarker(size: Size(34, 42)),
    );

class _MapSourcesInfoButton extends StatelessWidget {
  const _MapSourcesInfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.background.withValues(alpha: .9),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const SizedBox.square(
        dimension: 30,
        child: Icon(
          Icons.info_outline_rounded,
          color: AppColors.primaryText,
          size: 17,
        ),
      ),
    ),
  );
}

Future<void> _showMapSources(
  BuildContext context, {
  bool usingOpenStreetMap = false,
  bool usingGoogleMaps = false,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Fuentes de datos del mapa',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.primaryText,
                ),
              ],
            ),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            if (usingGoogleMaps)
              const _MapSourceRow(
                title: 'Google Maps',
                detail: 'Mapa y datos cartográficos de Google. La grabación en vivo y las rutas guardadas usan Google Maps mientras esta opción está activa.',
              )
            else ...[
              _MapSourceRow(
                title: '© OpenStreetMap contributors',
                detail: usingOpenStreetMap
                    ? 'Mapa de esta vista y de la grabación en vivo. Licencia ODbL: openstreetmap.org/copyright.'
                    : 'Mapa para grabar en vivo y respaldo para las rutas guardadas.',
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _MapSourceRow extends StatelessWidget {
  const _MapSourceRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        detail,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected ? AppColors.accent : AppColors.divider,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? AppColors.accent : AppColors.primaryText,
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

List<RideTrackPoint> _sampleRouteTrack(List<RideTrackPoint> points) {
  const maxPoints = 240;
  if (points.length <= maxPoints) return points;
  final lastIndex = points.length - 1;
  return [
    for (var index = 0; index < maxPoints; index++)
      points[(index * lastIndex / (maxPoints - 1)).round()],
  ];
}

String _formatDistance(int meters) =>
    (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');

String _formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final remainingSeconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (minutes == 0) return '$remainingSeconds s';
  return '$minutes min ${remainingSeconds.toString().padLeft(2, '0')} s';
}

String _formatHours(int seconds) {
  final hours = seconds / 3600;
  return hours.toStringAsFixed(1).replaceAll('.', ',');
}

String _formatDate(DateTime date, {bool includeTime = false}) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final datePart = '$day/$month/${date.year}';
  if (!includeTime) return datePart;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$datePart · $hour:$minute';
}
