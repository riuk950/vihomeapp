import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/widgets/btn_primary.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/domain/usecases/landlord/get_landlord_profile_usecase.dart';

class DetallesPropiedadesPage extends StatefulWidget {
  final Property property;

  const DetallesPropiedadesPage({super.key, required this.property});

  @override
  State<DetallesPropiedadesPage> createState() =>
      _DetallesPropiedadesPageState();
}

class _DetallesPropiedadesPageState extends State<DetallesPropiedadesPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isLoadingLandlord = true;
  Landlord? _landlord;
  bool _hasExistingApplication = false;
  bool _isCheckingApplication = false;

  @override
  void initState() {
    super.initState();
    if (EnvDef.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(EnvDef.mapboxAccessToken);
    }
    _fetchLandlordInfo();
    _checkExistingApplication();
  }

  Future<void> _fetchLandlordInfo() async {
    try {
      final useCase = getIt<GetLandlordProfileUseCase>();
      final result = await useCase(widget.property.arrendadorId);
      result.fold(
        (failure) {
          if (mounted) setState(() => _isLoadingLandlord = false);
        },
        (landlord) {
          if (mounted) {
            setState(() {
              _landlord = landlord;
              _isLoadingLandlord = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isLoadingLandlord = false);
    }
  }

  Future<void> _checkExistingApplication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null && user.role == 'arrendatario') {
      setState(() => _isCheckingApplication = true);
      try {
        final appProvider =
            Provider.of<ApplicationProvider>(context, listen: false);
        final exists = await appProvider.hasApplicationForProperty(
            user.id, widget.property.id);
        if (mounted) setState(() => _hasExistingApplication = exists);
      } catch (e) {
        debugPrint('Error checking application: $e');
      } finally {
        if (mounted) setState(() => _isCheckingApplication = false);
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
      coordinates: Position(widget.property.lng, widget.property.lat),
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
    const radius = 20.0;

    canvas.drawCircle(const Offset(radius, radius), radius, paint);

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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isOwner = user != null && user.id == widget.property.arrendadorId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Detalles de la Propiedad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageCarousel(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.property.estado == 'arriendo'
                      ? _buildArriendoContent()
                      : _buildVentaContent(),
                ),
              ),
            ],
          ),
          if (isOwner)
            _buildOwnerActionBar()
          else if (user?.role == 'arrendatario' &&
              widget.property.estado == 'arriendo')
            _buildTenantActionBar(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.property.fotos.isEmpty
                    ? 1
                    : widget.property.fotos.length,
                itemBuilder: (context, index) {
                  if (widget.property.fotos.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.home, size: 64, color: Colors.grey),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: CachedNetworkImage(
                      imageUrl: widget.property.fotos[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                },
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.property.fotos.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.property.fotos.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: _currentImageIndex == entry.key ? 0.9 : 0.4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArriendoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainInfo(
            '\$${(widget.property.precioRenta ?? widget.property.precio).toStringAsFixed(0)} COP/mes'),
        _buildFeatures(),
        _buildDivider(),
        _buildDescription(),
        _buildDivider(),
        _buildAmenities(),
        _buildDivider(),
        _buildLandlordProfile(),
        _buildDivider(),
        _buildLocation(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildVentaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainInfo(
            '\$${(widget.property.precioVenta ?? widget.property.precio).toStringAsFixed(0)} COP'),
        _buildFeatures(),
        _buildDivider(),
        _buildDescription(),
        _buildDivider(),
        _buildAmenities(),
        _buildDivider(),
        _buildLandlordProfile(),
        _buildDivider(),
        _buildContactInfo(),
        _buildDivider(),
        _buildLocation(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildMainInfo(String priceText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.property.titulo,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Text(
          widget.property.direccion,
          style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 16),
        Text(
          priceText,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFeatureItem(
            Icons.bed_outlined, '${widget.property.habitaciones} Hab'),
        _buildFeatureItem(
            Icons.bathtub_outlined, '${widget.property.banos} Baños'),
        _buildFeatureItem(Icons.square_foot,
            '${widget.property.metrosCuadrados.toStringAsFixed(0)} m²'),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        Text(
          widget.property.descripcion.isNotEmpty
              ? widget.property.descripcion
              : 'Disfruta de la vida de lujo en este espectacular inmueble. Con acabados modernos, amplios espacios y una ubicación inmejorable. Ideal para quienes buscan comodidad y estilo.',
          style: const TextStyle(
              fontSize: 16, height: 1.5, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenidades',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 2),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          children: [
            _buildAmenityItem(Icons.pool, 'Alberca'),
            _buildAmenityItem(Icons.fitness_center, 'Gimnasio'),
            _buildAmenityItem(Icons.local_parking, 'Estacionamiento'),
            _buildAmenityItem(Icons.pets, 'Mascotas'),
            _buildAmenityItem(Icons.balcony, 'Balcón'),
            _buildAmenityItem(Icons.security, 'Seguridad 24/7'),
          ],
        ),
      ],
    );
  }

  Widget _buildLandlordProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _isLoadingLandlord
          ? const Row(
              children: [
                CircleAvatar(radius: 28, backgroundColor: Colors.grey),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 16,
                          width: 100,
                          child: LinearProgressIndicator()),
                      SizedBox(height: 8),
                      SizedBox(
                          height: 12,
                          width: 60,
                          child: LinearProgressIndicator()),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _landlord != null
                            ? '${_landlord!.primerNombre} ${_landlord!.primerApellido}'
                            : 'Propietario',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Propietario',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.blue),
              ],
            ),
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${widget.property.lat},${widget.property.lng}',
            );
            if (!await launchUrl(url)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir el mapa')),
                );
              }
            }
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IgnorePointer(
                child: MapWidget(
                  onMapCreated: _onMapCreated,
                  cameraOptions: CameraOptions(
                    center: Point(
                        coordinates:
                            Position(widget.property.lng, widget.property.lat)),
                    zoom: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Consumer<LandlordPropertiesProvider>(
          builder: (context, provider, child) {
            final isPublished = widget.property.publicado;
            return ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success = await provider.togglePropertyPublication(
                        widget.property.id,
                        widget.property.publicado,
                      );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isPublished
                                  ? 'Propiedad despublicada exitosamente'
                                  : 'Propiedad publicada exitosamente',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPublished ? primaryColor : const Color(0xFF137FEC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isPublished ? 'Pausar Publicación' : 'Publicar propiedad',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 10, color: Colors.transparent));

  Widget _buildTenantActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Consumer<TenantProvider>(
          builder: (context, tenantProvider, child) {
            if (_isCheckingApplication) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_hasExistingApplication) {
              return ElevatedButton.icon(
                onPressed: () async {
                  await context.push('/solicitudes-arrendatario');
                  if (mounted) _checkExistingApplication();
                },
                icon: const Icon(Icons.list_alt, color: Colors.white),
                label: const Text('Ver Mis Solicitudes',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            }

            return BtnPrimary(
              text: "Solicitar Arriendo",
              onPressed: () async {
                if (!tenantProvider.isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Debes completar tu perfil antes de solicitar un arriendo'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  await context.push('/complete-profile');
                } else {
                  await context.push(
                    '/solicitud-arriendo',
                    extra: {
                      'propertyId': widget.property.id,
                      'propertyTitle': widget.property.titulo,
                      'landlordId': widget.property.arrendadorId,
                    },
                  );
                }
                if (mounted) _checkExistingApplication();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF137FEC)),
        ),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contacto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (_landlord == null || _landlord!.telefonoContacto.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Información de contacto no disponible')),
                );
                return;
              }
              final phone = _landlord!.telefonoContacto;
              final message =
                  "Hola, estoy interesado en tu propiedad: ${widget.property.titulo}";
              final whatsappUrl = Uri.parse(
                  "https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl,
                    mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                  );
                }
              }
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: const Text(
              'Contactar por WhatsApp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
