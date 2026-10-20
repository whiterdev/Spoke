import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

import '../../app/app_theme.dart';
import '../../app/map_provider_selection.dart';
import '../../app/google_maps_preferences.dart';
import '../../data/routes/route_track_segments.dart';
import '../routes/route_map_markers.dart';
import 'ride_recorder.dart';

const _osmTileUrl = String.fromEnvironment(
  'OSM_TILE_URL',
  defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
);
const _osmUserAgent = 'Spoke/1.0.0 (com.spoke.spoke_app)';

class RecordMap extends ConsumerStatefulWidget {
  const RecordMap({super.key});

  @override
  ConsumerState<RecordMap> createState() => _RecordMapState();
}

class _RecordMapState extends ConsumerState<RecordMap>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  gmaps.GoogleMapController? _googleMapController;
  gmaps.CameraPosition? _googleCameraPosition;
  LatLng? _currentPosition;
  int? _lastFollowedSequence;
  bool _followUser = true;
  bool _mapReady = false;
  bool _googleMapsEnabled = false;
  bool _googleMapUnavailable = false;
  bool _googleMapMoveIsProgrammatic = false;
  bool _googleThreeD = false;
  gmaps.MapType _googleMapType = gmaps.MapType.normal;
  RouteMapMarkerIcons? _markerIcons;
  Timer? _googleMapStartupWatchdog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGoogleMapsPreference();
    unawaited(_loadMarkerIcons());
  }

  Future<void> _loadMarkerIcons() async {
    final icons = await RouteMapMarkerIcons.load();
    if (mounted) setState(() => _markerIcons = icons);
  }

  Future<void> _loadGoogleMapsPreference() async {
    try {
      final enabled = await shouldUseGoogleMaps();
      if (mounted) setState(() => _googleMapsEnabled = enabled);
    } catch (_) {
      if (mounted) setState(() => _googleMapsEnabled = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationAfterSettings());
    }
  }

  @override
  void dispose() {
    _googleMapStartupWatchdog?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshLocationAfterSettings() async {
    final permission = await geo.Geolocator.checkPermission();
    if (!mounted ||
        permission == geo.LocationPermission.denied ||
        permission == geo.LocationPermission.deniedForever) {
      return;
    }

    await _centerOnCurrentLocation(fallbackToRoute: true);
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(rideRecorderProvider);
    ref.listen(rideRecorderProvider, (previous, next) {
      if (previous?.trackPoints.length != next.trackPoints.length &&
          _followUser &&
          next.trackPoints.isNotEmpty) {
        _followLatestPoint(next.trackPoints.last);
      }
    });

    final latestTrackPoint = recorder.trackPoints.isEmpty
        ? null
        : recorder.trackPoints.last;
    final currentLocation = latestTrackPoint == null
        ? _currentPosition
        : LatLng(latestTrackPoint.latitude, latestTrackPoint.longitude);
    final routeSegments = splitRouteTrackAtGaps(
      recorder.trackPoints,
      sequence: (point) => point.sequence,
      recordedAt: (point) => point.recordedAt,
    );
    final routeStart = routeSegments.firstOrNull?.first;
    final routeFinish = routeSegments.lastOrNull?.last;
    final showFinish =
        recorder.phase == RideRecordingPhase.finished &&
        routeStart != null &&
        routeFinish != null &&
        (routeStart.latitude != routeFinish.latitude ||
            routeStart.longitude != routeFinish.longitude);
    final usingGoogleMaps =
        liveMapProvider(
          googleMapsEnabled: _googleMapsEnabled && !_googleMapUnavailable,
        ) ==
        MapProvider.googleMaps;
    if (usingGoogleMaps) _startGoogleMapStartupWatchdog();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (usingGoogleMaps)
          _buildGoogleMap(
            currentLocation,
            routeSegments,
            showFinish: showFinish,
          )
        else
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-34.574, -58.418),
              initialZoom: 14,
              minZoom: 3,
              maxZoom: 19,
              backgroundColor: const Color(0xFFE9EFEA),
              onMapReady: _onMapReady,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && _followUser && mounted) {
                  setState(() => _followUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _osmTileUrl,
                userAgentPackageName: 'com.spoke.spoke_app',
                tileProvider: NetworkTileProvider(
                  headers: {'User-Agent': _osmUserAgent},
                  cachingProvider:
                      BuiltInMapCachingProvider.getOrCreateInstance(),
                ),
                maxZoom: 19,
                maxNativeZoom: 19,
              ),
              if (routeSegments.any((segment) => segment.length >= 2))
                PolylineLayer(
                  polylines: [
                    for (final segment in routeSegments)
                      if (segment.length >= 2)
                        Polyline(
                          points: [
                            for (final point in segment)
                              LatLng(point.latitude, point.longitude),
                          ],
                          color: AppColors.accent,
                          strokeWidth: 5,
                          borderColor: const Color(0xFF17352B),
                          borderStrokeWidth: 1.5,
                        ),
                  ],
                ),
              if (routeStart != null ||
                  routeFinish != null ||
                  currentLocation != null)
                MarkerLayer(
                  markers: [
                    if (routeStart != null)
                      Marker(
                        point: LatLng(
                          routeStart.latitude,
                          routeStart.longitude,
                        ),
                        width: 24,
                        height: 24,
                        child: const RouteStartMapMarker(),
                      ),
                    if (showFinish)
                      Marker(
                        point: LatLng(
                          routeFinish.latitude,
                          routeFinish.longitude,
                        ),
                        width: 34,
                        height: 42,
                        alignment: Alignment.bottomCenter,
                        child: const RouteFinishMapMarker(size: Size(34, 42)),
                      ),
                    if (currentLocation != null)
                      Marker(
                        point: currentLocation,
                        width: 22,
                        height: 22,
                        child: const RouteCurrentLocationMapMarker(),
                      ),
                  ],
                ),
            ],
          ),
        if (usingGoogleMaps)
          Positioned(
            left: 10,
            bottom: 46,
            child: _mapSourcesButton(_showMapSources),
          ),
        if (!usingGoogleMaps)
          Positioned(
            left: 10,
            bottom: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.82),
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
                Material(
                  color: AppColors.background.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: _showMapSources,
                    borderRadius: BorderRadius.circular(18),
                    child: const SizedBox.square(
                      dimension: 32,
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryText,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          right: 12,
          bottom: 18,
          child: FloatingActionButton.small(
            heroTag: 'record-map-follow',
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.accent,
            onPressed: _recenterOnCurrentLocation,
            child: Icon(
              _followUser
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(
    LatLng? currentLocation,
    List<List<RideTrackSample>> routeSegments, {
    required bool showFinish,
  }) {
    final initialTarget = currentLocation == null
        ? const gmaps.LatLng(-34.574, -58.418)
        : gmaps.LatLng(currentLocation.latitude, currentLocation.longitude);
    final routePolylines = <gmaps.Polyline>{};
    for (var index = 0; index < routeSegments.length; index++) {
      final segment = routeSegments[index];
      if (segment.length < 2) continue;
      final points = [
        for (final point in segment)
          gmaps.LatLng(point.latitude, point.longitude),
      ];
      routePolylines.addAll([
        gmaps.Polyline(
          polylineId: gmaps.PolylineId('record-border-$index'),
          points: points,
          color: const Color(0xFF17352B),
          width: 8,
          zIndex: 0,
        ),
        gmaps.Polyline(
          polylineId: gmaps.PolylineId('record-route-$index'),
          points: points,
          color: AppColors.accent,
          width: 5,
          zIndex: 1,
        ),
      ]);
    }
    final firstPoint = routeSegments.firstOrNull?.first;
    final lastPoint = routeSegments.lastOrNull?.last;
    final markers = <gmaps.Marker>{};
    if (firstPoint != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('route-start'),
          position: gmaps.LatLng(firstPoint.latitude, firstPoint.longitude),
          icon:
              _markerIcons?.start ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueGreen,
              ),
          anchor: const Offset(.5, .5),
          infoWindow: const gmaps.InfoWindow(title: 'Inicio'),
        ),
      );
    }
    if (showFinish && lastPoint != null && lastPoint != firstPoint) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('route-finish'),
          position: gmaps.LatLng(lastPoint.latitude, lastPoint.longitude),
          icon:
              _markerIcons?.finish ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueRed,
              ),
          anchor: const Offset(.25, .92),
          infoWindow: const gmaps.InfoWindow(title: 'Meta'),
        ),
      );
    }
    if (currentLocation != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('current-location'),
          position: gmaps.LatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
          icon:
              _markerIcons?.currentLocation ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueAzure,
              ),
          anchor: const Offset(.5, .5),
          zIndexInt: 4,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        gmaps.GoogleMap(
          initialCameraPosition: gmaps.CameraPosition(
            target: initialTarget,
            zoom: 14,
          ),
          mapType: _googleMapType,
          compassEnabled: true,
          buildingsEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          zoomControlsEnabled: false,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          polylines: routePolylines,
          markers: markers,
          onMapCreated: _onGoogleMapCreated,
          onCameraMove: (position) => _googleCameraPosition = position,
          onCameraMoveStarted: _onGoogleCameraMoveStarted,
          onCameraIdle: () => _googleMapMoveIsProgrammatic = false,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<gmaps.MapType>(
                tooltip: 'Estilo del mapa',
                onSelected: (mapType) =>
                    setState(() => _googleMapType = mapType),
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
                child: _RecordMapControl(
                  icon: Icons.layers_rounded,
                  label: switch (_googleMapType) {
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
                onTap: _toggleGoogleThreeD,
                borderRadius: BorderRadius.circular(20),
                child: _RecordMapControl(
                  icon: Icons.view_in_ar_rounded,
                  label: '3D',
                  selected: _googleThreeD,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onGoogleMapCreated(gmaps.GoogleMapController controller) {
    _googleMapStartupWatchdog?.cancel();
    _googleMapStartupWatchdog = null;
    _googleMapController = controller;
    _onMapReady();
  }

  void _startGoogleMapStartupWatchdog() {
    if (_googleMapController != null || _googleMapUnavailable) return;
    _googleMapStartupWatchdog ??= Timer(const Duration(seconds: 20), () {
      _googleMapStartupWatchdog = null;
      if (!mounted || _googleMapController != null) return;
      if (mounted) setState(() => _googleMapUnavailable = true);
    });
  }

  void _onGoogleCameraMoveStarted() {
    if (_googleMapMoveIsProgrammatic || !_followUser || !mounted) return;
    setState(() => _followUser = false);
  }

  Future<void> _toggleGoogleThreeD() async {
    final enabled = !_googleThreeD;
    setState(() => _googleThreeD = enabled);
    final current = _googleCameraPosition;
    final target = current?.target ?? const gmaps.LatLng(-34.574, -58.418);
    await _animateGoogleCamera(
      gmaps.CameraPosition(
        target: target,
        zoom: current?.zoom ?? 14,
        bearing: current?.bearing ?? 0,
        tilt: enabled ? 45 : 0,
      ),
    );
  }

  Future<void> _animateGoogleCamera(gmaps.CameraPosition position) async {
    final controller = _googleMapController;
    if (controller == null) return;
    _googleMapMoveIsProgrammatic = true;
    try {
      await controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(position),
      );
    } catch (_) {
      _googleMapMoveIsProgrammatic = false;
    }
  }

  Widget _mapSourcesButton(VoidCallback onTap) => Material(
    color: AppColors.background.withValues(alpha: 0.9),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const SizedBox.square(
        dimension: 32,
        child: Icon(
          Icons.info_outline_rounded,
          color: AppColors.primaryText,
          size: 17,
        ),
      ),
    ),
  );

  void _onMapReady() {
    _mapReady = true;
    final recorder = ref.read(rideRecorderProvider);
    if (recorder.trackPoints.isNotEmpty) {
      _followLatestPoint(recorder.trackPoints.last, force: true);
    } else {
      unawaited(_centerOnCurrentLocation(fallbackToRoute: true));
    }
  }

  Future<void> _recenterOnCurrentLocation() async {
    if (mounted) setState(() => _followUser = true);
    await _centerOnCurrentLocation();
  }

  Future<void> _centerOnCurrentLocation({bool fallbackToRoute = false}) async {
    if (!_mapReady) return;

    try {
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        _showLocationPermissionMessage();
        return;
      }

      geo.Position? lastKnown;
      try {
        lastKnown = await geo.Geolocator.getLastKnownPosition();
      } catch (_) {
        // A fresh GPS fix can still arrive from the position stream.
      }
      if (!mounted) return;
      if (lastKnown != null) {
        _setCurrentPosition(lastKnown);
        if (_followUser) {
          _moveMapCamera(LatLng(lastKnown.latitude, lastKnown.longitude), 15.5);
        }
      }

      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      _setCurrentPosition(position);
      if (_followUser) {
        _moveMapCamera(LatLng(position.latitude, position.longitude), 15.5);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'OpenStreetMap current location unavailable: ${error.runtimeType}',
        );
      }
      if (fallbackToRoute && _currentPosition == null) {
        final points = ref.read(rideRecorderProvider).trackPoints;
        if (points.isNotEmpty) {
          _followLatestPoint(points.last, force: true);
        }
      }
    }
  }

  Future<void> _followLatestPoint(
    RideTrackSample point, {
    bool force = false,
  }) async {
    if (!_mapReady || !_followUser) return;
    if (!force && point.sequence == _lastFollowedSequence) return;
    _lastFollowedSequence = point.sequence;
    _moveMapCamera(LatLng(point.latitude, point.longitude), 16.2);
  }

  void _moveMapCamera(LatLng target, double zoom) {
    if (!_googleMapsEnabled || _googleMapUnavailable) {
      _mapController.move(target, zoom);
      return;
    }
    unawaited(
      _animateGoogleCamera(
        gmaps.CameraPosition(
          target: gmaps.LatLng(target.latitude, target.longitude),
          zoom: zoom,
          tilt: _googleThreeD ? 45 : 0,
        ),
      ),
    );
  }

  void _setCurrentPosition(geo.Position position) {
    if (!mounted) return;
    setState(
      () => _currentPosition = LatLng(position.latitude, position.longitude),
    );
  }

  void _showLocationPermissionMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permití el acceso a la ubicación para centrar el mapa.'),
      ),
    );
  }

  Future<void> _showMapSources() async {
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
              if (_googleMapsEnabled && !_googleMapUnavailable)
                const _MapSourceRow(
                  title: 'Google Maps',
                  detail: 'Mapa y datos cartográficos de Google. Google Maps está activo en toda la app.',
                )
              else ...[
                const _MapSourceRow(
                  title: '© OpenStreetMap contributors',
                  detail: 'Mapa y datos de esta vista. Licencia ODbL: openstreetmap.org/copyright.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordMapControl extends StatelessWidget {
  const _RecordMapControl({
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
      color: AppColors.background.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected ? AppColors.accent : AppColors.divider,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primaryText),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        detail,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 11,
          height: 1.4,
        ),
      ),
    ],
  );
}
