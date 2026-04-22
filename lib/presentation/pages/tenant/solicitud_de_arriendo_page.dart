import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/widgets/btn_primary.dart';

class SolicitudDeArriendoPage extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String landlordId;

  const SolicitudDeArriendoPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.landlordId,
  });

  @override
  State<SolicitudDeArriendoPage> createState() =>
      _SolicitudDeArriendoPageState();
}

class _SolicitudDeArriendoPageState extends State<SolicitudDeArriendoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para información laboral y financiera
  final _empresaController = TextEditingController();
  final _cargoController = TextEditingController();
  final _tiempoEmpleoController = TextEditingController();
  final _ingresoMensualController = TextEditingController();
  final _otrosIngresosController = TextEditingController();

  // Lista de documentos adjuntos
  final List<PlatformFile> _documentosAdjuntos = [];

  // Lista de referencias personales
  final List<Map<String, String>> _referencias = [];

  // Aceptación de términos legales
  bool _aceptaTerminos = false;
  bool _aceptaPoliticaPrivacidad = false;
  bool _aceptaVerificacionDatos = false;

  // Estados de expansión de los paneles
  bool _isLaboralExpanded = true;
  bool _isReferenciasExpanded = false;
  bool _isLegalExpanded = false;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _empresaController.dispose();
    _cargoController.dispose();
    _tiempoEmpleoController.dispose();
    _ingresoMensualController.dispose();
    _otrosIngresosController.dispose();
    super.dispose();
  }

  Future<void> _adjuntarDocumento() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _documentosAdjuntos.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarDocumento(int index) {
    setState(() {
      _documentosAdjuntos.removeAt(index);
    });
  }

  void _agregarReferencia() {
    showDialog(
      context: context,
      builder: (context) {
        final nombreController = TextEditingController();
        final telefonoController = TextEditingController();
        final relacionController = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar Referencia Personal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relacionController,
                  decoration: const InputDecoration(
                    labelText: 'Relación (Amigo, Familiar, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty &&
                    telefonoController.text.isNotEmpty &&
                    relacionController.text.isNotEmpty) {
                  setState(() {
                    _referencias.add({
                      'nombre': nombreController.text,
                      'telefono': telefonoController.text,
                      'relacion': relacionController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _eliminarReferencia(int index) {
    setState(() {
      _referencias.removeAt(index);
    });
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: secondaryColor,
        ),
      );
      return;
    }

    if (_referencias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agregue al menos una referencia personal'),
          backgroundColor: secondaryColor,
        ),
      );
      return;
    }

    if (!_aceptaTerminos ||
        !_aceptaPoliticaPrivacidad ||
        !_aceptaVerificacionDatos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar todos los términos y condiciones'),
          backgroundColor: secondaryColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationProvider = Provider.of<ApplicationProvider>(
        context,
        listen: false,
      );

      if (authProvider.user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Convertir referencias a objetos PersonalReference
      final refPersonales = _referencias
          .map(
            (ref) => PersonalReference(
              nombre: ref['nombre']!,
              telefono: ref['telefono']!,
              relacion: ref['relacion']!,
            ),
          )
          .toList();

      String? documentoUrlsString;
      if (_documentosAdjuntos.isNotEmpty) {
        try {
          final supabase = Supabase.instance.client;
          final List<String> urls = [];

          for (var file in _documentosAdjuntos) {
            // Generate unique path
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(RegExp(r'\s+'), '_')}';
            final path = 'solicitudes/${authProvider.user!.id}/$fileName';

            if (file.path != null) {
              final fileObj = File(file.path!);
              await supabase.storage
                  .from('documentos_solicitudes')
                  .upload(path, fileObj);
            } else if (file.bytes != null) {
              await supabase.storage
                  .from('documentos_solicitudes')
                  .uploadBinary(path, file.bytes!);
            }

            final publicUrl = supabase.storage
                .from('documentos_solicitudes')
                .getPublicUrl(path);
            urls.add(publicUrl);
          }
          documentoUrlsString = urls.join(',');
        } catch (e) {
          debugPrint('Error uploading file: $e');
          // Continue? Or throw? Better to throw so user knows.
          throw Exception('Error al subir documentos: $e');
        }
      }

      // Crear la solicitud
      final application = ApplicationModel(
        id: '', // Se generará en el servidor
        arrendatarioId: authProvider.user!.id,
        arrendadorId: widget.landlordId,
        propiedadId: widget.propertyId,
        estado: 'pendiente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        empresa: _empresaController.text,
        cargo: _cargoController.text,
        tiempoEmpleo: _tiempoEmpleoController.text,
        ingresosMensuales: _ingresoMensualController.text,
        otrosIngresos: _otrosIngresosController.text.isEmpty
            ? null
            : _otrosIngresosController.text,
        documentoUrl: documentoUrlsString,
        refPersonales: refPersonales,
      );

      final result = await applicationProvider.createApplication(application);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('¡Solicitud Enviada!'),
                ],
              ),
              content: const Text(
                'Su solicitud de arriendo ha sido enviada exitosamente. '
                'El propietario revisará su información y se pondrá en contacto con usted.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a la página anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                applicationProvider.errorMessage ??
                    'Error al enviar la solicitud',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Solicitud de Arriendo'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información de la propiedad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Propiedad',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.propertyTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. Información Laboral y Financiera
            _buildExpansionPanel(
              title: 'Información Laboral y Financiera',
              subtitle: 'Complete sus datos laborales y adjunte documentos',
              icon: Icons.work_outline,
              isExpanded: _isLaboralExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isLaboralExpanded = expanded;
                });
              },
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _empresaController,
                  label: 'Empresa donde trabaja',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cargoController,
                  label: 'Cargo o posición',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _tiempoEmpleoController,
                  label: 'Tiempo en el empleo (meses)',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ingresoMensualController,
                  label: 'Ingreso mensual (COP)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _otrosIngresosController,
                  label: 'Otros ingresos (opcional)',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Sección de documentos
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Documentos Adjuntos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _adjuntarDocumento,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Adjuntar'),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adjunte certificados laborales, comprobantes de ingresos, etc.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                if (_documentosAdjuntos.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No hay documentos adjuntos',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(_documentosAdjuntos.length, (index) {
                    final file = _documentosAdjuntos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFileIcon(file.extension ?? ''),
                            color: primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _formatFileSize(file.size),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _eliminarDocumento(index),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Referencias Personales
            _buildExpansionPanel(
              title: 'Referencias Personales',
              subtitle: 'Agregue al menos una referencia personal',
              icon: Icons.people_outline,
              isExpanded: _isReferenciasExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isReferenciasExpanded = expanded;
                });
              },
              children: [
                if (_referencias.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No hay referencias agregadas',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(_referencias.length, (index) {
                    final referencia = _referencias[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  referencia['nombre']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  referencia['telefono']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  referencia['relacion']!,
                                  style: const TextStyle(
                                    color: Color(0xFF137FEC),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _eliminarReferencia(index),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _agregarReferencia,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Referencia'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Acuerdos Legales
            _buildExpansionPanel(
              title: 'Acuerdos Legales',
              subtitle: 'Lea y acepte los términos y condiciones',
              icon: Icons.gavel,
              isExpanded: _isLegalExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isLegalExpanded = expanded;
                });
              },
              children: [
                // Términos y Condiciones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Términos y Condiciones de Arriendo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. El arrendatario se compromete a pagar el arriendo mensual en las fechas acordadas.\n\n'
                        '2. El arrendatario debe mantener la propiedad en buen estado.\n\n'
                        '3. No se permiten modificaciones estructurales sin autorización del propietario.\n\n'
                        '4. El depósito de garantía será devuelto al finalizar el contrato, sujeto a inspección.\n\n'
                        '5. El incumplimiento de los términos puede resultar en la terminación del contrato.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _aceptaTerminos,
                  onChanged: (value) {
                    setState(() {
                      _aceptaTerminos = value ?? false;
                    });
                  },
                  title: const Text(
                    'Acepto los términos y condiciones de arriendo',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _aceptaPoliticaPrivacidad,
                  onChanged: (value) {
                    setState(() {
                      _aceptaPoliticaPrivacidad = value ?? false;
                    });
                  },
                  title: const Text(
                    'Acepto la política de privacidad y tratamiento de datos',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _aceptaVerificacionDatos,
                  onChanged: (value) {
                    setState(() {
                      _aceptaVerificacionDatos = value ?? false;
                    });
                  },
                  title: const Text(
                    'Autorizo la verificación de mi información laboral y referencias',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 4. Botón de Solicitud
            SizedBox(
              width: double.infinity,
              child: BtnPrimary(
                onPressed: _isSubmitting ? null : () => _enviarSolicitud(),
                text: 'Enviar Solicitud',
                elevation: 2,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
