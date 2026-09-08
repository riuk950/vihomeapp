import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  MapboxMap? mapboxMap;
  Point? selectedPoint;
  final ValueNotifier<bool> _isMovingNotifier = ValueNotifier<bool>(false);
  Timer? _debounceTimer;
  late final CameraViewportState _initialViewport;

  @override
  void initState() {
    super.initState();
    _initialViewport = CameraViewportState(
      center: Point(
        coordinates: Position(
          widget.initialLongitude ?? -72.933,
          widget.initialLatitude ?? 5.715,
        ),
      ),
      zoom: widget.initialLatitude != null ? 15.0 : 13.0,
    );
    if (EnvDef.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(EnvDef.mapboxAccessToken);
    }
    // Solicitar permisos de ubicación al iniciar
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _isMovingNotifier.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!mounted) return;
    if (status.isGranted) {
      debugPrint('Permiso de ubicación concedido');
      if (mapboxMap != null) {
        await _enableLocationPuck();
      }
    } else if (status.isDenied) {
      debugPrint('Permiso de ubicación denegado');
    } else if (status.isPermanentlyDenied) {
      debugPrint('Permiso de ubicación denegado permanentemente');
    }
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Verificar permisos antes de habilitar el puck
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _enableLocationPuck();
    }

    // Inicializar el punto seleccionado con el centro inicial
    final cameraState = await mapboxMap.getCameraState();
    if (!mounted) return;
    setState(() {
      selectedPoint = cameraState.center;
    });
  }

  void _onCameraChange(CameraChangedEventData event) {
    if (!_isMovingNotifier.value) {
      _isMovingNotifier.value = true;
    }

    // Pequeño retraso para detectar cuando deja de moverse
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () async {
      if (!mounted) return;
      _isMovingNotifier.value = false;
      if (mapboxMap != null) {
        final cameraState = await mapboxMap!.getCameraState();
        if (!mounted) return;
        selectedPoint = cameraState.center;
      }
    });
  }

  Future<void> _enableLocationPuck() async {
    if (mapboxMap == null) return;

    try {
      // Configurar el puck de ubicación
      await mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          pulsingColor: primaryColor.toARGB32(),
          pulsingMaxRadius: 20.0,
          showAccuracyRing: true,
          accuracyRingColor: primaryColor.withValues(alpha: 0.2).toARGB32(),
          accuracyRingBorderColor:
              primaryColor.withValues(alpha: 0.5).toARGB32(),
        ),
      );

      debugPrint('Location puck habilitado correctamente');
    } catch (e) {
      debugPrint('Error al habilitar location puck: $e');
    }
  }

  void _centerOnUserLocation() async {
    // Verificar si tenemos permisos
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (!mounted) return;
      if (permission == geo.LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
        return;
      }
    }

    if (!mounted) return;

    if (permission == geo.LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los permisos de ubicación están denegados permanentemente.',
          ),
        ),
      );
      return;
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition();
      if (!mounted) return;

      if (mapboxMap != null) {
        mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );

        // Asegurarse de que el puck esté habilitado
        await _enableLocationPuck();
      }
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener la ubicación actual')),
        );
      }
    }
  }

  Future<void> _confirmSelection() async {
    if (mapboxMap != null) {
      final cameraState = await mapboxMap!.getCameraState();
      if (!mounted) return;
      context.pop(cameraState.center);
    } else if (selectedPoint != null) {
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
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              viewport: _initialViewport,
              onCameraChangeListener: _onCameraChange,
            ),
            // Marcador fijo en el centro con animación reactiva
            ValueListenableBuilder<bool>(
              valueListenable: _isMovingNotifier,
              builder: (context, isMoving, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform:
                          Matrix4.translationValues(0, isMoving ? -10 : 0, 0),
                      child: const Icon(
                        Icons.location_on,
                        size: 45,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Punto de referencia (sombra) para el marcador
            Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: backgroundColor,
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
                backgroundColor: backgroundColor,
                foregroundColor: primaryColor,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
