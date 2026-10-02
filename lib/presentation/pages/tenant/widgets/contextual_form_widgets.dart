import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/utils/context_form_validator.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

/// Formulario contextual para inmuebles residenciales familiares (Casas, Apartamentos, Fincas) [RF-14]
class FormResidencialWidget extends StatelessWidget {
  const FormResidencialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Familiar y Convivencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('occupantsField'),
          controller: provider.occupantsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de ocupantes',
            hintText: 'Ej: 3',
            prefixIcon: Icon(Icons.people_outline),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateOccupants,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('familyDescriptionField'),
          controller: provider.familyDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Composición del núcleo familiar',
            hintText: 'Describe quiénes habitarán el inmueble (parentesco, edades)...',
            prefixIcon: Icon(Icons.family_restroom),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateFamilyDescription,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('¿Tienen mascotas?'),
          subtitle: const Text('Indica si conviven con perros, gatos u otros animales'),
          value: provider.hasPets,
          activeThumbColor: const Color(0xFF0F172A),
          onChanged: (val) {
            provider.setHasPets(val);
          },
        ),
        if (provider.hasPets) ...[
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('petDetailsField'),
            controller: provider.petDetailsController,
            decoration: const InputDecoration(
              labelText: 'Detalle de mascotas (tipo y cantidad)',
              hintText: 'Ej: Un perro Golden Retriever de 2 años',
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(),
            ),
            validator: (val) => ContextualFormValidator.validatePetDetails(
              hasPets: provider.hasPets,
              details: val,
            ),
            onChanged: (_) => provider.notifyValidationChange(),
          ),
        ],
      ],
    );
  }
}

/// Formulario contextual para habitaciones y apartaestudios individuales [RF-15]
class FormIndividualWidget extends StatelessWidget {
  const FormIndividualWidget({super.key});

  static const List<String> _occupations = [
    'Estudiante',
    'Empleado',
    'Independiente',
    'Otro / Sin actividad fija',
  ];

  static const List<String> _relationships = [
    'Padre/Madre',
    'Tutor Legal',
    'Familiar Cercano',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de Ocupación del Solicitante',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('occupationDropdown'),
          initialValue: provider.selectedOccupation,
          decoration: const InputDecoration(
            labelText: 'Ocupación principal',
            prefixIcon: Icon(Icons.work_outline),
            border: OutlineInputBorder(),
          ),
          items: _occupations
              .map((occ) => DropdownMenuItem(value: occ, child: Text(occ)))
              .toList(),
          onChanged: (val) => provider.setSelectedOccupation(val),
          validator: ContextualFormValidator.validateOccupation,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('workplaceOrSchoolField'),
          controller: provider.workplaceOrSchoolController,
          decoration: const InputDecoration(
            labelText: 'Lugar de estudio o empresa',
            hintText: 'Nombre de la universidad, colegio o empresa',
            prefixIcon: Icon(Icons.school_outlined),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateWorkplaceOrSchool,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('¿El solicitante es menor de edad?'),
          subtitle: const Text('Requiere registrar acudiente o tutor responsable'),
          value: provider.isMinor,
          activeThumbColor: const Color(0xFF0F172A),
          onChanged: (val) {
            provider.setIsMinor(val);
          },
        ),
        if (provider.isMinor) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              'Nota: Los ingresos declarados y el comprobante adjunto deben corresponder al acudiente o responsable económico.',
              style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('guardianNameField'),
            controller: provider.guardianNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo del acudiente',
              hintText: 'Nombre y apellidos del responsable',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (val) => ContextualFormValidator.validateGuardianName(
              isMinor: provider.isMinor,
              name: val,
            ),
            onChanged: (_) => provider.notifyValidationChange(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('guardianPhoneField'),
            controller: provider.guardianPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono de contacto del acudiente',
              hintText: 'Número de 10 dígitos (ej: 3101234567)',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (val) => ContextualFormValidator.validateGuardianPhone(
              isMinor: provider.isMinor,
              phone: val,
            ),
            onChanged: (_) => provider.notifyValidationChange(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('guardianRelationshipDropdown'),
            initialValue: provider.guardianRelationship,
            decoration: const InputDecoration(
              labelText: 'Parentesco o relación legal',
              prefixIcon: Icon(Icons.supervised_user_circle_outlined),
              border: OutlineInputBorder(),
            ),
            items: _relationships
                .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                .toList(),
            onChanged: (val) => provider.setGuardianRelationship(val),
            validator: (val) =>
                ContextualFormValidator.validateGuardianRelationship(
              isMinor: provider.isMinor,
              relationship: val,
            ),
          ),
        ],
      ],
    );
  }
}

/// Formulario contextual para inmuebles comerciales (Locales, Oficinas, Bodegas) [RF-16]
class FormComercialWidget extends StatelessWidget {
  const FormComercialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Comercial y del Negocio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('businessNameField'),
          controller: provider.businessNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre comercial o razón social',
            hintText: 'Ej: Inversiones del Café S.A.S.',
            prefixIcon: Icon(Icons.storefront_outlined),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateBusinessName,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('nitField'),
          controller: provider.nitController,
          decoration: const InputDecoration(
            labelText: 'NIT o documento tributario',
            hintText: 'Ej: 901.345.678-2',
            prefixIcon: Icon(Icons.receipt_long_outlined),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateNit,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('economicActivityField'),
          controller: provider.economicActivityController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Actividad económica y uso previsto',
            hintText: 'Describe el tipo de negocio que operará en el inmueble...',
            prefixIcon: Icon(Icons.business_center_outlined),
            border: OutlineInputBorder(),
          ),
          validator: ContextualFormValidator.validateEconomicActivity,
          onChanged: (_) => provider.notifyValidationChange(),
        ),
      ],
    );
  }
}
