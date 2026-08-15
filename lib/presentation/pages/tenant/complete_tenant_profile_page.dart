import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/presentation/widgets/btn_primary.dart';
import '../../../domain/entities/tenant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import 'package:flutter/services.dart';
import '../../helpers/phone_input_formatter.dart';

class CompleteTenantProfilePage extends StatefulWidget {
  const CompleteTenantProfilePage({super.key});

  @override
  State<CompleteTenantProfilePage> createState() =>
      _CompleteTenantProfilePageState();
}

class _CompleteTenantProfilePageState extends State<CompleteTenantProfilePage> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TenantProvider>(context, listen: false).clearError();
    });
  }

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
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    final tenant = Tenant(
      id: user.id,
      primerNombre: _primerNombreController.text.trim(),
      segundoNombre: _segundoNombreController.text.trim().isEmpty
          ? null
          : _segundoNombreController.text.trim(),
      primerApellido: _primerApellidoController.text.trim(),
      segundoApellido: _segundoApellidoController.text.trim().isEmpty
          ? null
          : _segundoApellidoController.text.trim(),
      documento: _documentoController.text.trim(),
      direccionContacto: _direccionContactoController.text.trim(),
      tipoDocumento: _tipoDocumento,
      telefonoContacto:
          _telefonoContactoController.text.replaceAll(RegExp(r'\D'), ''),
    );

    final success = await tenantProvider.saveTenantProfile(tenant);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil completado exitosamente'),
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
            child: Consumer<TenantProvider>(
              builder: (context, tenantProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Información del Arrendatario',
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
                        PhoneInputFormatter(),
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
                    if (tenantProvider.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        tenantProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    BtnPrimary(
                        text: 'Guardar',
                        onPressed:
                            tenantProvider.isLoading ? null : _handleSave),
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
