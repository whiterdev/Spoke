import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../data/local/app_database.dart';
import '../bikes/bikes_providers.dart';
import 'ride_recorder.dart';

class RideBikeSelectionScreen extends ConsumerStatefulWidget {
  const RideBikeSelectionScreen({super.key});

  @override
  ConsumerState<RideBikeSelectionScreen> createState() =>
      _RideBikeSelectionScreenState();
}

class _RideBikeSelectionScreenState
    extends ConsumerState<RideBikeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreActiveRide();
    });
  }

  Future<void> _restoreActiveRide() async {
    try {
      await ref.read(rideRecorderProvider.notifier).initialize();
      if (!mounted) return;
      final phase = ref.read(rideRecorderProvider).phase;
      if (phase == RideRecordingPhase.recording ||
          phase == RideRecordingPhase.paused) {
        context.go('/record/map');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo recuperar la salida.')),
        );
      }
    }
  }

  void _continueWithoutBike() => context.go('/record/map');

  @override
  Widget build(BuildContext context) {
    final bikes = ref.watch(bikesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            sliver: SliverList.list(
              children: [
                Text(
                  'Nueva salida',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '¿Con cuál bici vas a salir?',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 20),
                bikes.when(
                  data: (items) => items.isEmpty
                      ? _EmptyBikes(
                          onAdd: () => context.go('/bikes'),
                          onContinueWithoutBike: _continueWithoutBike,
                        )
                      : Column(
                          children: [
                            for (final bike in items) ...[
                              _RideBikeCard(
                                bike: bike,
                                onTap: () =>
                                    context.go('/record/map?bikeId=${bike.id}'),
                              ),
                              const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: _continueWithoutBike,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Continuar sin bici'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                  error: (error, stackTrace) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Text(
                      'No se pudieron cargar tus bicicletas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(36),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideBikeCard extends ConsumerWidget {
  const _RideBikeCard({required this.bike, required this.onTap});

  final Bike bike;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odometer = ref.watch(bikeOdometerProvider(bike.id));
    final forecasts = ref.watch(bikeMaintenanceForecastsProvider(bike.id));
    final title = [
      bike.brand,
      bike.model,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final displayName = bike.nickname?.trim().isNotEmpty == true
        ? bike.nickname!.trim()
        : title;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              _BikePhoto(path: bike.photoPath),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty ? 'Mi bicicleta' : displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (bike.nickname?.trim().isNotEmpty == true &&
                        title.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    _BikeTypePill(type: bike.type),
                    const SizedBox(height: 8),
                    odometer.when(
                      data: (meters) => Text(
                        '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km recorridos',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      error: (error, stackTrace) => const Text(
                        'Kilometraje no disponible',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      loading: () => const Text(
                        'Calculando kilometraje…',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    forecasts.when(
                      data: (items) {
                        if (items.isEmpty) return const SizedBox.shrink();
                        final next = [...items]
                          ..sort(
                            (a, b) =>
                                a.remainingMeters.compareTo(b.remainingMeters),
                          );
                        final forecast = next.first;
                        final maintenance = forecast.isDue
                            ? 'Revisión pendiente · ${forecast.event.serviceName}'
                            : '${forecast.event.serviceName} en ${(forecast.remainingMeters / 1000).ceil()} km';
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            maintenance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: forecast.isDue
                                  ? AppColors.accent
                                  : AppColors.secondaryText,
                              fontSize: 10,
                              fontWeight: forecast.isDue
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                      error: (error, stackTrace) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.accent,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BikePhoto extends StatelessWidget {
  const _BikePhoto({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(17),
    child: SizedBox(
      width: 96,
      height: 106,
      child: path == null
          ? const _BikePhotoPlaceholder()
          : Image.file(
              File(path!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _BikePhotoPlaceholder(),
            ),
    ),
  );
}

class _BikePhotoPlaceholder extends StatelessWidget {
  const _BikePhotoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.raisedSurface,
    alignment: Alignment.center,
    child: const Icon(
      Icons.pedal_bike_rounded,
      color: AppColors.accent,
      size: 38,
    ),
  );
}

class _BikeTypePill extends StatelessWidget {
  const _BikeTypePill({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.raisedSurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      BikeType.label(type),
      style: const TextStyle(
        color: AppColors.accent,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EmptyBikes extends StatelessWidget {
  const _EmptyBikes({required this.onAdd, required this.onContinueWithoutBike});

  final VoidCallback onAdd;
  final VoidCallback onContinueWithoutBike;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        const Icon(Icons.pedal_bike_rounded, color: AppColors.accent, size: 36),
        const SizedBox(height: 12),
        const Text(
          'Todavía no agregaste una bici',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar bici'),
          ),
        ),
        TextButton(
          onPressed: onContinueWithoutBike,
          child: const Text('Continuar sin bici'),
        ),
      ],
    ),
  );
}
