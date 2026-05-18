import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'package:vihomeapp/presentation/widgets/alert_dialog.dart';
import '../providers/tenant_provider.dart';
import '../providers/landlord_provider.dart';
import '../providers/application_provider.dart';

class BtnLogout extends StatelessWidget {
  const BtnLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _handleLogout(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.logout),
      label: const Text(
        'Cerrar Sesión',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AlertDialogWidget(
        icon: Icons.logout,
        title: 'Cerrar Sesión',
        content: '¿Estás seguro de que quieres cerrar sesión?',
        cancelText: 'Cancelar',
        acceptText: 'Cerrar Sesión',
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
      final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Error al cerrar sesión en Supabase: $e');
      }

      // Limpiar el estado local de los demás Providers para la próxima sesión
      tenantProvider.clear();
      landlordProvider.clear();
      appProvider.clear();

      await authProvider.signOut();
      
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
