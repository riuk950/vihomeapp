import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/data/models/amenidad_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';

class EditarPropiedadesPage extends StatefulWidget {
  final Property property;

  const EditarPropiedadesPage({super.key, required this.property});

  @override
  State<EditarPropiedadesPage> createState() => _EditarPropiedadesPageState();
}

class _EditarPropiedadesPageState extends State<EditarPropiedadesPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _tituloController;
  late final TextEditingController _direccionController;
  late final TextEditingController _ciudadController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioRentaController;
  late final TextEditingController _precioVentaController;
  late final TextEditingController _habitacionesController;
  late final TextEditingController _banosController;
  late final TextEditingController _metrosCuadradosController;

  String? _tipoPropiedad;
  late String _estado;
  late bool _publicado;
  double? _lat;
  double? _lng;
  final List<File> _selectedNewImages = [];
  late List<String> _existingImages;
  bool _isUploadingImages = false;

  List<String> _tiposPropiedad = [];
  bool _isLoadingTipos = true;

  List<AmenidadModel> _amenidades = [];
  bool _isLoadingAmenidades = true;
  final List<String> _amenidadesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.property.titulo);
    _direccionController = TextEditingController(text: widget.property.direccion);
    _ciudadController = TextEditingController(text: widget.property.ciudad);
    _descripcionController = TextEditingController(text: widget.property.descripcion);
    _precioRentaController = TextEditingController(
      text: widget.property.precioRenta != null
          ? _formatCurrency(widget.property.precioRenta!)
          : '',
    );
    _precioVentaController = TextEditingController(
      text: widget.property.precioVenta != null
          ? _formatCurrency(widget.property.precioVenta!)
          : '',
    );
    _habitacionesController = TextEditingController(text: widget.property.habitaciones.toString());
    _banosController = TextEditingController(text: widget.property.banos.toString());
    _metrosCuadradosController = TextEditingController(
      text: widget.property.metrosCuadrados.toString(),
    );

    _tipoPropiedad = widget.property.tipoPropiedad;
    _estado = widget.property.estado;
    _publicado = widget.property.publicado;
    _lat = widget.property.lat;
    _lng = widget.property.lng;
    _existingImages = List<String>.from(widget.property.fotos);

    // Extract existing amenity IDs
    if (widget.property.amenidades != null) {
      for (var a in widget.property.amenidades!) {
        if (a is Map) {
          final id = a['id_amenidad'] ?? a['idAmenidad'];
          if (id != null) {
            _amenidadesSeleccionadas.add(id.toString());
          }
        } else if (a is String) {
          _amenidadesSeleccionadas.add(a);
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandlordPropertiesProvider>(context, listen: false)
          .clearError();
    });
    _cargarTiposPropiedad();
    _cargarAmenidades();
  }

  Future<void> _cargarAmenidades() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('amenidades').select('*');
      if (mounted) {
        setState(() {
          _amenidades = (response as List)
              .map((e) => AmenidadModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoadingAmenidades = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading amenidades: $e');
      if (mounted) {
        setState(() {
          _isLoadingAmenidades = false;
        });
      }
    }
  }

  Future<void> _cargarTiposPropiedad() async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from('tipos_propiedad').select('propiedad');
      if (mounted) {
        setState(() {
          _tiposPropiedad = (response as List)
              .map((e) => e['propiedad']?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
          
          if (_tiposPropiedad.contains(widget.property.tipoPropiedad)) {
            _tipoPropiedad = widget.property.tipoPropiedad;
          } else if (_tiposPropiedad.isNotEmpty) {
            _tipoPropiedad = _tiposPropiedad.first;
          }
          _isLoadingTipos = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading property types: $e');
      if (mounted) {
        setState(() {
          _isLoadingTipos = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _descripcionController.dispose();
    _precioRentaController.dispose();
    _precioVentaController.dispose();
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

      setState(() => _isUploadingImages = true);
      List<String> photoUrls = List<String>.from(_existingImages);

      try {
        if (_selectedNewImages.isNotEmpty) {
          final supabase = Supabase.instance.client;
          for (var image in _selectedNewImages) {
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
            final path = 'propiedades/$fileName';

            await supabase.storage.from('propiedades-fotos').upload(
                  path,
                  image,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );

            final String publicUrl =
                supabase.storage.from('propiedades-fotos').getPublicUrl(path);

            photoUrls.add(publicUrl);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imágenes: $e')),
          );
          setState(() => _isUploadingImages = false);
          return;
        }
      }

      final propertyData = {
        'tipo_propiedad': _tipoPropiedad ?? '',
        'titulo': _tituloController.text,
        'direccion': _direccionController.text,
        'ciudad': _ciudadController.text,
        'descripcion': _descripcionController.text,
        'precio': 0,
        'precio_renta': _estado == 'arriendo' && _precioRentaController.text.isNotEmpty
            ? double.tryParse(_precioRentaController.text.replaceAll(RegExp(r'\D'), ''))
            : null,
        'precio_venta': _estado == 'venta' && _precioVentaController.text.isNotEmpty
            ? double.tryParse(_precioVentaController.text.replaceAll(RegExp(r'\D'), ''))
            : null,
        'habitaciones': int.tryParse(_habitacionesController.text) ?? 0,
        'banos': int.tryParse(_banosController.text) ?? 0,
        'metros_cuadrados':
            double.tryParse(_metrosCuadradosController.text) ?? 0,
        'lat': _lat ?? 0.0,
        'lng': _lng ?? 0.0,
        'publicado': _publicado,
        'estado': _estado,
        'fotos': photoUrls,
        'amenidades': _amenidades
            .where((a) => _amenidadesSeleccionadas.contains(a.idAmenidad))
            .map((a) => a.toJson())
            .toList(),
      };

      final success = await landlordProvider.updateProperty(widget.property.id, propertyData);

      if (mounted) {
        setState(() => _isUploadingImages = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propiedad actualizada exitosamente')),
          );
          context.pop(); // Volver a la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                landlordProvider.errorMessage ?? 'Error al actualizar propiedad',
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editar Propiedad',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<LandlordPropertiesProvider>(
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
                              child: _isLoadingTipos
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : _buildDropdown(
                                      label: 'Tipo de Propiedad',
                                      value: _tipoPropiedad,
                                      items: _tiposPropiedad,
                                      onChanged: (v) =>
                                          setState(() => _tipoPropiedad = v),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _ciudadController,
                                label: 'Ciudad',
                                hint: 'Ej: Sogamoso',
                                enabled: false,
                                validator: (v) =>
                                    v?.isEmpty ?? true ? 'Requerido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Estado',
                          value: _estado,
                          items: ['arriendo', 'venta'],
                          onChanged: (v) => setState(() => _estado = v!),
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
                        // Location Picker
                        _buildLocationPicker(),
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
                        _buildSectionTitle('Fotos de la Propiedad'),
                        const SizedBox(height: 16),
                        _buildImagePicker(),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Detalles y Precio'),
                        const SizedBox(height: 16),

                        if (_estado == 'arriendo')
                          _buildTextField(
                            controller: _precioRentaController,
                            label: 'Precio de Renta (COP)',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [_CurrencyInputFormatter()],
                          )
                        else
                          _buildTextField(
                            controller: _precioVentaController,
                            label: 'Precio de Venta (COP)',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [_CurrencyInputFormatter()],
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
                        _buildSectionTitle('Amenidades'),
                        const SizedBox(height: 16),
                        _buildAmenidadesSelector(),

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
                                onChanged: (v) =>
                                    setState(() => _publicado = v),
                                activeTrackColor: primaryColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                (provider.isLoading || _isUploadingImages)
                                    ? null
                                    : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading || _isUploadingImages)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
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
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
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
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
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
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
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
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final dynamic result = await context.pushNamed('location-picker');

            if (result != null && result is Point) {
              setState(() {
                _lat = result.coordinates.lat.toDouble();
                _lng = result.coordinates.lng.toDouble();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lat != null && _lng != null
                        ? 'Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}'
                        : 'Seleccionar en el mapa',
                    style: TextStyle(
                      color: _lat != null && _lng != null ? textColor : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_existingImages.isNotEmpty || _selectedNewImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                ..._selectedNewImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedNewImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        if (_existingImages.isNotEmpty || _selectedNewImages.isNotEmpty)
          const SizedBox(height: 16),
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: primaryColor,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Agregar Fotos',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'JPG, PNG (Max 5MB)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        final files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        setState(() {
          _selectedNewImages.addAll(files);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al seleccionar imágenes')),
        );
      }
    }
  }

  Widget _buildAmenidadesSelector() {
    if (_isLoadingAmenidades) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_amenidades.isEmpty) {
      return const Text(
        'No hay amenidades disponibles',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _amenidades.map((amenidad) {
        final isSelected =
            _amenidadesSeleccionadas.contains(amenidad.idAmenidad);
        IconData? iconData = _getAmenityIcon(amenidad.logo);

        return FilterChip(
          label: Text(amenidad.idAmenidad.trim()),
          avatar: Icon(
            iconData,
            size: 18,
            color: isSelected ? Colors.white : primaryColor,
          ),
          selected: isSelected,
          selectedColor: primaryColor,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : textColor,
          ),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _amenidadesSeleccionadas.add(amenidad.idAmenidad);
              } else {
                _amenidadesSeleccionadas.remove(amenidad.idAmenidad);
              }
            });
          },
        );
      }).toList(),
    );
  }

  IconData _getAmenityIcon(String name) {
    switch (name.trim().toLowerCase()) {
      case 'pool':
        return Icons.pool;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'security_outlined':
        return Icons.security_outlined;
      case 'park_outlined':
        return Icons.park_outlined;
      case 'local_parking_outlined':
        return Icons.local_parking_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      customPattern: '\$ #,##0',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final double value = double.tryParse(cleanText) ?? 0;
    final String formattedText = _EditarPropiedadesPageState._formatCurrency(value);

    int selectionEnd = newValue.selection.end;
    if (selectionEnd < 0) {
      selectionEnd = newValue.text.length;
    }

    final int digitsBeforeCursor = newValue.text
        .substring(0, selectionEnd)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    int selectionIndex = 0;
    int digitCount = 0;

    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor) {
        selectionIndex = i + 1;
        break;
      }
    }

    if (selectionIndex == 0) {
      if (digitsBeforeCursor == 0) {
        selectionIndex = formattedText.indexOf(RegExp(r'\d'));
        if (selectionIndex == -1) selectionIndex = formattedText.length;
      } else {
        selectionIndex = formattedText.length;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
