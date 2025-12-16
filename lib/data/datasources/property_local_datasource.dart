import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';
import '../../core/errors/exceptions.dart';

abstract class PropertyLocalDataSource {
  Future<List<PropertyModel>> getLastProperties();
  Future<void> cacheProperties(List<PropertyModel> propertiesToCache);
}

const CACHED_PROPERTIES = 'CACHED_PROPERTIES';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  final SharedPreferences sharedPreferences;

  PropertyLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PropertyModel>> getLastProperties() {
    final jsonString = sharedPreferences.getString(CACHED_PROPERTIES);
    if (jsonString != null) {
      return Future.value(
        (json.decode(jsonString) as List)
            .map((item) => PropertyModel.fromJson(item))
            .toList(),
      );
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProperties(List<PropertyModel> propertiesToCache) {
    return sharedPreferences.setString(
      CACHED_PROPERTIES,
      json.encode(
        propertiesToCache.map((property) => property.toJson()).toList(),
      ),
    );
  }
}
