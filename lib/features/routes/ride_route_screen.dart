import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong;

import '../../app/app_theme.dart';
import '../../app/google_maps_preferences.dart';
import '../../data/local/app_database.dart';
import '../../data/routes/route_track_segments.dart';
import 'route_map_markers.dart';
import 'route_replay.dart';

enum RideRouteViewMode { follow, replay }

const _osmTileUrl = String.fromEnvironment(
  'OSM_TILE_URL',
  defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
);
const _replayDuration = Duration(seconds: 45);

class RideRouteScreen extends StatefulWidget {
  const RideRouteScreen({
    required this.ride,
    required this.points,
    required this.mode,
    super.key,
  });

  final Ride ride;
  final List<RideTrackPoint> points;
  final RideRouteViewMode mode;

  @override
  State<RideRouteScreen> createState() => _RideRouteScreenState();
}

class _RideRouteScreenState extends State<RideRouteScreen> {
  late final List<List<RideTrackPoint>> _segments;
  late final RouteReplayTimeline _replayTimeline;
  final _osmController = fmap.MapController();
  gmaps.GoogleMapController? _googleController;
  geo.Position? _currentPosition;
  RouteMatchPosition? _routeMatch;
  StreamSubscription<geo.Position>? _locationSubscription;
  Timer? _googleMapStartupWatchdog;
  Timer? _replayTimer;
  RouteMapMarkerIcons? _markerIcons;
  bool _googleMapsEnabled = false;
  bool _googleMapUnavailable = false;
  bool _followCamera = true;
  bool _programmaticCameraMove = false;
  bool _playing = false;
  double _replayProgress = 0;
  int _cameraFollowTicks = 0;
  gmaps.MapType _mapType = gmaps.MapType.normal;
  bool _threeD = false;

  bool get _usingGoogleMaps => _googleMapsEnabled && !_googleMapUnavailable;

  bool get _isReplay => widget.mode == RideRouteViewMode.replay;

  ReplayCoordinate? get _replayPosition =>
      _replayTimeline.positionAt(_replayProgress);

  List<RideTrackPoint> get _allPoints =>
      _segments.expand((segment) => segment).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _segments = splitRouteTrackAtGaps(
      widget.points,
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    ).where((segment) => segment.isNotEmpty).toList(growable: false);
    _replayTimeline = RouteReplayTimeline([
      for (final segment in _segments)
        [
          for (final point in segment)
            (latitude: point.latitude, longitude: point.longitude),
        ],
    ]);
    unawaited(_loadGoogleMapsPreference());
    unawaited(_loadMarkerIcons());
    if (widget.mode == RideRouteViewMode.follow) {
      unawaited(_startLocationTracking());
    }
  }

  @override
  void dispose() {
    _googleMapStartupWatchdog?.cancel();
    _replayTimer?.cancel();
    unawaited(_locationSubscription?.cancel());
    super.dispose();
  }

  Future<void> _loadGoogleMapsPreference() async {
    try {
      final enabled = await shouldUseGoogleMaps();
      if (mounted) setState(() => _googleMapsEnabled = enabled);
    } catch (_) {
      if (mounted) setState(() => _googleMapsEnabled = false);
    }
  }

  Future<void> _loadMarkerIcons() async {
    final icons = await RouteMapMarkerIcons.load();
    if (mounted) setState(() => _markerIcons = icons);
  }

  Future<void> _startLocationTracking() async {
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) {
        _showMessage('Activá la ubicación para seguir la ruta.');
        return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        _showMessage('Permití la ubicación para ver tu posición en la ruta.');
        return;
      }

      final lastKnown = await geo.Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        _updatePosition(lastKnown);
      }
      final current = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) _updatePosition(current);
      _locationSubscription = geo.Geolocator.getPositionStream(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen(_updatePosition, onError: (_) {});
    } catch (_) {
      _showMessage('No se pudo obtener la ubicación actual.');
    }
  }

  void _updatePosition(geo.Position position) {
    if (!mounted) return;
    final routeMatch = _replayTimeline.matchPosition((
      latitude: position.latitude,
      longitude: position.longitude,
    ));
    setState(() {
      _currentPosition = position;
      _routeMatch = routeMatch;
    });
    if (widget.mode == RideRouteViewMode.follow && _followCamera) {
      unawaited(_moveCamera(position.latitude, position.longitude, zoom: 16));
    }
  }

  void _startGoogleMapWatchdog() {
    if (_googleController != null || _googleMapUnavailable) return;
    _googleMapStartupWatchdog ??= Timer(const Duration(seconds: 20), () {
      _googleMapStartupWatchdog = null;
      if (!mounted || _googleController != null) return;
      if (mounted) setState(() => _googleMapUnavailable = true);
    });
  }

  void _onGoogleMapCreated(gmaps.GoogleMapController controller) {
    _googleMapStartupWatchdog?.cancel();
    _googleMapStartupWatchdog = null;
    _googleController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_fitGoogleMapToRoute());
    });
  }

  Future<void> _fitGoogleMapToRoute() async {
    final controller = _googleController;
    final points = _allPoints;
    if (controller == null || points.isEmpty) return;
    if (points.length == 1) {
      await _moveCamera(
        points.first.latitude,
        points.first.longitude,
        zoom: 16,
      );
      return;
    }

    var minLatitude = points
        .map((point) => point.latitude)
        .reduce((first, second) => first < second ? first : second);
    var maxLatitude = points
        .map((point) => point.latitude)
        .reduce((first, second) => first > second ? first : second);
    var minLongitude = points
        .map((point) => point.longitude)
        .reduce((first, second) => first < second ? first : second);
    var maxLongitude = points
        .map((point) => point.longitude)
        .reduce((first, second) => first > second ? first : second);
    const minimumSpan = 0.001;
    if (maxLatitude - minLatitude < minimumSpan) {
      minLatitude -= minimumSpan / 2;
      maxLatitude += minimumSpan / 2;
    }
    if (maxLongitude - minLongitude < minimumSpan) {
      minLongitude -= minimumSpan / 2;
      maxLongitude += minimumSpan / 2;
    }
    try {
      _programmaticCameraMove = true;
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(
          gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLatitude, minLongitude),
            northeast: gmaps.LatLng(maxLatitude, maxLongitude),
          ),
          76,
        ),
      );
    } catch (_) {
      // The route line remains available if the platform map cannot fit bounds.
    } finally {
      _programmaticCameraMove = false;
    }
  }

  Future<void> _moveCamera(
    double latitude,
    double longitude, {
    required double zoom,
  }) async {
    if (_usingGoogleMaps) {
      final controller = _googleController;
      if (controller == null) return;
      _programmaticCameraMove = true;
      try {
        await controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: gmaps.LatLng(latitude, longitude),
              zoom: zoom,
              tilt: _threeD ? 45 : 0,
            ),
          ),
        );
      } catch (_) {
        // Keep the recording available even when a camera animation fails.
      } finally {
        _programmaticCameraMove = false;
      }
    } else {
      _osmController.move(latlong.LatLng(latitude, longitude), zoom);
    }
  }

  void _onCameraMoveStarted() {
    if (_programmaticCameraMove || !_followCamera || !mounted) return;
    setState(() => _followCamera = false);
  }

  Future<void> _recenter() async {
    setState(() => _followCamera = true);
    final position = _isReplay ? _replayPosition : null;
    final latitude =
        _currentPosition?.latitude ??
        position?.latitude ??
        _segments.firstOrNull?.first.latitude;
    final longitude =
        _currentPosition?.longitude ??
        position?.longitude ??
        _segments.firstOrNull?.first.longitude;
    if (latitude == null || longitude == null) return;
    await _moveCamera(
      latitude,
      longitude,
      zoom: _currentPosition == null ? 15 : 16,
    );
  }

  void _toggleReplay() {
    if (!_isReplay) return;
    if (_playing) {
      _replayTimer?.cancel();
      setState(() => _playing = false);
      return;
    }
    if (_replayProgress >= 1) setState(() => _replayProgress = 0);
    setState(() => _playing = true);
    const frameDuration = Duration(milliseconds: 250);
    _replayTimer = Timer.periodic(frameDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextProgress =
          _replayProgress +
          frameDuration.inMilliseconds / _replayDuration.inMilliseconds;
      setState(() {
        _replayProgress = nextProgress >= 1 ? 1 : nextProgress;
        if (_replayProgress >= 1) {
          _playing = false;
          timer.cancel();
        }
      });
      _cameraFollowTicks++;
      if (_followCamera && _cameraFollowTicks % 4 == 0) {
        final replayPosition = _replayPosition;
        if (replayPosition != null) {
          unawaited(
            _moveCamera(
              replayPosition.latitude,
              replayPosition.longitude,
              zoom: 16,
            ),
          );
        }
      }
    });
  }

  Future<void> _toggleThreeD() async {
    setState(() => _threeD = !_threeD);
    final target = _googleController == null
        ? null
        : await _googleController!.getVisibleRegion().then(
            (bounds) => gmaps.LatLng(
              (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
              (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
            ),
          );
    final controller = _googleController;
    if (controller == null) return;
    final routeStart = _routeStart;
    final position =
        target ??
        (routeStart == null
            ? null
            : gmaps.LatLng(routeStart.latitude, routeStart.longitude));
    if (position == null) return;
    try {
      final zoom = await controller.getZoomLevel();
      await controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: position,
            zoom: zoom,
            tilt: _threeD ? 45 : 0,
          ),
        ),
      );
    } catch (_) {
      // Keep the route map usable if the platform camera cannot change pitch.
    }
  }

  latlong.LatLng? get _routeStart {
    final point = _segments.firstOrNull?.first;
    return point == null
        ? null
        : latlong.LatLng(point.latitude, point.longitude);
  }

  fmap.CameraFit? get _osmCameraFit {
    final points = _allPoints;
    if (points.length < 2) return null;
    return fmap.CameraFit.coordinates(
      coordinates: [
        for (final point in points)
          latlong.LatLng(point.latitude, point.longitude),
      ],
      padding: const EdgeInsets.fromLTRB(64, 90, 64, 240),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_usingGoogleMaps) _startGoogleMapWatchdog();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _usingGoogleMaps ? _buildGoogleMap() : _buildOpenStreetMap(),
          _buildTopBar(context),
          Positioned(
            left: 12,
            bottom: 170,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_usingGoogleMaps) ...[
                  const _OsmCopyright(),
                  const SizedBox(width: 6),
                ],
                _RoundMapButton(
                  icon: Icons.info_outline_rounded,
                  tooltip: 'Fuentes del mapa',
                  onTap: () => unawaited(_showMapSources(context)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 170,
            child: _RoundMapButton(
              icon: Icons.my_location_rounded,
              tooltip: 'Centrar ubicación',
              onTap: () => unawaited(_recenter()),
            ),
          ),
          Positioned(left: 12, right: 12, bottom: 18, child: _bottomPanel()),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    final initial = _routeStart ?? const latlong.LatLng(-34.574, -58.418);
    final markerIcons = _markerIcons;
    final markers = <gmaps.Marker>{};
    final firstPoint = _segments.firstOrNull?.first;
    final lastPoint = _segments.lastOrNull?.last;
    if (firstPoint != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('route-start'),
          position: gmaps.LatLng(firstPoint.latitude, firstPoint.longitude),
          icon:
              markerIcons?.start ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueGreen,
              ),
          anchor: const Offset(.5, .5),
          infoWindow: const gmaps.InfoWindow(title: 'Inicio'),
        ),
      );
    }
    if (lastPoint != null && lastPoint != firstPoint) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('route-finish'),
          position: gmaps.LatLng(lastPoint.latitude, lastPoint.longitude),
          icon:
              markerIcons?.finish ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueRed,
              ),
          anchor: const Offset(.25, .92),
          infoWindow: const gmaps.InfoWindow(title: 'Llegada'),
        ),
      );
    }
    final currentPosition = _currentPosition;
    if (currentPosition != null && !_isReplay) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('current-location'),
          position: gmaps.LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
          icon:
              markerIcons?.currentLocation ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueAzure,
              ),
          anchor: const Offset(.5, .5),
          zIndexInt: 4,
        ),
      );
    }
    final replayPosition = _isReplay ? _replayPosition : null;
    if (replayPosition != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('replay-cyclist'),
          position: gmaps.LatLng(
            replayPosition.latitude,
            replayPosition.longitude,
          ),
          icon:
              markerIcons?.replayPosition ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueOrange,
              ),
          anchor: const Offset(.5, .5),
          zIndexInt: 5,
          infoWindow: const gmaps.InfoWindow(title: 'Recorrido'),
        ),
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(initial.latitude, initial.longitude),
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
        for (var index = 0; index < _segments.length; index++)
          if (_segments[index].length > 1) ...[
            gmaps.Polyline(
              polylineId: gmaps.PolylineId('route-border-$index'),
              points: [
                for (final point in _segments[index])
                  gmaps.LatLng(point.latitude, point.longitude),
              ],
              color: const Color(0xFF17352B),
              width: 9,
              zIndex: 1,
            ),
            gmaps.Polyline(
              polylineId: gmaps.PolylineId('route-$index'),
              points: [
                for (final point in _segments[index])
                  gmaps.LatLng(point.latitude, point.longitude),
              ],
              color: AppColors.accent,
              width: 5,
              zIndex: 2,
            ),
          ],
      },
      markers: markers,
      onMapCreated: _onGoogleMapCreated,
      onCameraMoveStarted: _onCameraMoveStarted,
    );
  }

  Widget _buildOpenStreetMap() {
    final initialCenter = _routeStart ?? const latlong.LatLng(-34.574, -58.418);
    final markers = <fmap.Marker>[];
    final firstPoint = _segments.firstOrNull?.first;
    final lastPoint = _segments.lastOrNull?.last;
    if (firstPoint != null) {
      markers.add(
        fmap.Marker(
          point: latlong.LatLng(firstPoint.latitude, firstPoint.longitude),
          width: 24,
          height: 24,
          child: const RouteStartMapMarker(),
        ),
      );
    }
    if (lastPoint != null && lastPoint != firstPoint) {
      markers.add(
        fmap.Marker(
          point: latlong.LatLng(lastPoint.latitude, lastPoint.longitude),
          width: 30,
          height: 38,
          alignment: Alignment.bottomCenter,
          child: const RouteFinishMapMarker(),
        ),
      );
    }
    final currentPosition = _currentPosition;
    if (currentPosition != null && !_isReplay) {
      markers.add(
        fmap.Marker(
          point: latlong.LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
          width: 22,
          height: 22,
          child: const RouteCurrentLocationMapMarker(),
        ),
      );
    }
    final replayPosition = _isReplay ? _replayPosition : null;
    if (replayPosition != null) {
      markers.add(
        fmap.Marker(
          point: latlong.LatLng(
            replayPosition.latitude,
            replayPosition.longitude,
          ),
          width: 22,
          height: 22,
          child: const RouteReplayMapMarker(),
        ),
      );
    }

    return fmap.FlutterMap(
      mapController: _osmController,
      options: fmap.MapOptions(
        initialCenter: initialCenter,
        initialZoom: 14,
        initialCameraFit: _osmCameraFit,
        minZoom: 3,
        maxZoom: 19,
        backgroundColor: const Color(0xFFE9EFEA),
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && _followCamera && mounted) {
            setState(() => _followCamera = false);
          }
        },
      ),
      children: [
        fmap.TileLayer(
          urlTemplate: _osmTileUrl,
          userAgentPackageName: 'com.spoke.spoke_app',
          maxZoom: 19,
          maxNativeZoom: 19,
        ),
        fmap.PolylineLayer(
          polylines: [
            for (final segment in _segments)
              if (segment.length > 1)
                fmap.Polyline(
                  points: [
                    for (final point in segment)
                      latlong.LatLng(point.latitude, point.longitude),
                  ],
                  color: AppColors.accent,
                  strokeWidth: 5,
                  borderColor: const Color(0xFF17352B),
                  borderStrokeWidth: 2,
                ),
          ],
        ),
        fmap.MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _RoundMapButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.91),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isReplay ? 'Reproducción del recorrido' : 'Seguir ruta',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.ride.title?.isNotEmpty == true
                          ? widget.ride.title!
                          : _formatRideDate(widget.ride.startedAt.toLocal()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_usingGoogleMaps) ...[
              const SizedBox(width: 8),
              PopupMenuButton<gmaps.MapType>(
                tooltip: 'Estilo del mapa',
                onSelected: (type) => setState(() => _mapType = type),
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
                child: const _RoundMapButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Estilo del mapa',
                ),
              ),
              const SizedBox(width: 7),
              _RoundMapButton(
                icon: Icons.view_in_ar_rounded,
                tooltip: 'Vista 3D',
                selected: _threeD,
                onTap: () => unawaited(_toggleThreeD()),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _bottomPanel() => Container(
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .96),
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: AppColors.divider),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 18,
          offset: Offset(0, 5),
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    child: _isReplay ? _replayControls() : _followInformation(),
  );

  Widget _followInformation() {
    final position = _currentPosition;
    final routeMatch = _routeMatch;
    final accuracyMeters = position?.accuracy ?? 0;
    final deviationLimit = accuracyMeters > 50 ? accuracyMeters * 1.5 : 80.0;
    final offRoute =
        routeMatch != null &&
        accuracyMeters <= 50 &&
        routeMatch.distanceFromRouteMeters > deviationLimit;
    final lowAccuracy = position != null && accuracyMeters > 50;
    final status = position == null
        ? 'Buscando GPS…'
        : lowAccuracy
        ? 'GPS impreciso'
        : offRoute
        ? 'Fuera de la ruta'
        : 'Sobre la ruta';
    final statusColor = offRoute || lowAccuracy
        ? const Color(0xFFFFA36B)
        : position == null
        ? AppColors.secondaryText
        : AppColors.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              offRoute
                  ? Icons.wrong_location_rounded
                  : position == null
                  ? Icons.gps_not_fixed_rounded
                  : Icons.gps_fixed_rounded,
              size: 17,
              color: statusColor,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_formatDistance(widget.ride.distanceMeters)} km',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: routeMatch?.progress ?? 0,
            minHeight: 4,
            backgroundColor: AppColors.raisedSurface,
            valueColor: AlwaysStoppedAnimation(statusColor),
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _RouteMetric(
                label: 'AVANCE ESTIMADO',
                value: routeMatch == null
                    ? '—'
                    : '${(routeMatch.progress * 100).round()}%',
              ),
            ),
            Expanded(
              child: _RouteMetric(
                label: 'DISTANCIA A LA RUTA',
                value: routeMatch == null
                    ? '—'
                    : _formatMeters(routeMatch.distanceFromRouteMeters),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _replayControls() {
    final elapsed = Duration(
      milliseconds: (_replayProgress * _replayDuration.inMilliseconds).round(),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route_rounded, color: AppColors.accent, size: 17),
            const SizedBox(width: 7),
            const Expanded(
              child: Text(
                'Recorrido grabado',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_formatDistance(widget.ride.distanceMeters)} km',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: _replayProgress,
          onChanged: (value) => setState(() => _replayProgress = value),
          activeColor: AppColors.accent,
          inactiveColor: AppColors.raisedSurface,
        ),
        Row(
          children: [
            Text(
              _formatDuration(elapsed.inSeconds),
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            IconButton.filled(
              onPressed: _toggleReplay,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                minimumSize: const Size(44, 44),
              ),
              icon: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 25,
              ),
            ),
            const Spacer(),
            Text(
              _formatDuration(_replayDuration.inSeconds),
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> _showMapSources(
    BuildContext context,
  ) => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fuentes de datos del mapa',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _MapSourceRow(
            title: _usingGoogleMaps ? 'Google Maps' : 'OpenStreetMap',
            detail: _usingGoogleMaps
                ? 'Mapa principal para seguir y reproducir recorridos.'
                : 'Mapa de respaldo. © OpenStreetMap contributors.',
          ),
          if (_usingGoogleMaps) ...[
            const SizedBox(height: 7),
            const _MapSourceRow(
              title: 'OpenStreetMap',
              detail:
                  'Proveedor de respaldo si Google Maps no está disponible.',
            ),
          ],
        ],
      ),
    ),
  );
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.background.withValues(alpha: .92),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: SizedBox.square(
          dimension: 42,
          child: Icon(
            icon,
            color: selected ? AppColors.accent : AppColors.primaryText,
            size: 20,
          ),
        ),
      ),
    ),
  );
}

class _OsmCopyright extends StatelessWidget {
  const _OsmCopyright();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      '© OpenStreetMap',
      style: TextStyle(
        color: AppColors.primaryText,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _MapSourceRow extends StatelessWidget {
  const _MapSourceRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
        ),
      ],
    ),
  );
}

String _formatRideDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

String _formatDistance(int meters) => (meters / 1000).toStringAsFixed(1);

String _formatMeters(double meters) => meters < 1000
    ? '${meters.round()} m'
    : '${(meters / 1000).toStringAsFixed(1)} km';
