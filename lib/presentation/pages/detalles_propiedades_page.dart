import 'package:flutter/material.dart';
import '../../domain/entities/property.dart';

class DetallesPropiedadesPage extends StatelessWidget {
  final Property property;

  const DetallesPropiedadesPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detalles de la Propiedad'),
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
              // App Bar & Image
              // Image Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      PageView(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.home,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Gradient Overlay
                      Container(
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
                      // Favorite Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Address
                      Text(
                        property.titulo,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B), // Slate 900
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.direccion,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF475569), // Slate 600
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${property.precioRenta.toStringAsFixed(0)} COP/mes',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF137FEC), // Primary Blue
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Key Features
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureItem(
                            Icons.bed_outlined,
                            '${property.habitaciones} Hab',
                          ),
                          _buildFeatureItem(
                            Icons.bathtub_outlined,
                            '${property.banos} Baños',
                          ),
                          _buildFeatureItem(
                            Icons.square_foot,
                            '${property.metrosCuadrados.toStringAsFixed(0)} m²',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.descripcion.isNotEmpty
                            ? property.descripcion
                            : 'Disfruta de la vida de lujo en este espectacular inmueble. Con acabados modernos, amplios espacios y una ubicación inmejorable. Ideal para quienes buscan comodidad y estilo.',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF475569),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Amenities
                      const Text(
                        'Amenidades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
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
                          _buildAmenityItem(
                            Icons.local_parking,
                            'Estacionamiento',
                          ),
                          _buildAmenityItem(Icons.pets, 'Mascotas'),
                          _buildAmenityItem(Icons.balcony, 'Balcón'),
                          _buildAmenityItem(Icons.security, 'Seguridad 24/7'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Landlord Profile
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=11',
                              ), // Mock Image
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Publicado por Juan Pérez',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Propietario',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.blue),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF137FEC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Contactar',
                        style: TextStyle(
                          color: Color(0xFF137FEC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF137FEC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Solicitar Arriendo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey[700], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF137FEC), size: 20),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
