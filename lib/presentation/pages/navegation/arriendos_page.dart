import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../../providers/property_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/property.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArriendosPage extends StatefulWidget {
  const ArriendosPage({super.key});

  @override
  State<ArriendosPage> createState() => _ArriendosPageState();
}

class _ArriendosPageState extends State<ArriendosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawerScrimColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Arriendos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        shadowColor: backgroundColor,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black),
            onPressed: () {
              context.push('/mapa');
            },
          ),
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
                offset: const Offset(-4, 4), // Mueve el badge más cerca del icono
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black),
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
      body: Column(
        children: [
          // Search Bar
          /* Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar dirección, ciudad...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ), */
          const SizedBox(height: 10),

          // Filters
          SizedBox(
            height: 50,
            child: Consumer<PropertyProvider>(
              builder: (context, provider, child) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(
                      'Todas',
                      provider.selectedType == null,
                      () => provider.selectType(null),
                    ),
                    ...provider.propertyTypes.map(
                      (type) => _buildFilterChip(
                        type.nombre,
                        provider.selectedType == type,
                        () => provider.selectType(type),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Property List
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, propertyProvider, child) {
                final arriendosProperties = propertyProvider.properties
                    .where((p) => p.estado == 'arriendo')
                    .toList();

                if (propertyProvider.isLoading &&
                    propertyProvider.propertyTypes.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (propertyProvider.errorMessage != null) {
                  return Center(child: Text(propertyProvider.errorMessage!));
                }

                if (arriendosProperties.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron propiedades'));
                }

                return RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: backgroundColor,
                  onRefresh: () async {
                    propertyProvider.fetchProperties();
                    propertyProvider.fetchPropertyTypes();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: arriendosProperties.length,
                    itemBuilder: (context, index) {
                      final property = arriendosProperties[index];
                      return _buildPropertyCard(context, property);
                    },
                  ),
                );
              },
            ),
          ),
        ],
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

  Widget _buildPropertyCard(BuildContext context, Property property) {
    // Updated signature
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        // Added InkWell
        onTap: () {
          context.push(
            '/property-details',
            extra: property,
          ); // Added onTap navigation
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ImageCarousel
            SizedBox(
              height: 180,
              width: double.infinity,
              child: property.fotos.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.home, size: 50, color: Colors.grey),
                      ),
                    )
                  : Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: property.fotos.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                            color: primaryColor,
                          )),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.titulo,
                    style: const TextStyle(
                      fontSize: 18,
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
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.direccion,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
