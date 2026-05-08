import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/presentation/widgets/widgets.dart';
import '../../../domain/entities/landlord.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import 'package:flutter/services.dart';

class CompleteLandlordProfilePage extends StatefulWidget {
  const CompleteLandlordProfilePage({super.key});

  @override
  State<CompleteLandlordProfilePage> createState() =>
      _CompleteLandlordProfilePageState();
}

class _CompleteLandlordProfilePageState
    extends State<CompleteLandlordProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _direccionContactoController = TextEditingController();
  final _telefonoContactoController = TextEditingController();
  String _tipoDocumento = 'CC';

  @override
  void dispose() {
    _primerNombreController.dispose();
    _segundoNombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _documentoController.dispose();
    _direccionContactoController.dispose();
    _telefonoContactoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final landlordProvider = Provider.of<LandlordProvider>(
      context,
      listen: false,
    );
    final user = authProvider.user;

    if (user == null) return;

    final landlord = Landlord(
      id: user.id,
      primerNombre: _primerNombreController.text.trim(),
      segundoNombre: _segundoNombreController.text.trim().isEmpty
          ? null
          : _segundoNombreController.text.trim(),
      primerApellido: _primerApellidoController.text.trim(),
      segundoApellido: _segundoApellidoController.text.trim().isEmpty
          ? null
          : _segundoApellidoController.text.trim(),
      documento: int.parse(_documentoController.text.trim()),
      direccionContacto: _direccionContactoController.text.trim(),
      tipoDocumento: _tipoDocumento,
      telefonoContacto:
          _telefonoContactoController.text.replaceAll(RegExp(r'\D'), ''),
    );

    final success = await landlordProvider.saveLandlordProfile(landlord);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil de arrendador completado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar Perfil'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer<LandlordProvider>(
              builder: (context, landlordProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Información del Arrendador',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor completa tus datos para verificar tu cuenta',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _primerNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Primer Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _segundoNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Segundo Nombre (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _primerApellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Primer Apellido',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _segundoApellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Segundo Apellido (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoDocumento,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CC',
                          child: Text('Cédula de Ciudadanía'),
                        ),
                        DropdownMenuItem(
                          value: 'CE',
                          child: Text('Cédula de Extranjería'),
                        ),
                        DropdownMenuItem(
                          value: 'PAS',
                          child: Text('Pasaporte'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoDocumento = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _documentoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de Documento',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        if (value.length < 5 || value.length > 10) {
                          return 'El número de documento debe tener entre 5 y 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionContactoController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de Contacto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoContactoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        _PhoneInputFormatter(),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de Contacto',
                        hintText: 'Ej: 57 300 123 4567',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        final cleanValue = value.replaceAll(RegExp(r'\D'), '');
                        if (!cleanValue.startsWith('57')) {
                          return 'El número debe comenzar por 57';
                        }
                        if (cleanValue.length < 12) {
                          return 'Número inválido (debe tener 12 dígitos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BtnPrimary(
                        text: 'Guardar',
                        onPressed:
                            landlordProvider.isLoading ? null : _handleSave),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;

    newText.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    int selectionIndex = newValue.selection.end;
    int digitCount = 0;
    int newSelectionIndex = 0;

    for (int i = 0; i < newText.length; i++) {
      if (i == selectionIndex) {
        newSelectionIndex = buffer.length;
      }
      if (RegExp(r'\d').hasMatch(newText[i])) {
        if (digitCount == 2 || digitCount == 5 || digitCount == 8) {
          buffer.write(' ');
          if (i == selectionIndex) {
            newSelectionIndex = buffer.length;
          }
        }
        buffer.write(newText[i]);
        digitCount++;
      }
    }

    if (selectionIndex == newText.length) {
      newSelectionIndex = buffer.length;
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
