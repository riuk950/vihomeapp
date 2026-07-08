import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Ya no necesitamos _fetchPackages porque el provider lo hace al inicializar
  // y podemos usar provider.products directamente.

  Future<void> _purchaseProduct(ProductDetails product) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await provider.purchaseProduct(product);
    
    if (!mounted) return;
    
    if (success) {
      // La confirmación real vendrá del listener en el provider que actualiza _isSubscribed
      // Podemos mostrar un mensaje de que se inició el proceso o esperar al cambio de estado.
    } else if (provider.errorMessage != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de Compra'),
          content: Text(provider.errorMessage!),
          actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(),
               child: const Text('Cerrar'),
             )
          ],
        ),
      );
    }
  }

  Future<void> _restorePurchases() async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await provider.restorePurchases();
    
    if (!mounted) return;
    
    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Proceso Iniciado'),
          content: const Text('Se ha solicitado la restauración de tus compras. Si hay suscripciones activas, se actualizarán en breve.'),
          actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(),
               child: const Text('OK'),
             )
          ],
        ),
      ).then((_) {
        // if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);

    // Escuchar cambios en la suscripción para cerrar la página si ya es premium
    if (provider.isSubscribed) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Ya eres Premium!')),
            );
            Navigator.of(context).pop();
         }
       });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Hazte Premium', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 100,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Desbloquea todo el potencial de ViHome',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureRow(Icons.add_home_work_outlined, 'Publica propiedades ilimitadas'),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.block_outlined, 'Navegación libre de anuncios'),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.insights_outlined, 'Estadísticas detalladas (Próximamente)'),
                  const SizedBox(height: 40),
                  
                  if (provider.isLoading && provider.products.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.products.isEmpty)
                    const Center(
                      child: Text(
                        'No hay suscripciones disponibles en este momento.\nAsegúrate de que los IDs de producto estén configurados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...provider.products.map((product) => _buildProductCard(product)),
                    
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _restorePurchases,
                    child: const Text(
                      'Restaurar Compras',
                      style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (provider.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _purchaseProduct(product),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                product.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

