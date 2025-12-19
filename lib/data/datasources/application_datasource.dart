import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/data/models/application_model.dart';

abstract class ApplicationDatasource {
  Future<List<ApplicationModel>> getLandlordApplications(String landlordId);
  Future<List<ApplicationModel>> getTenantApplications(String tenantId);
  Future<bool> updateApplicationStatus(String applicationId, String status);
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
      await client
          .from('solicitudes')
          .update({'estado': status})
          .eq('id', applicationId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
