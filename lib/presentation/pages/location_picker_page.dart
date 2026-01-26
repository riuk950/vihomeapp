import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  Point? selectedPoint;

  @override
  void initState() {
    super.initState();
    if (EnvDef.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(EnvDef.mapboxAccessToken);
    }
    // Solicitar permisos de ubicación al iniciar
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      debugPrint('Permiso de ubicación concedido');
    } else if (status.isDenied) {
      debugPrint('Permiso de ubicación denegado');
    } else if (status.isPermanentlyDenied) {
      debugPrint('Permiso de ubicación denegado permanentemente');
      // Opcionalmente, abrir configuración de la app
      // await openAppSettings();
    }
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Habilitar el puck de ubicación
    await _enableLocationPuck();

    // Crear el gestor de anotaciones
    pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();

    // Cargar imagen del marcador
    final Uint8List markerImage = await _loadMarkerImage();
    try {
      await mapboxMap.style.addStyleImage(
        'selected-marker',
        2.0,
        MbxImage(width: 40, height: 40, data: markerImage),
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint('Error adding image to style: $e');
    }
  }

  Future<void> _enableLocationPuck() async {
    if (mapboxMap == null) return;

    try {
      // Configurar el puck de ubicación
      await mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          pulsingColor: Colors.blue.toARGB32(),
          pulsingMaxRadius: 20.0,
          showAccuracyRing: true,
          accuracyRingColor: Colors.blue.withValues(alpha: 0.2).toARGB32(),
          accuracyRingBorderColor: Colors.blue
              .withValues(alpha: 0.5)
              .toARGB32(),
        ),
      );

      debugPrint('Location puck habilitado correctamente');
    } catch (e) {
      debugPrint('Error al habilitar location puck: $e');
    }
  }

  void _centerOnUserLocation() async {
    // Verificar si tenemos permisos
    final status = await Permission.location.status;

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Necesitas conceder permisos de ubicación para usar esta función',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Intentar solicitar permisos nuevamente
      await _requestLocationPermission();
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El puck azul muestra tu ubicación actual'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<Uint8List> _loadMarkerImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    final radius = 20.0;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on.codePoint),
      style: TextStyle(
        fontSize: 25.0,
        fontFamily: Icons.location_on.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      (radius * 2).toInt(),
      (radius * 2).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _handleMapTap(MapContentGestureContext mapContext) {
    final point = mapContext.point;

    setState(() {
      selectedPoint = point;
    });

    _updateMarker(point);
  }

  Future<void> _updateMarker(Point point) async {
    if (pointAnnotationManager == null) return;

    await pointAnnotationManager?.deleteAll();

    final options = PointAnnotationOptions(
      geometry: point,
      iconImage: 'selected-marker',
      iconSize: 1.0,
    );

    await pointAnnotationManager?.create(options);
  }

  void _confirmSelection() {
    if (selectedPoint != null) {
      context.pop(selectedPoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (EnvDef.mapboxAccessToken.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text(
            'No se encontró el token de Mapbox.\nConfigure MAPBOX_ACCESS_TOKEN en el archivo .env',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          if (selectedPoint != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
            ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(-72.933, 5.715)),
              zoom: 13.0,
            ),
            onTapListener: _handleMapTap,
          ),
          if (selectedPoint != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137FEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar Ubicación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: _centerOnUserLocation,
              tooltip: 'Mi ubicación',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
