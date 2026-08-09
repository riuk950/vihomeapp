import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/data/models/application_model.dart';

abstract class ApplicationDatasource {
  Future<List<ApplicationModel>> getLandlordApplications(String landlordId);
  Future<List<ApplicationModel>> getTenantApplications(String tenantId);
  Future<bool> updateApplicationStatus(String applicationId, String status);
  Future<ApplicationModel> createApplication(ApplicationModel application);
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId);
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId);
  Future<bool> deleteApplication(String applicationId);
  Future<bool> deleteApplicationsForProperty(String propertyId);
}

class ApplicationDatasourceImpl implements ApplicationDatasource {
  final SupabaseClient client;

  ApplicationDatasourceImpl(this.client);

  @override
  Future<List<ApplicationModel>> getLandlordApplications(
    String landlordId,
  ) async {
    try {
      // Intentar traer datos relacionados.
      // Nota: Esto requiere que las foreign keys existan en Supabase.
      // Si 'propiedades' es la tabla relacionada por propiedad_id
      // 'perfiles' (o users si es publico) por arrendatario_id.
      // Ajustaré la query a lo safe primero, y si puedo join mejor.
      // Como no estoy seguro de la tabla de usuarios publica, usaré solo propiedades.

      final response = await client
          .from('solicitudes')
          .select('*, propiedades(*)')
          .eq('arrendador_id', landlordId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching applications: $e');
    }
  }

  @override
  Future<List<ApplicationModel>> getTenantApplications(String tenantId) async {
    try {
      final response = await client
          .from('solicitudes')
          .select('*, propiedades(*)')
          .eq('arrendatario_id', tenantId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching tenant applications: $e');
    }
  }

  @override
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      final applicationResponse = await client
          .from('solicitudes')
          .select('propiedad_id')
          .eq('id', applicationId)
          .maybeSingle();

      if (applicationResponse == null) {
        throw Exception(
          'No se pudo actualizar la solicitud. Verifique permisos o existencia.',
        );
      }

      final propertyId = applicationResponse['propiedad_id'] as String?;
      if (propertyId == null || propertyId.isEmpty) {
        throw Exception('La solicitud no tiene una propiedad asociada.');
      }

      final response = await client
          .from('solicitudes')
          .update({'estado': status})
          .eq('id', applicationId)
          .select();

      if (response.isEmpty) {
        throw Exception(
          'No se pudo actualizar la solicitud. Verifique permisos o existencia.',
        );
      }

      if (status.toLowerCase() == 'aceptada') {
        await client
            .from('propiedades')
            .update({'publicado': false}).eq('id', propertyId);
      }

      if (status.toLowerCase() == 'cancelada') {
        await client
            .from('propiedades')
            .update({'publicado': true}).eq('id', propertyId);
      }

      return true;
    } catch (e) {
      throw Exception('Error updating application status: $e');
    }
  }

  @override
  Future<ApplicationModel> createApplication(
    ApplicationModel application,
  ) async {
    try {
      final response = await client
          .from('solicitudes')
          .insert(application.toJsonCreate())
          .select()
          .single();

      return ApplicationModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating application: $e');
    }
  }

  @override
  Future<bool> hasApplicationForProperty(
    String tenantId,
    String propertyId,
  ) async {
    try {
      final response = await client
          .from('solicitudes')
          .select('id')
          .eq('arrendatario_id', tenantId)
          .eq('propiedad_id', propertyId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async {
    try {
      final response = await client
          .from('solicitudes')
          .select('id')
          .eq('propiedad_id', propertyId)
          .eq('estado', 'aceptada')
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteApplication(String applicationId) async {
    try {
      await client.from('solicitudes').delete().eq('id', applicationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async {
    try {
      await client.from('solicitudes').delete().eq('propiedad_id', propertyId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
