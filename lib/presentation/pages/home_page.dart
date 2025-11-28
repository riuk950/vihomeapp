import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'buscar_page.dart';
import 'favoritos_page.dart';
import 'consultas_page.dart';
import 'perfil_page.dart';
import 'panel_page.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isLandlord = user?.role == 'arrendador';

    final List<Widget> pages = [
      const BuscarPage(),
      const FavoritosPage(),
      const ConsultasPage(),
      isLandlord ? const PanelPage() : const PerfilPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Buscar',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.edit_document),
                label: 'Contratos',
              ),
              BottomNavigationBarItem(
                icon: Icon(isLandlord ? Icons.dashboard : Icons.person),
                label: isLandlord ? 'Panel' : 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
