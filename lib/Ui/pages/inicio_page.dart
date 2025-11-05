import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

enum OpcionSeleccionada { venta, arriendo, proyectos, ninguna }

class _InicioPageState extends State<InicioPage> {
  OpcionSeleccionada _opcionSeleccionada = OpcionSeleccionada.ninguna;
  bool _isVentaPressed = false;
  bool _isArriendoPressed = false;
  bool _isProyectosPressed = false;
  String? _tipoSeleccionado;
  String? _ciudadSeleccionada;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.40;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: appBarHeight,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/diseno-interior.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encuentra la casa de tus sueños',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedButton(
                          label: 'Venta',
                          icon: Icons.shopping_bag,
                          isPressed: _isVentaPressed,
                          isSelected: _opcionSeleccionada == OpcionSeleccionada.venta,
                          onPressed: () {
                            setState(() {
                              _opcionSeleccionada = _opcionSeleccionada == OpcionSeleccionada.venta
                                  ? OpcionSeleccionada.ninguna
                                  : OpcionSeleccionada.venta;
                            });
                            // Aquí puedes agregar la navegación o acción
                          },
                          onPressedDown: () {
                            setState(() => _isVentaPressed = true);
                          },
                          onPressedUp: () {
                            setState(() => _isVentaPressed = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnimatedButton(
                          label: 'Arriendo',
                          icon: Icons.key,
                          isPressed: _isArriendoPressed,
                          isSelected: _opcionSeleccionada == OpcionSeleccionada.arriendo,
                          onPressed: () {
                            setState(() {
                              _opcionSeleccionada = _opcionSeleccionada == OpcionSeleccionada.arriendo
                                  ? OpcionSeleccionada.ninguna
                                  : OpcionSeleccionada.arriendo;
                            });
                            // Aquí puedes agregar la navegación o acción
                          },
                          onPressedDown: () {
                            setState(() => _isArriendoPressed = true);
                          },
                          onPressedUp: () {
                            setState(() => _isArriendoPressed = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnimatedButton(
                          label: 'Proyectos',
                          icon: Icons.apartment,
                          isPressed: _isProyectosPressed,
                          isSelected: _opcionSeleccionada == OpcionSeleccionada.proyectos,
                          onPressed: () {
                            setState(() {
                              _opcionSeleccionada = _opcionSeleccionada == OpcionSeleccionada.proyectos
                                  ? OpcionSeleccionada.ninguna
                                  : OpcionSeleccionada.proyectos;
                            });
                            // Aquí puedes agregar la navegación o acción
                          },
                          onPressedDown: () {
                            setState(() => _isProyectosPressed = true);
                          },
                          onPressedUp: () {
                            setState(() => _isProyectosPressed = false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showTipoInmuebleSelector,
                    icon: const Icon(Icons.home_work),
                    label: Text(_tipoSeleccionado ?? 'Seleccionar tipo de inmueble'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showCiudadSelector,
                    icon: const Icon(Icons.location_city),
                    label: Text(_ciudadSeleccionada ?? 'Seleccionar ciudad'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      final String tipo = _tipoSeleccionado ?? 'No definido';
                      final String ciudad = _ciudadSeleccionada ?? 'No definida';
                      final String modo = _opcionSeleccionada.toString().split('.').last;
                      // Imprimir en consola la selección actual
                      // Ejemplo: Buscar -> tipo: Casa, ciudad: Duitama, modo: venta
                      // ignore: avoid_print
                      print('Buscar -> tipo: ' + tipo + ', ciudad: ' + ciudad + ', modo: ' + modo);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required IconData icon,
    required bool isPressed,
    required bool isSelected,
    required VoidCallback onPressed,
    required VoidCallback onPressedDown,
    required VoidCallback onPressedUp,
  }) {
    final color = isSelected ? Colors.green : Colors.grey;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isPressed ? 4.0 : 0.0, 0.0, 1.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          onTapDown: (_) => onPressedDown(),
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) onPressedUp();
            });
          },
          onTapCancel: onPressedUp,
          borderRadius: BorderRadius.circular(16),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isSelected ? 0.5 : 0.3),
                  blurRadius: isPressed ? 8 : (isSelected ? 16 : 12),
                  offset: Offset(0, isPressed ? 2 : (isSelected ? 4 : 6)),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTipoInmuebleSelector() {
    final List<String> tiposBase = <String>[
      'Casa',
      'Apartamento',
      'Oficina',
      'Local',
      'Bodega',
      'Terreno',
      'Finca',
      'Estudio',
      'Dúplex',
      'Loft',
      'Casa campestre',
      'Penthouse',
      'Habitación',
    ];

    // Crear una copia y mezclar para obtener elementos al azar
    final List<String> tiposAleatorios = List<String>.from(tiposBase)..shuffle();
    // Tomar entre 6 y 8 elementos aleatorios según disponibilidad
    final int cantidad = tiposAleatorios.length >= 8 ? 8 : (tiposAleatorios.length >= 6 ? 6 : tiposAleatorios.length);
    final List<String> mostrar = tiposAleatorios.take(cantidad).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tipos de inmueble',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: mostrar.length,
                    itemBuilder: (context, index) {
                      final String tipo = mostrar[index];
                      return ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(tipo),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _tipoSeleccionado = tipo;
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCiudadSelector() {
    final List<String> ciudades = <String>[
      'Duitama',
      'Sogamoso',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selecciona la ciudad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: ciudades.length,
                    itemBuilder: (context, index) {
                      final String ciudad = ciudades[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(ciudad),
                        trailing: _ciudadSeleccionada == ciudad
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _ciudadSeleccionada = ciudad;
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

