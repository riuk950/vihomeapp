import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/pages/tenant/widgets/application_card_tenant.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_empty_state.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_filter_bar.dart';

/// Pantalla principal de consulta y seguimiento de Solicitudes de Arriendo para el Arrendatario.
/// (RF-18.1, RF-18.3, RF-19, RF-20.1, RF-21, RF-22, QA 1.6, QA 1.14).
class SolicitudesArrendatarioPage extends StatefulWidget {
  const SolicitudesArrendatarioPage({super.key});

  @override
  State<SolicitudesArrendatarioPage> createState() =>
      _SolicitudesArrendatarioPageState();
}

class _SolicitudesArrendatarioPageState
    extends State<SolicitudesArrendatarioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider?>(context, listen: false);
      final appProvider =
          Provider.of<ApplicationProvider>(context, listen: false);
      if (authProvider != null && authProvider.user != null) {
        appProvider.fetchTenantApplications(authProvider.user!.id);
      }
    });
  }

  Future<void> _handleRefresh(ApplicationProvider provider) async {
    final authProvider = Provider.of<AuthProvider?>(context, listen: false);
    final userId = authProvider?.user?.id ??
        (provider.applications.isNotEmpty
            ? provider.applications.first.arrendatarioId
            : '');
    if (userId.isNotEmpty) {
      await provider.fetchTenantApplications(userId);
    }

    if (mounted && provider.refreshErrorMessage != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.refreshErrorMessage!),
          backgroundColor: Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.clearRefreshError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mis Solicitudes',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, _) {
          // Carga inicial sin datos previos
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Error en carga inicial bloqueante cuando no hay datos
          if (provider.errorMessage != null && provider.applications.isEmpty) {
            final authProvider =
                Provider.of<AuthProvider?>(context, listen: false);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 54, color: disabledColor),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudieron cargar tus solicitudes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style:
                          const TextStyle(color: disabledColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (authProvider != null && authProvider.user != null) {
                          provider
                              .fetchTenantApplications(authProvider.user!.id);
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Barra de filtros segmentada con badges dinámicos (RF-21.1, QA 1.17)
              SolicitudesFilterBar(
                currentFilter: provider.currentFilter,
                onFilterSelected: (filter) => provider.setFilter(filter),
                totalCount: provider.totalCount,
                pendingCount: provider.pendingCount,
                acceptedCount: provider.acceptedCount,
                rejectedCount: provider.rejectedCount,
              ),

              // Contenido con Pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () => _handleRefresh(provider),
                  child: _buildBodyContent(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(
      BuildContext context, ApplicationProvider provider) {
    // Estado vacío general: sin solicitudes registradas (RF-22.1)
    if (provider.applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: SolicitudesEmptyState.tenant(
              onExplore: () {
                try {
                  context.go('/home');
                } catch (_) {
                  context.pop();
                }
              },
            ),
          ),
        ],
      );
    }

    // Estado vacío por filtro activo sin resultados (RF-22.2)
    if (provider.filteredApplications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: SolicitudesEmptyState.filtered(
              filterName: provider.currentFilter,
              onClearFilter: () => provider.setFilter('Todas'),
            ),
          ),
        ],
      );
    }

    // Lista de tarjetas de alta densidad del inquilino con paso siguiente
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: provider.filteredApplications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
      itemBuilder: (context, index) {
        final application = provider.filteredApplications[index];
        return ApplicationCardTenant(
          application: application,
        );
      },
    );
  }
}
