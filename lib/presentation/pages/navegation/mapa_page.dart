import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart' as geo;

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
    customPattern:
        '\u00A4#,##0', // El caracter \u00A4 representa el símbolo de moneda
  );

  @override
  void initState() {
    super.initState();
    if (EnvDef.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(EnvDef.mapboxAccessToken);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PropertyProvider>(context, listen: false);
      if (provider.properties.isEmpty) {
        provider.fetchProperties();
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
          pulsingColor: Colors.blue.toARGB32(),
          pulsingMaxRadius: 20.0,
          showAccuracyRing: true,
          accuracyRingColor: Colors.blue.withValues(alpha: 0.2).toARGB32(),
          accuracyRingBorderColor:
              Colors.blue.withValues(alpha: 0.5).toARGB32(),
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
        mapboxMap!.setCamera(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15.0,
          ),
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

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Verificar permisos antes de habilitar el puck
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _enableLocationPuck();
    }

    // Crear el gestor de anotaciones
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Configurar listener de eventos (tapEvents)
    pointAnnotationManager?.tapEvents(onTap: _handleAnnotationClick);

    _loadPropertyMarkers();
  }

  IconData _getIconForPropertyType(String tipoPropiedad) {
    switch (tipoPropiedad.toLowerCase()) {
      case 'casa':
        return Icons.house;
      case 'apartamento':
        return Icons.apartment;
      case 'local':
        return Icons.store;
      case 'oficina':
        return Icons.business;
      case 'lote':
      case 'terreno':
        return Icons.landscape;
      case 'finca':
        return Icons.agriculture;
      case 'bodega':
        return Icons.warehouse;
      case 'habitacion':
      case 'habitación':
        return Icons.bed;
      default:
        return Icons.home;
    }
  }

  Future<void> _loadPropertyMarkers() async {
    if (pointAnnotationManager == null) return;

    final provider = Provider.of<PropertyProvider>(context, listen: false);
    // Limpiar marcadores existentes
    await pointAnnotationManager?.deleteAll();

    final Set<String> registeredMarkers = {};

    for (var property in provider.properties) {
      if (property.lat != 0 && property.lng != 0) {
        final point = Point(coordinates: Position(property.lng, property.lat));

        final bool isArriendo = property.estado.toLowerCase() == 'arriendo';
        final double? price =
            isArriendo ? property.precioRenta : property.precioVenta;
        final String priceText =
            price != null ? currencyFormat.format(price) : 'N/A';

        final IconData icon = isArriendo
            ? _getIconForPropertyType(property.tipoPropiedad)
            : Icons.home;
        final String markerKey =
            isArriendo ? 'marker-arriendo-${icon.codePoint}' : 'marker-venta';

        if (!registeredMarkers.contains(markerKey)) {
          final Color color = isArriendo ? Colors.blue : Colors.red;
          final Uint8List markerBytes = await _loadMarkerImage(color, icon);
          try {
            await mapboxMap?.style.addStyleImage(
              markerKey,
              2.0,
              MbxImage(width: 40, height: 40, data: markerBytes),
              false,
              [],
              [],
              null,
            );
          } catch (e) {
            debugPrint('Error adding images to style: $e');
          }
          registeredMarkers.add(markerKey);
        }

        final options = PointAnnotationOptions(
          geometry: point,
          iconImage: markerKey,
          iconSize: 1.0,
          textField: priceText,
          textSize: 12.0,
          textOffset: [0, 2.0],
          textColor: Colors.black.toARGB32(),
        );

        await pointAnnotationManager?.create(options);
      }
    }
  }

  Future<Uint8List> _loadMarkerImage(Color color, IconData iconData) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    final radius = 20.0;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 25.0,
        color: Colors.white,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
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
      appBar: AppBar(title: const Text('Mapa Propiedades'), centerTitle: true),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              MapWidget(
                onMapCreated: _onMapCreated,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-72.933, 5.715)),
                  zoom: 13.0,
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _loadPropertyMarkers,
                  child: const Icon(Icons.refresh),
                ),
              ),
              Positioned(
                bottom: 80,
                right: 20,
                child: FloatingActionButton(
                  heroTag: 'location',
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _centerOnUserLocation();
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAnnotationClick(PointAnnotation annotation) {
    if (!mounted) return;
    try {
      final lat = annotation.geometry.coordinates.lat.toDouble();
      final lng = annotation.geometry.coordinates.lng.toDouble();

      final provider = Provider.of<PropertyProvider>(context, listen: false);
      final list = provider.properties;

      final property = list.firstWhere(
        (p) => (p.lat - lat).abs() < 0.0001 && (p.lng - lng).abs() < 0.0001,
      );

      if ((property.lat - lat).abs() < 0.0001) {
        _showPropertyDetails(property);
      }
    } catch (e) {
      debugPrint('Error finding property for annotation: $e');
    }
  }

  void _showPropertyDetails(Property property) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        final bool isArriendo = property.estado.toLowerCase() == 'arriendo';

        final double? price =
            isArriendo ? property.precioRenta : property.precioVenta;
        final String priceText =
            price != null ? currencyFormat.format(price) : 'N/A';

        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                property.direccion,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(Icons.bed, '${property.habitaciones} Hab'),
                  _infoItem(Icons.bathtub, '${property.banos} Baños'),
                  _infoItem(
                    Icons.aspect_ratio,
                    '${property.metrosCuadrados} m²',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                isArriendo ? 'Precio de Arriendo' : 'Precio de Venta',
                style: const TextStyle(color: disabledColor, fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar modal
                      context.push('/property-details', extra: property);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ver Detalles'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
