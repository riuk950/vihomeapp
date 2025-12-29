import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/errors/exceptions.dart';
import 'package:vihomeapp/data/models/property_model.dart';

abstract class PropertyLocalDataSource {
  Future<List<PropertyModel>> getLastProperties();
  Future<void> cacheProperties(List<PropertyModel> propertiesToCache);
}

const cachedProperties = 'CACHED_PROPERTIES';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  final SharedPreferences sharedPreferences;

  PropertyLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PropertyModel>> getLastProperties() {
    final jsonString = sharedPreferences.getString(cachedProperties);
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
      cachedProperties,
      json.encode(
        propertiesToCache.map((property) => property.toJson()).toList(),
      ),
    );
  }
}
