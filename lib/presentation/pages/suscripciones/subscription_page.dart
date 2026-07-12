import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedPlanIndex =
      1; // Por defecto seleccionado el de 6 Meses (Popular)
  bool _hasRedirected = false; // Evita bucles de redirección si ya es Premium

  SubscriptionProvider? _subscriptionProvider;

  @override
  void initState() {
    super.initState();
    // Registrar callback: cuando la compra se confirme, recargar el usuario
    // para que isPremium=true se refleje en toda la app (quita anuncios, etc.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _subscriptionProvider?.onPurchaseSuccess = () async {
        await authProvider.reloadUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '¡Suscripción Premium activada! Los anuncios han sido eliminados.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          _safePop();
        }
      };
    });
  }

  @override
  void dispose() {
    // Limpiar el callback al salir de la página usando la referencia guardada
    _subscriptionProvider?.onPurchaseSuccess = null;
    super.dispose();
  }

  final List<Map<String, dynamic>> _mockPlans = [
    {
      'id': SubscriptionProvider.monthlySubscriptionId,
      'title': 'Mensual',
      'price': '\$19,900 COP',
      'period': '/mes',
      'badge': null,
      'badgeColor': null,
      'savings': null,
      'features': [
        'Sin anuncios molestos',
        'Publica hasta 3 propiedades',
        'Soporte estándar',
      ],
    },
    {
      'id': SubscriptionProvider.sixMonthSubscriptionId,
      'title': '6 Meses',
      'price': '\$89,900 COP',
      'period': '/semestre',
      'badge': 'MÁS POPULAR',
      'badgeColor': const Color(0xFF005DFF),
      'savings': 'AHORRA 25%',
      'features': [
        'Sin anuncios molestos',
        'Publicaciones destacadas',
        'Publica propiedades ilimitadas',
        'Soporte prioritario 24/7',
      ],
    },
    {
      'id': SubscriptionProvider.yearlySubscriptionId,
      'title': 'Anual',
      'price': '\$149,900 COP',
      'period': '/año',
      'badge': 'MEJOR VALOR',
      'badgeColor': const Color(0xFF10B981),
      'savings': 'AHORRA 37%',
      'features': [
        'Todo lo de Premium',
        'Estadísticas avanzadas de visitas',
        'Destacado platino en búsquedas',
        'Acceso anticipado a proyectos',
      ],
    },
  ];

  /// Navega atrás de forma segura compatible con go_router
  void _safePop() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await provider.purchaseProduct(product);

    if (!mounted) return;

    if (!success && provider.errorMessage != null) {
      _showErrorDialog(provider.errorMessage!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error de Compra'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }

  Future<void> _restorePurchases() async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await provider.restorePurchases();

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restauración Iniciada'),
          content: const Text(
              'Se ha solicitado la restauración de tus compras. Si hay suscripciones activas, se actualizarán en breve.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  /// Simula una compra exitosa cuando no hay productos reales en la tienda (útil para CI/CD)
  Future<void> _simulatePurchase(String planId) async {
    await _runSimulatedPurchase(planId, label: 'Modo Simulado');
  }

  /// Fuerza la simulación de compra aunque haya productos reales (solo modo DEV)
  Future<void> _simulatePurchaseDev(String planId) async {
    await _runSimulatedPurchase(planId,
        label: 'Modo DEV - Play Console Tester');
  }

  /// Lógica común de simulación de compra
  Future<void> _runSimulatedPurchase(String planId,
      {required String label}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    // Mostrar loading dialog local controlado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.delayed(const Duration(seconds: 2));

      await Supabase.instance.client
          .from('profiles')
          .update({'is_premium': true}).eq('id', user.id);

      await authProvider.reloadUser();

      if (!mounted) return;
      Navigator.of(context)
          .pop(); // Quitar loading dialog utilizando el contexto principal seguro

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Suscripción Premium activada! ($label)'),
          backgroundColor: Colors.green,
        ),
      );
      _safePop();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Quitar loading dialog
        _showErrorDialog('Error al simular la suscripción: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // FIX: Manejo limpio de usuario que ya posee suscripción Premium activa
    if (authProvider.user?.isPremium == true && !_hasRedirected) {
      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Ya tienes una suscripción Premium activa!'),
              backgroundColor: Colors.blue,
            ),
          );
          _safePop();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: _safePop,
        ),
        title: const Text(
          'Suscripciones',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (EnvDef.isDevelopment)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: subProvider.products.isNotEmpty
                        ? Colors.green.shade50
                        : Colors.amber.shade100,
                    child: Row(
                      children: [
                        Icon(
                          subProvider.products.isNotEmpty
                              ? Icons.store
                              : Icons.developer_mode,
                          size: 16,
                          color: subProvider.products.isNotEmpty
                              ? Colors.green.shade700
                              : Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subProvider.products.isNotEmpty
                                ? 'SANDBOX OK — ${subProvider.products.length} producto(s) cargados desde Play Store'
                                : 'MODO DEV — Sin productos reales. Verifica License Tester en Play Console.',
                            style: TextStyle(
                              fontSize: 11,
                              color: subProvider.products.isNotEmpty
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.diamond_outlined,
                                          color: primaryColor, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'VIHOME Premium',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Elimina anuncios y obtén acceso prioritario hoy mismo.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _mockPlans.length,
                              itemBuilder: (context, index) {
                                final plan = _mockPlans[index];
                                final isSelected = _selectedPlanIndex == index;

                                ProductDetails? realProduct;
                                try {
                                  realProduct = subProvider.products.firstWhere(
                                    (p) => p.id == plan['id'],
                                  );
                                } catch (_) {
                                  realProduct = null;
                                }

                                final displayPrice = realProduct != null
                                    ? realProduct.price
                                    : plan['price'];
                                final displayPeriod =
                                    realProduct != null ? '' : plan['period'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPlanIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 250,
                                    margin: EdgeInsets.only(
                                      left: index == 0 ? 0 : 8,
                                      right: index == _mockPlans.length - 1
                                          ? 0
                                          : 8,
                                      bottom: 16,
                                      top: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? primaryColor.withValues(
                                                  alpha: 0.1)
                                              : Colors.black
                                                  .withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 16 : 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        if (plan['badge'] != null)
                                          Positioned(
                                            top: -12,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: plan['badgeColor'],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  plan['badge'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plan['title'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? primaryColor
                                                      : Colors.grey.shade800,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    displayPrice,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    displayPeriod,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (plan['savings'] != null)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    plan['savings'],
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 12),
                                              const Divider(height: 1),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      (plan['features'] as List)
                                                          .length,
                                                  itemBuilder:
                                                      (context, fIndex) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 6.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.check_circle,
                                                            color: isSelected
                                                                ? primaryColor
                                                                : Colors.grey
                                                                    .shade400,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Expanded(
                                                            child: Text(
                                                              plan['features']
                                                                  [fIndex],
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: primaryColor,
                                                    width: 2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (EnvDef.isDevelopment) ...[
                        OutlinedButton.icon(
                          onPressed: subProvider.isLoading
                              ? null
                              : () {
                                  final selectedPlan =
                                      _mockPlans[_selectedPlanIndex];
                                  _simulatePurchaseDev(selectedPlan['id']);
                                },
                          icon: const Icon(Icons.developer_mode, size: 16),
                          label: const Text('Forzar Activación (DEV/CI)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.amber.shade800,
                            side: BorderSide(color: Colors.amber.shade600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ElevatedButton(
                        onPressed: subProvider.isLoading
                            ? null
                            : () {
                                final selectedPlan =
                                    _mockPlans[_selectedPlanIndex];

                                ProductDetails? realProduct;
                                try {
                                  realProduct = subProvider.products.firstWhere(
                                    (p) => p.id == selectedPlan['id'],
                                  );
                                } catch (_) {
                                  realProduct = null;
                                }

                                if (realProduct != null) {
                                  _purchaseProduct(realProduct);
                                } else {
                                  _simulatePurchase(selectedPlan['id']);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Suscribirse Ahora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: subProvider.isLoading ? null : _restorePurchases,
                        child: const Text(
                          'Restaurar Compras',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (subProvider.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
