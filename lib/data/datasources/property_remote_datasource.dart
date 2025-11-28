import '../../core/errors/failures.dart';
import '../models/property_model.dart';
import '../../infrastructure/services/supabase_service.dart';

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties();
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final SupabaseService supabaseService;

  PropertyRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<List<PropertyModel>> getProperties() async {
    try {
      final response = await supabaseService.client
          .from('propiedades')
          .select();
      final properties = (response as List)
          .map((property) => PropertyModel.fromJson(property))
          .toList();
      return properties;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId) async {
    try {
      final response = await supabaseService.client
          .from('propiedades')
          .select()
          .eq('arrendador_id', landlordId);
      final properties = (response as List)
          .map((property) => PropertyModel.fromJson(property))
          .toList();
      return properties;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
