import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vihomeapp/presentation/widgets/ad_banner_widget.dart';
import '../../providers/project_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/project.dart';
import 'package:go_router/go_router.dart';

class ProyectosPage extends StatefulWidget {
  const ProyectosPage({super.key});

  @override
  State<ProyectosPage> createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  static const List<String?> _filters = [
    null,
    'Sobre Planos',
    'En Construcción',
    'Entrega Inmediata',
  ];

  static const List<String> _filterLabels = [
    'Todos',
    'Sobre Planos',
    'En Construcción',
    'Entrega Inmediata',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawerScrimColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Proyectos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        shadowColor: backgroundColor,
        centerTitle: false,
        actions: [
          Consumer<ApplicationProvider>(
            builder: (context, appProvider, child) {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final user = authProvider.user;
              int notificationCount = 0;
              if (user != null) {
                notificationCount = user.role == 'arrendador'
                    ? appProvider.unreadLandlordCount
                    : appProvider.unreadTenantCount;
              }

              return Badge(
                label: Text(
                  notificationCount.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                isLabelVisible: notificationCount > 0,
                backgroundColor: Colors.redAccent,
                offset: const Offset(-4, 4),
                child: IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () {
                    if (user != null) {
                      if (user.role == 'arrendador') {
                        context.push('/notifications_landlord');
                      } else {
                        context.push('/notifications_tenant');
                      }
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Filtros de estado
            SizedBox(
              height: 50,
              child: Consumer<ProjectProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final isSelected =
                          provider.selectedFilter == _filters[index];
                      return _buildFilterChip(
                        _filterLabels[index],
                        isSelected,
                        () => provider.selectFilter(_filters[index]),
                      );
                    },
                  );
                },
              ),
            ),

            // Lista de proyectos
            Expanded(
              child: Consumer<ProjectProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  final projects = provider.filteredProjects;

                  if (projects.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron proyectos'),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    backgroundColor: backgroundColor,
                    onRefresh: () async {
                      provider.fetchProjects();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        return _buildProjectCard(context, projects[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          backgroundColor: isSelected ? primaryColor : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          context.push('/proyecto-detalle', extra: project);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen placeholder con badge de estado
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: disabledColor,
                  ),
                  child: project.fotos.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: project.fotos.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: disabledColor,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.apartment,
                            size: 60,
                            color: disabledColor,
                          ),
                        ),
                ),
                // Badge de estado
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(project.estado),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      project.estado,
                      style: const TextStyle(
                        color: backgroundColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.tipoPropiedad,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    project.ubicacionPrincipal,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Desde',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatCurrency(project.precioDesde),
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: backgroundColor),
                  const SizedBox(height: 12),

                  // Features y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildFeature(
                            Icons.bed_outlined,
                            '${project.habitaciones} Hab',
                          ),
                          const SizedBox(width: 16),
                          _buildFeature(
                            Icons.straighten,
                            '${project.area.toStringAsFixed(0)} m²',
                          ),
                          if (project.financiacion) ...[
                            const SizedBox(width: 16),
                            _buildFeature(
                              Icons.payments_outlined,
                              'Financiación',
                            ),
                          ],
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/proyecto-detalle', extra: project);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Ver Detalles',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    final normEstado = estado.toLowerCase().trim();
    if (normEstado.contains('construccion') ||
        normEstado.contains('construcción')) {
      return primaryColor;
    }
    if (normEstado.contains('entrega inmediata')) {
      return const Color(0xFF10B981); // emerald-500
    }
    if (normEstado.contains('sobre planos')) {
      return const Color(0xFF6366F1); // indigo
    }
    return const Color(0xFF6366F1); // default indigo
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }
}
