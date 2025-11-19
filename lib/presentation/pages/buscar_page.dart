import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';

class BuscarPage extends StatelessWidget {
  const BuscarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propiedades'),
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (propertyProvider.errorMessage != null) {
            return Center(
              child: Text(propertyProvider.errorMessage!),
            );
          }

          if (propertyProvider.properties.isEmpty) {
            return const Center(
              child: Text('No se encontraron propiedades'),
            );
          }

          return ListView.builder(
            itemCount: propertyProvider.properties.length,
            itemBuilder: (context, index) {
              final property = propertyProvider.properties[index];
              return Card(
                child: ListTile(
                  title: Text(property.titulo),
                  subtitle: Text(property.direccion),
                  onTap: () {
                    // TODO: Navigate to property details page
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}