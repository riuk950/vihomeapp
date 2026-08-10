import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  MapboxMap? mapboxMap;
  Point? selectedPoint;
  bool _isMoving = false;

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
    setState(() {
      selectedPoint = cameraState.center;
    });
  }

  void _onCameraChange(CameraChangedEventData event) async {
    if (mapboxMap == null) return;

    final cameraState = await mapboxMap!.getCameraState();
    setState(() {
      selectedPoint = cameraState.center;
      _isMoving = true;
    });

    // Pequeño retraso para detectar cuando deja de moverse
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        setState(() {
          _isMoving = false;
        });
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
      if (permission == geo.LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
        }
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Los permisos de ubicación están denegados permanentemente.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition();

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
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              viewport: CameraViewportState(
                center: Point(coordinates: Position(-72.933, 5.715)),
                zoom: 13.0,
              ),
              onCameraChangeListener: _onCameraChange,
            ),
            // Marcador fijo en el centro
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform:
                      Matrix4.translationValues(0, _isMoving ? -10 : 0, 0),
                  child: const Icon(
                    Icons.location_on,
                    size: 45,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            // Punto de referencia (sombra) para el marcador
            Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (selectedPoint != null)
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
