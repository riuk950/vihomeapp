import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:go_router/go_router.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

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

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    // Crear el gestor de anotaciones
    pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();

    // Configurar listener de eventos (tapEvents)
    pointAnnotationManager?.tapEvents(onTap: _handleAnnotationClick);

    _loadPropertyMarkers();
  }

  Future<void> _loadPropertyMarkers() async {
    if (pointAnnotationManager == null) return;

    final provider = Provider.of<PropertyProvider>(context, listen: false);
    // Limpiar marcadores existentes
    await pointAnnotationManager?.deleteAll();

    // Generar imagen del marcador
    final Uint8List markerImage = await _loadMarkerImage();

    try {
      await mapboxMap?.style.addStyleImage(
        'custom-marker',
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

    for (var property in provider.properties) {
      if (property.lat != 0 && property.lng != 0) {
        final point = Point(coordinates: Position(property.lng, property.lat));

        final options = PointAnnotationOptions(
          geometry: point,
          iconImage: 'custom-marker',
          iconSize: 1.0,
          textField: '\$${property.precioRenta}',
          textSize: 12.0,
          textOffset: [0, 2.0],
          textColor: Colors.black.toARGB32(),
        );

        await pointAnnotationManager?.create(options);
      }
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
      text: String.fromCharCode(Icons.home.codePoint),
      style: TextStyle(
        fontSize: 25.0,
        fontFamily: Icons.home.fontFamily,
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
              const Text(
                'Precio de Venta',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${property.precio}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar modal
                      context.push('/property-details', extra: property);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
