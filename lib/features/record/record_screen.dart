import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../data/local/app_database.dart';
import '../bikes/bikes_providers.dart';
import 'record_map.dart';
import 'ride_recorder.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({this.initialBikeId, super.key});

  final int? initialBikeId;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen>
    with WidgetsBindingObserver {
  int? _selectedBikeId;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _selectedBikeId = widget.initialBikeId;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(rideRecorderProvider.notifier).initialize());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(rideRecorderProvider.notifier).refreshBackgroundPermission(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(rideRecorderProvider);
    final controller = ref.read(rideRecorderProvider.notifier);
    final bikes = ref.watch(bikesProvider);
    final selectedBikeId = recorder.bikeId ?? _selectedBikeId;
    final selectedBike = bikes.maybeWhen(
      data: (items) {
        for (final bike in items) {
          if (bike.id == selectedBikeId) return bike;
        }
        return null;
      },
      orElse: () => null,
    );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RecordMap(key: const ValueKey('openstreetmap-record-map')),
                if (recorder.phase == RideRecordingPhase.recording &&
                    recorder.backgroundLocationLimited)
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 16,
                    child: Material(
                      color: AppColors.background.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => unawaited(
                          _configureBackgroundPermission(controller),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Habilitá ubicación en segundo plano para seguir grabando con la pantalla apagada.',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 10,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.open_in_new_rounded,
                                color: AppColors.accent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _RideControlPanel(
            state: recorder,
            selectedBike: selectedBike,
            actionInProgress: _actionInProgress,
            onStart: () =>
                _runAction(() => controller.start(bikeId: _selectedBikeId)),
            onPause: () => _runAction(controller.pause),
            onResume: () => _runAction(controller.resume),
            onFinish: () => _runAction(controller.finish),
            onDiscard: () => _confirmDiscard(controller),
            onNewRide: controller.reset,
            onClearError: controller.clearError,
            onOpenSettings: () {
              controller.clearError();
              unawaited(controller.openApplicationSettings());
            },
            onOpenLocationSettings: () {
              controller.clearError();
              unawaited(controller.openLocationSettings());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo completar la acción.')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _configureBackgroundPermission(
    RideRecorderController controller,
  ) async {
    try {
      // Notifications improve the recording experience, but they are optional.
      await controller.requestNotificationPermission();
      final granted = await controller.requestBackgroundPermission();
      if (!granted && mounted) {
        await controller.openApplicationSettings();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron actualizar los permisos.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmDiscard(RideRecorderController controller) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Descartar salida',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: const Text(
          'Se borrarán los puntos GPS de esta salida de este dispositivo.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir grabando'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      await _runAction(controller.discard);
    }
  }
}

class _RideControlPanel extends StatelessWidget {
  const _RideControlPanel({
    required this.state,
    required this.selectedBike,
    required this.actionInProgress,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onDiscard,
    required this.onNewRide,
    required this.onClearError,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final RideRecorderState state;
  final Bike? selectedBike;
  final bool actionInProgress;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onDiscard;
  final VoidCallback onNewRide;
  final VoidCallback onClearError;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final isFinished = state.phase == RideRecordingPhase.finished;
    final needsPermissionSettings =
        state.errorMessage?.contains('permiso de ubicación') ?? false;
    final needsDeviceLocationSettings =
        state.errorMessage?.contains('ubicación del teléfono') ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isFinished ? 'SALIDA GUARDADA' : 'RESUMEN EN VIVO',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
              ),
              _StatePill(phase: state.phase),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedBike != null) ...[
            _SelectedBikeSummary(bike: selectedBike!),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _RideMetric(
                  label: 'Distancia',
                  value: _formatDistance(state.distanceMeters),
                  unit: 'km',
                  icon: Icons.route_rounded,
                ),
              ),
              const _RideMetricDivider(),
              Expanded(
                child: _RideMetric(
                  label: 'Tiempo',
                  value: _formatDuration(state.elapsedSeconds),
                  unit: '',
                  icon: Icons.timer_outlined,
                ),
              ),
              const _RideMetricDivider(),
              Expanded(
                child: _RideMetric(
                  label: 'Velocidad',
                  value: (state.currentSpeedMetersPerSecond * 3.6)
                      .toStringAsFixed(0),
                  unit: 'km/h',
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.terrain_rounded,
                color: AppColors.secondaryText,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                'Desnivel + ${state.elevationGainMeters.toStringAsFixed(0)} m',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                'Prom. ${(state.averageSpeedMetersPerSecond * 3.6).toStringAsFixed(1)} km/h',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 9),
            Material(
              color: AppColors.raisedSurface,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.accent,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (needsPermissionSettings || needsDeviceLocationSettings)
                      TextButton(
                        onPressed: needsDeviceLocationSettings
                            ? onOpenLocationSettings
                            : onOpenSettings,
                        child: Text(
                          needsDeviceLocationSettings ? 'Activar' : 'Ajustes',
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'Cerrar aviso',
                        onPressed: onClearError,
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: AppColors.secondaryText,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _RideActions(
            phase: state.phase,
            busy: actionInProgress,
            onStart: onStart,
            onPause: onPause,
            onResume: onResume,
            onFinish: onFinish,
            onDiscard: onDiscard,
            onNewRide: onNewRide,
          ),
        ],
      ),
    );
  }
}

class _SelectedBikeSummary extends ConsumerWidget {
  const _SelectedBikeSummary({required this.bike});

  final Bike bike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odometer = ref.watch(bikeOdometerProvider(bike.id));
    final forecasts = ref.watch(bikeMaintenanceForecastsProvider(bike.id));
    final model = [
      bike.brand,
      bike.model,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final displayName = bike.nickname?.trim().isNotEmpty == true
        ? bike.nickname!.trim()
        : model;
    final kilometerText = odometer.asData?.value == null
        ? null
        : '${(odometer.asData!.value / 1000).toStringAsFixed(0)} km';
    final maintenanceItems = forecasts.asData?.value;
    String? maintenanceText;
    var maintenanceIsDue = false;
    if (maintenanceItems != null && maintenanceItems.isNotEmpty) {
      final next = [...maintenanceItems]
        ..sort((a, b) => a.remainingMeters.compareTo(b.remainingMeters));
      final forecast = next.first;
      maintenanceIsDue = forecast.isDue;
      maintenanceText = forecast.isDue
          ? '${forecast.event.serviceName} pendiente'
          : '${forecast.event.serviceName} en ${(forecast.remainingMeters / 1000).ceil()} km';
    }

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 56,
              height: 56,
              child: bike.photoPath?.isNotEmpty == true
                  ? Image.file(
                      File(bike.photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _BikePhotoFallback(),
                    )
                  : _BikePhotoFallback(),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName.isEmpty ? 'Mi bicicleta' : displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (bike.nickname?.trim().isNotEmpty == true &&
                    model.isNotEmpty)
                  Text(
                    model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  [BikeType.label(bike.type), ?kilometerText].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
                if (maintenanceText != null)
                  Text(
                    maintenanceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: maintenanceIsDue
                          ? AppColors.accent
                          : AppColors.secondaryText,
                      fontSize: 9,
                      fontWeight: maintenanceIsDue
                          ? FontWeight.w700
                          : FontWeight.w400,
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

class _BikePhotoFallback extends StatelessWidget {
  const _BikePhotoFallback();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.raisedSurface,
    alignment: Alignment.center,
    child: const Icon(
      Icons.pedal_bike_rounded,
      color: AppColors.accent,
      size: 27,
    ),
  );
}

class _RideMetric extends StatelessWidget {
  const _RideMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    ],
  );
}

class _RideMetricDivider extends StatelessWidget {
  const _RideMetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 37,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: AppColors.divider,
  );
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.phase});

  final RideRecordingPhase phase;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      RideRecordingPhase.ready => 'LISTO',
      RideRecordingPhase.recording => 'EN VIVO',
      RideRecordingPhase.paused => 'PAUSADA',
      RideRecordingPhase.finished => 'GUARDADA',
    };
    final icon = switch (phase) {
      RideRecordingPhase.ready => Icons.circle_outlined,
      RideRecordingPhase.recording => Icons.circle,
      RideRecordingPhase.paused => Icons.pause_circle_filled_rounded,
      RideRecordingPhase.finished => Icons.check_circle_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RideActions extends StatelessWidget {
  const _RideActions({
    required this.phase,
    required this.busy,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onDiscard,
    required this.onNewRide,
  });

  final RideRecordingPhase phase;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onDiscard;
  final VoidCallback onNewRide;

  @override
  Widget build(BuildContext context) {
    if (phase == RideRecordingPhase.ready) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: busy ? null : onStart,
          icon: busy
              ? const SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: const Text('Iniciar salida'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    if (phase == RideRecordingPhase.finished) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: busy ? null : onNewRide,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nueva salida'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    return Row(
      children: [
        IconButton.outlined(
          onPressed: busy ? null : onDiscard,
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.secondaryText,
          tooltip: 'Descartar salida',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: busy
                ? null
                : phase == RideRecordingPhase.paused
                ? onResume
                : onPause,
            icon: Icon(
              phase == RideRecordingPhase.paused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
            ),
            label: Text(
              phase == RideRecordingPhase.paused ? 'Reanudar' : 'Pausar',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryText,
              side: const BorderSide(color: AppColors.divider),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: busy ? null : onFinish,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Guardar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDistance(int meters) => (meters / 1000).toStringAsFixed(2);

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
