import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/constructora.dart';
import '../../../domain/usecases/usecases.dart';

class DetallesProyectoPage extends StatefulWidget {
  final Project project;
  const DetallesProyectoPage({super.key, required this.project});

  @override
  State<DetallesProyectoPage> createState() => _DetallesProyectoPageState();
}

class _DetallesProyectoPageState extends State<DetallesProyectoPage> {
  late PageController _pageController;
  int _currentPage = 0;
  Constructora? _constructora;
  bool _isLoadingConstructora = true;

  @override
  void initState() {
    super.initState();
    if (EnvDef.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(EnvDef.mapboxAccessToken);
    }
    _pageController = PageController();
    _loadConstructora();
  }

  Future<void> _loadConstructora() async {
    try {
      final useCase = getIt<GetConstructoraUseCase>();
      final constructora = await useCase(widget.project.constructoraId);
      if (mounted) {
        setState(() {
          _constructora = constructora;
          _isLoadingConstructora = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading constructora: $e');
      if (mounted) {
        setState(() {
          _isLoadingConstructora = false;
        });
      }
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    final pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    final Uint8List markerImage = await _loadMarkerImage();

    try {
      await mapboxMap.style.addStyleImage(
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

    final point = Point(
      coordinates: Position(widget.project.lng, widget.project.lat),
    );

    final options = PointAnnotationOptions(
      geometry: point,
      iconImage: 'custom-marker',
      iconSize: 1.0,
    );

    await pointAnnotationManager.create(options);
  }

  Future<Uint8List> _loadMarkerImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    final radius = 20.0;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Contenido scrolleable
          CustomScrollView(
            slivers: [
              // Hero Image + AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                ],
                title: const Text(
                  'Detalles del proyecto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Carrusel de imágenes
                      if (project.fotos.isNotEmpty)
                        Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: project.fotos.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: project.fotos[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Center(
                                    child: Icon(Icons.error),
                                  ),
                                );
                              },
                            ),
                            // Indicador de página
                            if (project.fotos.length > 1)
                              Positioned(
                                bottom: 20,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_currentPage + 1}/${project.fotos.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      else
                        // Imagen placeholder si no hay fotos
                        Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(
                              Icons.apartment,
                              size: 80,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      // Gradient Overlay para mejorar legibilidad
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                                stops: const [0.0, 0.2, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Badge de estado
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(project.estado),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              project.estado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de información principal
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tipo y precio
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.tipoPropiedad,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Estrato ${project.estrato}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Desde',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(project.precioDesde),
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Chips de características
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChip(
                                    Icons.bed_outlined,
                                    '${project.habitaciones} hab',
                                    isPrimary: true,
                                  ),
                                  _buildChip(
                                    Icons.straighten,
                                    '${project.area.toStringAsFixed(0)} m²',
                                    isPrimary: true,
                                  ),
                                  _buildChip(
                                    Icons.location_on_outlined,
                                    project.ubicacionPrincipal,
                                    isPrimary: false,
                                  ),
                                  if (project.parqueaderos > 0)
                                    _buildChip(
                                      Icons.directions_car_outlined,
                                      '${project.parqueaderos} parq.',
                                      isPrimary: false,
                                    ),
                                  if (project.financiacion)
                                    _buildChip(
                                      Icons.payments_outlined,
                                      'Financiación',
                                      isPrimary: true,
                                    ),
                                  if (project.aplicaSubsidio)
                                    _buildChip(
                                      Icons.volunteer_activism_outlined,
                                      'Aplica Subsidio',
                                      isPrimary: true,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Descripción
                    _buildSection(
                      context,
                      title: 'Descripción del Proyecto',
                      child: Text(
                        project.descripcion.isNotEmpty
                            ? project.descripcion
                            : 'Sin descripción disponible.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Detalles adicionales
                    _buildSection(
                      context,
                      title: 'Información del Proyecto',
                      child: _buildInfoGrid(project),
                    ),

                    // Constructora
                    if (_isLoadingConstructora)
                      _buildSection(
                        context,
                        title: 'Constructora',
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (_constructora != null)
                      _buildSection(
                        context,
                        title: 'Constructora',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (_constructora!.logoUrl != null &&
                                      _constructora!.logoUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: _constructora!.logoUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.business),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.business,
                                        size: 40, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _constructora!.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'NIT: ${_constructora!.nit}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_constructora!.direccion != null ||
                                  _constructora!.ciudad != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${_constructora!.direccion ?? ''}${_constructora!.direccion != null && _constructora!.ciudad != null ? ', ' : ''}${_constructora!.ciudad ?? ''}${_constructora!.ciudad != null && _constructora!.departamento != null ? ' - ' : ''}${_constructora!.departamento ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12)
                            ],
                          ),
                        ),
                      ),

                    if (project.amenidades != null &&
                        project.amenidades!['items'] != null)
                      _buildSection(
                        context,
                        title: 'Amenidades',
                        child: SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                (project.amenidades!['items'] as List).length,
                            itemBuilder: (context, index) {
                              final name =
                                  project.amenidades!['items'][index] as String;
                              return _buildAmenityItem(name);
                            },
                          ),
                        ),
                      ),

                    // Sección de mapa / ubicación
                    _buildSection(
                      context,
                      title: 'Ubicación',
                      child: GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${project.lat},${project.lng}',
                          );
                          if (!await launchUrl(url)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No se pudo abrir el mapa'),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: IgnorePointer(
                              child: MapWidget(
                                onMapCreated: _onMapCreated,
                                cameraOptions: CameraOptions(
                                  center: Point(
                                    coordinates: Position(
                                      project.lng,
                                      project.lat,
                                    ),
                                  ),
                                  zoom: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fecha de entrega (si aplica)
                    if (project.fechaFinalizacion != null)
                      _buildSection(
                        context,
                        title: 'Fecha de Entrega',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(project.fechaFinalizacion!),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Espacio para el bottom bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),

          // Botones sticky en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final text = Uri.encodeComponent(
                            'Hola, estoy interesado en el proyecto ${_constructora!.nombre} - ${widget.project.tipoPropiedad}');
                        final url = Uri.parse(
                            'https://wa.me/${_constructora!.whatsapp}?text=$text');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: const Text(
                        'Contactar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse(_constructora!.sitioWeb!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'Solicitar Información',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? headerAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? primaryColor.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isPrimary ? primaryColor : const Color(0xFF64748B),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrimary ? primaryColor : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Project project) {
    final items = [
      (Icons.layers_outlined, 'Pisos del proyecto', '${project.cantidadPisos}'),
      (Icons.bathtub_outlined, 'Baños', '${project.banos}'),
      (
        Icons.attach_money,
        'Cuota Inicial',
        _formatCurrency(project.coutaInicial)
      ),
      (
        Icons.price_change_outlined,
        'Precio Hasta',
        _formatCurrency(project.precioHasta)
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.0,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(item.$1, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenityItem(String name) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getAmenityIcon(name), color: primaryColor, size: 28),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'piscina':
        return Icons.pool;
      case 'gimnasio':
        return Icons.fitness_center;
      case 'seguridad 24/7':
      case 'portería':
      case 'porteria':
        return Icons.security_outlined;
      case 'zonas verdes':
      case 'sendero peatonal':
        return Icons.park_outlined;
      case 'parqueadero':
        return Icons.local_parking_outlined;
      case 'ascensor':
        return Icons.elevator_outlined;
      case 'cancha múltiple':
      case 'cancha multiple':
        return Icons.sports_basketball_outlined;
      case 'salón social':
      case 'salon social':
        return Icons.groups_outlined;
      case 'juegos infantiles':
        return Icons.child_care_outlined;
      case 'zona bbq':
      case 'bbq':
        return Icons.outdoor_grill_outlined;
      case 'turco':
        return Icons.hot_tub_outlined;
      case 'sauna':
        return Icons.spa_outlined;
      case 'coworking':
        return Icons.laptop_mac_outlined;
      case 'pet friendly':
        return Icons.pets_outlined;
      case 'shut de basuras':
        return Icons.delete_outline;
      case 'circuito cerrado':
        return Icons.videocam_outlined;
      case 'citofonía':
      case 'citofonia':
        return Icons.phone_in_talk_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'en construcción':
      case 'en construccion':
        return primaryColor;
      case 'entrega inmediata':
        return const Color(0xFF10B981);
      case 'sobre planos':
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      customPattern: '\$ #,##0',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'es');
    return formatter.format(date);
  }
}
