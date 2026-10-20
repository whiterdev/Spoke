import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';
import '../../data/routes/route_track_segments.dart';

enum RideRecordingPhase { ready, recording, paused, finished }

class RideTrackSample {
  const RideTrackSample({
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.altitudeMeters,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });

  factory RideTrackSample.fromDatabase(RideTrackPoint point) => RideTrackSample(
    sequence: point.sequence,
    latitude: point.latitude,
    longitude: point.longitude,
    recordedAt: point.recordedAt,
    altitudeMeters: point.altitudeMeters,
    accuracyMeters: point.horizontalAccuracyMeters,
    speedMetersPerSecond: point.speedMetersPerSecond,
  );

  final int sequence;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? altitudeMeters;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
}

class RideRecorderState {
  const RideRecorderState({
    this.phase = RideRecordingPhase.ready,
    this.rideId,
    this.bikeId,
    this.startedAt,
    this.pausedAt,
    this.elapsedSeconds = 0,
    this.distanceMeters = 0,
    this.elevationGainMeters = 0,
    this.maxSpeedMetersPerSecond = 0,
    this.trackPoints = const [],
    this.errorMessage,
    this.backgroundLocationLimited = false,
  });

  final RideRecordingPhase phase;
  final int? rideId;
  final int? bikeId;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final int elapsedSeconds;
  final int distanceMeters;
  final double elevationGainMeters;
  final double maxSpeedMetersPerSecond;
  final List<RideTrackSample> trackPoints;
  final String? errorMessage;
  final bool backgroundLocationLimited;

  double get currentSpeedMetersPerSecond =>
      phase != RideRecordingPhase.recording || trackPoints.isEmpty
      ? 0
      : trackPoints.last.speedMetersPerSecond ?? 0;

  double get averageSpeedMetersPerSecond =>
      elapsedSeconds <= 0 ? 0 : distanceMeters / elapsedSeconds;

  RideRecorderState copyWith({
    RideRecordingPhase? phase,
    int? rideId,
    bool clearRideId = false,
    int? bikeId,
    bool clearBikeId = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    int? elapsedSeconds,
    int? distanceMeters,
    double? elevationGainMeters,
    double? maxSpeedMetersPerSecond,
    List<RideTrackSample>? trackPoints,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? backgroundLocationLimited,
  }) => RideRecorderState(
    phase: phase ?? this.phase,
    rideId: clearRideId ? null : rideId ?? this.rideId,
    bikeId: clearBikeId ? null : bikeId ?? this.bikeId,
    startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
    pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
    maxSpeedMetersPerSecond:
        maxSpeedMetersPerSecond ?? this.maxSpeedMetersPerSecond,
    trackPoints: trackPoints ?? this.trackPoints,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    backgroundLocationLimited:
        backgroundLocationLimited ?? this.backgroundLocationLimited,
  );
}

final rideRecorderProvider =
    NotifierProvider<RideRecorderController, RideRecorderState>(
      RideRecorderController.new,
    );

class RideRecorderController extends Notifier<RideRecorderState> {
  late AppDatabase _database;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  Future<void> _pendingWrites = Future<void>.value();
  bool _initialized = false;
  int? _activeRideId;
  int _nextSequence = 0;
  int _elapsedBaseSeconds = 0;
  DateTime? _activeSegmentStartedAt;
  RideTrackSample? _lastPoint;

  @override
  RideRecorderState build() {
    _database = ref.watch(appDatabaseProvider);
    ref.onDispose(() {
      _timer?.cancel();
      unawaited(_positionSubscription?.cancel());
    });
    return const RideRecorderState();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final ride = await _database.activeRide();
    if (ride == null) return;

    final now = DateTime.now().toUtc();
    final storedPoints = await _database.getRideTrackPoints(ride.id);
    final points = storedPoints
        .map(RideTrackSample.fromDatabase)
        .toList(growable: false);
    _activeRideId = ride.id;
    _nextSequence = points.isEmpty ? 0 : points.last.sequence + 1;
    // A restored ride is paused, so the next GPS fix must not bridge the
    // gap between the previous ride session and the resumed session.
    _lastPoint = null;

    var distanceMeters = 0.0;
    var elevationGainMeters = 0.0;
    var maxSpeedMetersPerSecond = 0.0;
    for (final segment in splitRouteTrackAtGaps(
      points,
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    )) {
      for (var index = 0; index < segment.length; index++) {
        final point = segment[index];
        final speed = point.speedMetersPerSecond;
        if (speed != null &&
            speed.isFinite &&
            speed > maxSpeedMetersPerSecond) {
          maxSpeedMetersPerSecond = speed;
        }
        if (index == 0) continue;

        final previous = segment[index - 1];
        distanceMeters += Geolocator.distanceBetween(
          previous.latitude,
          previous.longitude,
          point.latitude,
          point.longitude,
        );
        final previousAltitude = previous.altitudeMeters;
        final altitude = point.altitudeMeters;
        if (previousAltitude != null && altitude != null) {
          final gain = altitude - previousAltitude;
          if (gain > 2 && gain < 50) elevationGainMeters += gain;
        }
      }
    }

    final elapsedEnd = ride.status == RideStatus.paused
        ? ride.pausedAt ?? points.lastOrNull?.recordedAt ?? ride.startedAt
        : points.lastOrNull?.recordedAt ?? ride.startedAt;
    final elapsed =
        elapsedEnd.difference(ride.startedAt).inSeconds -
        ride.pausedDurationSeconds;
    _elapsedBaseSeconds = elapsed > 0 ? elapsed : 0;

    final restoredPauseAt = ride.status == RideStatus.paused
        ? ride.pausedAt ?? now
        : now;
    if (ride.status == RideStatus.recording) {
      await _database.pauseRide(rideId: ride.id, pausedAt: restoredPauseAt);
    }

    state = RideRecorderState(
      phase: RideRecordingPhase.paused,
      rideId: ride.id,
      bikeId: ride.bikeId,
      startedAt: ride.startedAt,
      pausedAt: restoredPauseAt,
      elapsedSeconds: _elapsedBaseSeconds,
      distanceMeters: distanceMeters.round(),
      elevationGainMeters: elevationGainMeters,
      maxSpeedMetersPerSecond: maxSpeedMetersPerSecond,
      trackPoints: points,
    );
  }

  Future<void> start({int? bikeId}) async {
    if (state.phase == RideRecordingPhase.finished) reset();
    if (state.phase != RideRecordingPhase.ready) return;

    state = state.copyWith(
      phase: RideRecordingPhase.ready,
      clearErrorMessage: true,
      bikeId: bikeId,
      clearBikeId: bikeId == null,
    );

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Activá la ubicación del teléfono para grabar.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Spoke necesita permiso de ubicación para grabar.');
      }

      try {
        await requestNotificationPermission();
      } catch (_) {
        // Notification access is optional for a foreground location service.
      }

      final startedAt = DateTime.now().toUtc();
      final rideId = await _database.startRide(
        RidesCompanion(
          startedAt: Value(startedAt),
          bikeId: Value(bikeId),
          status: const Value(RideStatus.recording),
        ),
      );
      _activeRideId = rideId;
      _nextSequence = 0;
      _elapsedBaseSeconds = 0;
      _activeSegmentStartedAt = startedAt;
      _lastPoint = null;
      _pendingWrites = Future<void>.value();
      state = RideRecorderState(
        phase: RideRecordingPhase.recording,
        rideId: rideId,
        bikeId: bikeId,
        startedAt: startedAt,
        backgroundLocationLimited: permission != LocationPermission.always,
      );
      _startPositionStream();
      _startTimer();
    } catch (error, stackTrace) {
      developer.log(
        'Could not start GPS ride recording.',
        name: 'spoke.ride_recorder',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        phase: RideRecordingPhase.ready,
        errorMessage: error is StateError
            ? error.message
            : kDebugMode
            ? 'No se pudo iniciar la grabación GPS: $error'
            : 'No se pudo iniciar la grabación GPS.',
      );
    }
  }

  Future<void> pause() async {
    final rideId = _activeRideId;
    if (rideId == null || state.phase != RideRecordingPhase.recording) return;

    final pausedAt = DateTime.now().toUtc();
    _elapsedBaseSeconds = _elapsedAt(pausedAt);
    _activeSegmentStartedAt = null;
    _lastPoint = null;
    _timer?.cancel();
    _timer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _pendingWrites;
    await _database.pauseRide(rideId: rideId, pausedAt: pausedAt);
    state = state.copyWith(
      phase: RideRecordingPhase.paused,
      pausedAt: pausedAt,
      elapsedSeconds: _elapsedBaseSeconds,
      clearErrorMessage: true,
    );
  }

  Future<void> resume() async {
    final rideId = _activeRideId;
    if (rideId == null || state.phase != RideRecordingPhase.paused) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Activá la ubicación del teléfono para continuar.');
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Spoke necesita permiso de ubicación para continuar.');
      }

      final resumedAt = DateTime.now().toUtc();
      await _database.resumeRide(rideId: rideId, resumedAt: resumedAt);
      _activeSegmentStartedAt = resumedAt;
      state = state.copyWith(
        phase: RideRecordingPhase.recording,
        backgroundLocationLimited: permission != LocationPermission.always,
        clearPausedAt: true,
        clearErrorMessage: true,
      );
      _startPositionStream();
      _startTimer();
    } catch (error) {
      state = state.copyWith(
        errorMessage: error is StateError
            ? error.message
            : 'No se pudo reanudar la grabación GPS.',
      );
    }
  }

  Future<void> finish() async {
    final rideId = _activeRideId;
    final startedAt = state.startedAt;
    if (rideId == null || startedAt == null) return;
    if (state.trackPoints.length < 2) {
      state = state.copyWith(
        errorMessage: 'Esperá a tener al menos dos puntos GPS para guardar.',
      );
      return;
    }

    _timer?.cancel();
    _timer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _pendingWrites;
    final finishedAt = DateTime.now().toUtc();
    final elapsedSeconds = state.phase == RideRecordingPhase.paused
        ? _elapsedBaseSeconds
        : _elapsedAt(finishedAt);
    final durationSeconds = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    final averageSpeed = durationSeconds == 0
        ? 0.0
        : state.distanceMeters / durationSeconds;

    await _database.completeRide(
      rideId: rideId,
      finishedAt: finishedAt,
      durationSeconds: durationSeconds,
      distanceMeters: state.distanceMeters,
      elevationGainMeters: state.elevationGainMeters,
      averageSpeedMetersPerSecond: averageSpeed,
      maxSpeedMetersPerSecond: state.maxSpeedMetersPerSecond,
    );
    try {
      await _database.suggestRouteMatchesForRide(rideId);
    } catch (_) {
      // A failed match must not undo a successfully saved ride.
    }
    state = state.copyWith(
      phase: RideRecordingPhase.finished,
      elapsedSeconds: durationSeconds,
      clearPausedAt: true,
      clearErrorMessage: true,
    );
    _activeRideId = null;
    _activeSegmentStartedAt = null;
  }

  Future<void> discard() async {
    final rideId = _activeRideId;
    _timer?.cancel();
    _timer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _pendingWrites;
    if (rideId != null) await _database.discardRide(rideId);
    _activeRideId = null;
    _activeSegmentStartedAt = null;
    _elapsedBaseSeconds = 0;
    _lastPoint = null;
    state = const RideRecorderState();
    _initialized = true;
  }

  void reset() {
    _activeRideId = null;
    _nextSequence = 0;
    _elapsedBaseSeconds = 0;
    _activeSegmentStartedAt = null;
    _lastPoint = null;
    state = const RideRecorderState();
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<void> refreshBackgroundPermission() async {
    if (state.phase != RideRecordingPhase.recording &&
        state.phase != RideRecordingPhase.paused) {
      return;
    }
    final permission = await Geolocator.checkPermission();
    state = state.copyWith(
      backgroundLocationLimited: permission != LocationPermission.always,
    );
  }

  Future<bool> requestBackgroundPermission() async {
    final currentPermission = await Geolocator.checkPermission();
    if (currentPermission == LocationPermission.always) {
      state = state.copyWith(backgroundLocationLimited: false);
      return true;
    }
    if (currentPermission == LocationPermission.denied ||
        currentPermission == LocationPermission.deniedForever) {
      state = state.copyWith(backgroundLocationLimited: true);
      return false;
    }

    final result = await Permission.locationAlways.request();
    final updatedPermission = await Geolocator.checkPermission();
    final granted =
        result.isGranted || updatedPermission == LocationPermission.always;
    state = state.copyWith(backgroundLocationLimited: !granted);
    return granted;
  }

  Future<bool> requestNotificationPermission() async {
    final permission = await Permission.notification.status;
    if (permission.isGranted) return true;
    if (permission.isDenied) {
      return (await Permission.notification.request()).isGranted;
    }
    return false;
  }

  Future<bool> openApplicationSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  void _startPositionStream() {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
      intervalDuration: Duration(seconds: 3),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: 'Spoke está grabando tu salida',
        notificationText: 'Tu recorrido sigue en marcha.',
        notificationChannelName: 'Grabación de ciclismo',
        enableWakeLock: true,
        setOngoing: true,
      ),
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          _handlePosition,
          onError: (Object error, StackTrace stackTrace) {
            state = state.copyWith(
              errorMessage: 'Se perdió la señal GPS. La salida sigue abierta.',
            );
          },
        );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedSeconds: _elapsedAt(DateTime.now().toUtc()),
      );
    });
  }

  int _elapsedAt(DateTime now) {
    final segmentStart = _activeSegmentStartedAt;
    if (segmentStart == null) return _elapsedBaseSeconds;
    final segmentSeconds = now.difference(segmentStart).inSeconds;
    return _elapsedBaseSeconds + (segmentSeconds > 0 ? segmentSeconds : 0);
  }

  void _handlePosition(Position position) {
    if (_activeRideId == null || state.phase != RideRecordingPhase.recording) {
      return;
    }
    if (!position.latitude.isFinite || !position.longitude.isFinite) return;
    if (position.accuracy.isFinite && position.accuracy > 60) return;

    final recordedAt = position.timestamp.toUtc();
    final lastPoint = _lastPoint;
    if (lastPoint != null && !recordedAt.isAfter(lastPoint.recordedAt)) return;
    final previous =
        lastPoint != null && !isRouteTrackGap(lastPoint.recordedAt, recordedAt)
        ? lastPoint
        : null;
    final startsNewSegment = previous == null && state.trackPoints.isNotEmpty;

    final segmentDistance = previous == null
        ? 0.0
        : Geolocator.distanceBetween(
            previous.latitude,
            previous.longitude,
            position.latitude,
            position.longitude,
          );
    if (previous != null && segmentDistance < 2) return;

    final rawSpeed = position.speed;
    final speed = rawSpeed.isFinite && rawSpeed >= 0 ? rawSpeed : null;
    if (startsNewSegment) _nextSequence++;
    final point = RideTrackSample(
      sequence: _nextSequence++,
      latitude: position.latitude,
      longitude: position.longitude,
      recordedAt: recordedAt,
      altitudeMeters: position.altitude.isFinite ? position.altitude : null,
      accuracyMeters: position.accuracy.isFinite ? position.accuracy : null,
      speedMetersPerSecond: speed,
    );
    _lastPoint = point;

    var elevationGain = state.elevationGainMeters;
    if (previous?.altitudeMeters != null && point.altitudeMeters != null) {
      final delta = point.altitudeMeters! - previous!.altitudeMeters!;
      if (delta > 2 && delta < 50) elevationGain += delta;
    }
    final maxSpeed = speed != null && speed > state.maxSpeedMetersPerSecond
        ? speed
        : state.maxSpeedMetersPerSecond;
    final points = [...state.trackPoints, point];
    state = state.copyWith(
      trackPoints: points,
      distanceMeters: state.distanceMeters + segmentDistance.round(),
      elevationGainMeters: elevationGain,
      maxSpeedMetersPerSecond: maxSpeed,
      clearErrorMessage: true,
    );

    final rideId = _activeRideId!;
    _pendingWrites = _pendingWrites
        .then((_) => _database.appendTrackPoints(rideId, [_toCompanion(point)]))
        .catchError((Object error, StackTrace stackTrace) {
          state = state.copyWith(
            errorMessage: 'No se pudo guardar un punto GPS en SQLite.',
          );
        });
  }

  RideTrackPointsCompanion _toCompanion(RideTrackSample point) =>
      RideTrackPointsCompanion(
        sequence: Value(point.sequence),
        latitude: Value(point.latitude),
        longitude: Value(point.longitude),
        altitudeMeters: Value(point.altitudeMeters),
        horizontalAccuracyMeters: Value(point.accuracyMeters),
        speedMetersPerSecond: Value(point.speedMetersPerSecond),
        recordedAt: Value(point.recordedAt),
      );
}
