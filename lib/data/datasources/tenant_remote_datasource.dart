import '../../core/errors/supabase_error_handler.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<TenantModel?> getTenantProfile(String userId);
  Future<void> saveTenantProfile(TenantModel tenant);
}

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final SupabaseService supabaseService;

  TenantRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<TenantModel?> getTenantProfile(String userId) async {
    try {
      final response = await supabaseService.client
          .from('info_arrendatarios')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return TenantModel.fromJson(response);
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<void> saveTenantProfile(TenantModel tenant) async {
    try {
      await supabaseService.client
          .from('info_arrendatarios')
          .upsert(tenant.toJson());
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }
}
