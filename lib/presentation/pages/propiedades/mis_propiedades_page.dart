import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import 'package:vihomeapp/presentation/widgets/alert_dialog.dart';
import 'package:vihomeapp/presentation/widgets/ad_banner_widget.dart';

class MisPropiedadesPage extends StatefulWidget {
  const MisPropiedadesPage({super.key});

  @override
  State<MisPropiedadesPage> createState() => _MisPropiedadesPageState();
}

class _MisPropiedadesPageState extends State<MisPropiedadesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final landlordPropertiesProvider =
          Provider.of<LandlordPropertiesProvider>(context, listen: false);
      final applicationProvider =
          Provider.of<ApplicationProvider>(context, listen: false);

      if (authProvider.user != null) {
        landlordPropertiesProvider.fetchPropertiesByLandlord(
          authProvider.user!.id,
        );
        applicationProvider.fetchLandlordApplications(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111418)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mis Propiedades',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: primaryColor),
            onPressed: () {
              context.push('/crear-propiedad');
            },
            tooltip: 'Agregar propiedad',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<LandlordPropertiesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        if (authProvider.user != null) {
                          provider.fetchPropertiesByLandlord(
                            authProvider.user!.id,
                          );
                        }
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 80, color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes propiedades registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega tu primera propiedad para comenzar',
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/crear-propiedad');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Propiedad'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Stats Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total',
                          provider.properties.length.toString(),
                          primaryColor,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildStatItem(
                          'Activas',
                          provider.activePropertiesCount.toString(),
                          const Color(0xFF10B981),
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildStatItem(
                          'Inactivas',
                          provider.inactivePropertiesCount.toString(),
                          disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Properties List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.properties.length,
                    itemBuilder: (context, index) {
                      final property = provider.properties[index];
                      return _buildPropertyCard(context, property);
                    },
                  ),
                ),

                const AdBannerWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF617589)),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    final acceptedApplications = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    )
        .applications
        .where(
          (application) =>
              application.propiedadId == property.id &&
              application.estado.toLowerCase() == 'aceptada',
        )
        .toList();
    final hasAcceptedApplications = acceptedApplications.isNotEmpty;
    final isPropertyActive = property.publicado && !hasAcceptedApplications;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          context.push('/property-details', extra: property);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                property.fotos.isNotEmpty
                    ? Image.network(
                        property.fotos.first,
                        cacheWidth: 720,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.home, size: 50, color: Colors.grey),
                        ),
                      ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPropertyActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPropertyActive ? 'Activa' : 'Inactiva',
                      style: const TextStyle(
                        color: backgroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer<LandlordPropertiesProvider>(
                        builder: (context, provider, _) {
                          final isPublished = property.publicado;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                  size: 22,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                tooltip: 'Editar propiedad',
                                onPressed: () {
                                  _confirmEditProperty(context, property);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFEF4444),
                                  size: 22,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                tooltip: 'Eliminar propiedad',
                                onPressed: () {
                                  _confirmDeleteProperty(context, property);
                                },
                              ),
                              if (hasAcceptedApplications)
                                IconButton(
                                  icon: const Icon(
                                    Icons.assignment_turned_in,
                                    color: Color(0xFF10B981),
                                    size: 22,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  tooltip: 'Ver solicitud aceptada',
                                  onPressed: () {
                                    if (acceptedApplications.isNotEmpty) {
                                      context.push(
                                        '/detalle-solicitud-arrendador',
                                        extra: acceptedApplications.first,
                                      );
                                    }
                                  },
                                ),
                              if (!hasAcceptedApplications)
                                _buildTogglePublishButton(
                                  context,
                                  provider,
                                  property,
                                  isPublished,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  if (hasAcceptedApplications)
                    InkWell(
                      onTap: () {
                        if (Provider.of<ApplicationProvider>(context,
                                listen: false)
                            .applications
                            .where((application) =>
                                application.propiedadId == property.id &&
                                application.estado.toLowerCase() == 'aceptada')
                            .isNotEmpty) {
                          context.push(
                            '/detalle-solicitud-arrendador',
                            extra: Provider.of<ApplicationProvider>(
                              context,
                              listen: false,
                            ).applications.firstWhere(
                                  (application) =>
                                      application.propiedadId == property.id &&
                                      application.estado.toLowerCase() ==
                                          'aceptada',
                                ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Color(0xFFB45309),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tiene solicitudes aceptadas; la propiedad queda inactiva y la solicitud puede revisarse aquí.',
                                style: TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.direccion}, ${property.ciudad}',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.estado == 'arriendo'
                        ? '${_formatCurrency(property.precioRenta ?? property.precio)} COP/mes'
                        : '${_formatCurrency(property.precioVenta ?? property.precio)} COP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFeature(
                        Icons.bed_outlined,
                        '${property.habitaciones} Hab',
                      ),
                      const SizedBox(width: 16),
                      _buildFeature(
                        Icons.bathtub_outlined,
                        '${property.banos} Baños',
                      ),
                      const SizedBox(width: 16),
                      _buildFeature(
                        Icons.square_foot,
                        '${property.metrosCuadrados.toStringAsFixed(0)} m²',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildTogglePublishButton(
    BuildContext context,
    LandlordPropertiesProvider provider,
    Property property,
    bool isPublished,
  ) {
    return Tooltip(
      message: isPublished ? 'Pausar publicación' : 'Publicar propiedad',
      child: GestureDetector(
        onTap: provider.isLoading
            ? null
            : () => _confirmTogglePublication(context, provider, property),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isPublished
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : const Color(0xFF6B7280).withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isPublished
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  size: 22,
                  color: isPublished
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                ),
        ),
      ),
    );
  }

  Future<void> _confirmTogglePublication(
    BuildContext context,
    LandlordPropertiesProvider provider,
    Property property,
  ) async {
    final isPublished = property.publicado;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialogWidget(
        icon: isPublished
            ? Icons.stop_circle_outlined
            : Icons.play_circle_outline,
        title: isPublished ? 'Pausar Publicación' : 'Publicar Propiedad',
        content: isPublished
            ? '¿Deseas pausar la publicación de "${property.titulo}"? Dejará de aparecer en la plataforma.'
            : '¿Deseas publicar "${property.titulo}"? Será visible para todos los usuarios.',
        cancelText: 'Cancelar',
        acceptText: isPublished ? 'Pausar' : 'Publicar',
      ),
    );

    if (confirm == true && context.mounted) {
      if (!isPublished) {
        final applicationProvider = Provider.of<ApplicationProvider>(
          context,
          listen: false,
        );
        final hasAcceptedApplications =
            await applicationProvider.hasAcceptedApplicationsForProperty(
          property.id,
        );

        if (hasAcceptedApplications && context.mounted) {
          final confirmReactivate = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialogWidget(
              icon: Icons.warning_amber_rounded,
              title: 'Solicitudes aceptadas',
              content:
                  'La propiedad tiene solicitudes aceptadas. Al volver a publicarla se eliminarán todas las solicitudes asociadas a esta propiedad. ¿Deseas continuar?',
              cancelText: 'Cancelar',
              acceptText: 'Reactivar y limpiar solicitudes',
            ),
          );

          if (confirmReactivate != true) {
            return;
          }

          final deleted =
              await applicationProvider.deleteApplicationsForProperty(
            property.id,
          );
          if (!deleted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('No se pudieron limpiar las solicitudes asociadas.'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
            return;
          }
        }
      }

      final success = await provider.togglePropertyPublication(
        property.id,
        isPublished,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle_outline : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  success
                      ? (isPublished
                          ? 'Propiedad pausada exitosamente'
                          : 'Propiedad publicada exitosamente')
                      : (provider.errorMessage ?? 'Error al cambiar estado'),
                ),
              ],
            ),
            backgroundColor:
                success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  _confirmEditProperty(BuildContext context, Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialogWidget(
        icon: Icons.edit,
        title: 'Editar propiedad',
        content: '¿Deseas editar "${property.titulo}"?',
        cancelText: 'Cancelar',
        acceptText: 'Editar',
      ),
    );

    if (confirm == true && context.mounted) {
      context.push('/editar-propiedad', extra: property);
    }
  }

  Future<void> _confirmDeleteProperty(
      BuildContext context, Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialogWidget(
          icon: Icons.delete_outline,
          title: 'Eliminar propiedad',
          content:
              '¿Estás seguro de que deseas eliminar "${property.titulo}"? Esta acción no se puede deshacer.',
          cancelText: 'Cancelar',
          acceptText: 'Eliminar',
        );
      },
    );

    if (confirm == true && context.mounted) {
      final provider = Provider.of<LandlordPropertiesProvider>(
        context,
        listen: false,
      );
      final success = await provider.deleteProperty(property.id);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propiedad eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Error al eliminar la propiedad',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: disabledColor)),
      ],
    );
  }
}
