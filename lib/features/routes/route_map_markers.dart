import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

const _markerOutline = Color(0xFFFFFFFF);
const _markerCenter = Color(0xFF07191D);
const _startMarkerColor = Color(0xFFC8F36D);
const _replayMarkerColor = Color(0xFFFFA36B);
const _locationMarkerColor = Color(0xFF3988FF);
const _finishMarkerColor = Color(0xFFE74646);

/// Google Maps uses native bitmap descriptors; OSM uses the same artwork as
/// Flutter widgets so route markers stay recognizable across both providers.
class RouteMapMarkerIcons {
  const RouteMapMarkerIcons({
    required this.start,
    required this.finish,
    required this.replayPosition,
    required this.currentLocation,
  });

  final gmaps.BitmapDescriptor start;
  final gmaps.BitmapDescriptor finish;
  final gmaps.BitmapDescriptor replayPosition;
  final gmaps.BitmapDescriptor currentLocation;

  static Future<RouteMapMarkerIcons>? _cached;

  static Future<RouteMapMarkerIcons> load() => _cached ??= _create();

  static Future<RouteMapMarkerIcons> _create() async => RouteMapMarkerIcons(
    start: await _bitmap(_paintStartMarker, 48, 48, 24, 24),
    finish: await _bitmap(_paintFinishMarker, 64, 80, 32, 40),
    replayPosition: await _bitmap(_paintReplayMarker, 44, 44, 22, 22),
    currentLocation: await _bitmap(_paintLocationMarker, 44, 44, 22, 22),
  );

  static Future<gmaps.BitmapDescriptor> _bitmap(
    void Function(Canvas canvas, Size size) paintMarker,
    int pixelWidth,
    int pixelHeight,
    double width,
    double height,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paintMarker(canvas, Size(pixelWidth.toDouble(), pixelHeight.toDouble()));
    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelWidth, pixelHeight);
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('No se pudo generar un marcador del mapa.');
    }
    return gmaps.BitmapDescriptor.bytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      imagePixelRatio: 2,
      width: width,
      height: height,
    );
  }
}

class RouteStartMapMarker extends StatelessWidget {
  const RouteStartMapMarker({super.key, this.size = const Size(22, 22)});

  final Size size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _StartMarkerPainter());
}

class RouteReplayMapMarker extends StatelessWidget {
  const RouteReplayMapMarker({super.key, this.size = const Size(20, 20)});

  final Size size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _ReplayMarkerPainter());
}

class RouteCurrentLocationMapMarker extends StatelessWidget {
  const RouteCurrentLocationMapMarker({
    super.key,
    this.size = const Size(22, 22),
  });

  final Size size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _LocationMarkerPainter());
}

class RouteFinishMapMarker extends StatelessWidget {
  const RouteFinishMapMarker({super.key, this.size = const Size(30, 38)});

  final Size size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _FinishMarkerPainter());
}

class _StartMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => _paintStartMarker(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReplayMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => _paintReplayMarker(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => _paintLocationMarker(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FinishMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => _paintFinishMarker(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _paintStartMarker(Canvas canvas, Size size) =>
    _paintCircleMarker(canvas, size, _startMarkerColor);

void _paintReplayMarker(Canvas canvas, Size size) =>
    _paintCircleMarker(canvas, size, _replayMarkerColor);

void _paintLocationMarker(Canvas canvas, Size size) =>
    _paintCircleMarker(canvas, size, _locationMarkerColor);

void _paintCircleMarker(Canvas canvas, Size size, Color color) {
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.shortestSide * .43;
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = _markerOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .16,
  );
  canvas.drawCircle(center, radius * .88, Paint()..color = color);
  canvas.drawCircle(center, radius * .26, Paint()..color = _markerCenter);
}

void _paintFinishMarker(Canvas canvas, Size size) {
  canvas.save();
  canvas.scale(size.width / 64, size.height / 80);

  final pole = Paint()
    ..color = _markerCenter
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(16, 8), const Offset(16, 73), pole);
  canvas.drawLine(
    const Offset(16, 8),
    const Offset(16, 73),
    Paint()
      ..color = _markerOutline
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round,
  );

  final flag = Path()
    ..moveTo(19, 10)
    ..lineTo(57, 14)
    ..lineTo(47, 25)
    ..lineTo(57, 36)
    ..lineTo(19, 32)
    ..close();
  canvas.drawPath(flag, Paint()..color = _finishMarkerColor);
  canvas.save();
  canvas.clipPath(flag);
  const cellWidth = 9.5;
  const cellHeight = 11.5;
  for (var row = 0; row < 2; row++) {
    for (var column = 0; column < 4; column++) {
      if ((row + column).isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            19 + column * cellWidth,
            10 + row * cellHeight,
            cellWidth,
            cellHeight,
          ),
          Paint()..color = _markerOutline,
        );
      }
    }
  }
  canvas.restore();
  canvas.drawPath(
    flag,
    Paint()
      ..color = const Color(0xFF7B2020)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  canvas.restore();
}
