import '../../core/errors/failures.dart';
import '../models/property_model.dart';
import '../../infrastructure/services/supabase_service.dart';

import '../models/property_type_model.dart';

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties();
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId);
  Future<PropertyModel> createProperty(Map<String, dynamic> propertyData);
  Future<PropertyModel> updateProperty(String id, Map<String, dynamic> data);
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<void> deleteProperty(String id);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final SupabaseService supabaseService;

  PropertyRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<List<PropertyModel>> getProperties() async {
    try {
      final response =
          await supabaseService.client.from('propiedades').select();
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

  @override
  Future<PropertyModel> createProperty(
    Map<String, dynamic> propertyData,
  ) async {
    try {
      final response = await supabaseService.client
          .from('propiedades')
          .insert(propertyData)
          .select()
          .single();
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PropertyModel> updateProperty(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await supabaseService.client
          .from('propiedades')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return PropertyModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteProperty(String id) async {
    try {
      await supabaseService.client
          .from('propiedades')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    try {
      final response =
          await supabaseService.client.from('tipos_propiedad').select();
      return (response as List)
          .map((e) => PropertyTypeModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
