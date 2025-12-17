import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';

class CrearPropiedadPage extends StatefulWidget {
  const CrearPropiedadPage({super.key});

  @override
  State<CrearPropiedadPage> createState() => _CrearPropiedadPageState();
}

class _CrearPropiedadPageState extends State<CrearPropiedadPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _tituloController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioRentaController = TextEditingController();
  final _habitacionesController = TextEditingController();
  final _banosController = TextEditingController();
  final _metrosCuadradosController = TextEditingController();

  String _tipoPropiedad = 'Casa';
  bool _publicado = true;

  final List<String> _tiposPropiedad = [
    'Casa',
    'Apartamento',
    'Oficina',
    'Local',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _descripcionController.dispose();
    _precioRentaController.dispose();
    _habitacionesController.dispose();
    _banosController.dispose();
    _metrosCuadradosController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final landlordProvider = Provider.of<LandlordPropertiesProvider>(
        context,
        listen: false,
      );

      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
        return;
      }

      final propertyData = {
        'arrendador_id': authProvider.user!.id,
        'tipo_propiedad': _tipoPropiedad,
        'titulo': _tituloController.text,
        'direccion': _direccionController.text,
        'ciudad': _ciudadController.text,
        'descripcion': _descripcionController.text,
        'precio': 0, // Por defecto si es solo renta
        'precio_renta': double.tryParse(_precioRentaController.text) ?? 0,
        'habitaciones': int.tryParse(_habitacionesController.text) ?? 0,
        'banos': int.tryParse(_banosController.text) ?? 0,
        'metros_cuadrados':
            double.tryParse(_metrosCuadradosController.text) ?? 0,
        'lat': 0.0, // Placeholder
        'lng': 0.0, // Placeholder
        'publicado': _publicado,
      };

      final success = await landlordProvider.createProperty(propertyData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propiedad creada exitosamente')),
          );
          context.pop(); // Volver a la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                landlordProvider.errorMessage ?? 'Error al crear propiedad',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111418)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Nueva Propiedad',
          style: TextStyle(
            color: Color(0xFF111418),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<LandlordPropertiesProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Información General'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _tituloController,
                        label: 'Título',
                        hint: 'Ej: Hermosa casa en el centro',
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Tipo de Propiedad',
                              value: _tipoPropiedad,
                              items: _tiposPropiedad,
                              onChanged: (v) =>
                                  setState(() => _tipoPropiedad = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _ciudadController,
                              label: 'Ciudad',
                              hint: 'Ej: Bogotá',
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _direccionController,
                        label: 'Dirección',
                        hint: 'Ej: Carrera 7 # 12-34',
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        hint: 'Describe las características principales...',
                        maxLines: 3,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Requerido' : null,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Detalles y Precio'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _precioRentaController,
                        label: 'Precio de Renta (COP)',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        prefixText: '\$ ',
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _habitacionesController,
                              label: 'Habitaciones',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _banosController,
                              label: 'Baños',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _metrosCuadradosController,
                        label: 'Metros Cuadrados',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        suffixText: 'm²',
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Requerido' : null,
                      ),

                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Publicar Propiedad',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Hacer visible para todos los usuarios',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _publicado,
                              onChanged: (v) => setState(() => _publicado = v),
                              activeTrackColor: const Color(0xFF137FEC),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF137FEC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Crear Propiedad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111418),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? prefixText,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111418),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: prefixText,
            suffixText: suffixText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137FEC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111418),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137FEC)),
            ),
          ),
        ),
      ],
    );
  }
}
