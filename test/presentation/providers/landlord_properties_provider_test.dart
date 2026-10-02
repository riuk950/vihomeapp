import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/property/create_property_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/delete_property_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/get_properties_by_landlord_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/update_property_usecase.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import '../../fixtures/fixtures.dart';

class MockLandlordRepo implements PropertyRepository {
  final List<Property> properties = [];
  Failure? failure;

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async {
    if (failure != null) return Left(failure!);
    return Right(properties.where((p) => p.arrendadorId == landlordId).toList());
  }

  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async {
    if (failure != null) return Left(failure!);
    final prop = PropertyModel.fromJson(propertyData);
    properties.add(prop);
    return Right(prop);
  }

  @override
  Future<Either<Failure, Property>> updateProperty(String id, Map<String, dynamic> data) async {
    if (failure != null) return Left(failure!);
    final index = properties.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = PropertyModel.fromJson(data);
      properties[index] = updated;
      return Right(updated);
    }
    return const Left(ServerFailure('Propiedad no encontrada'));
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async {
    if (failure != null) return Left(failure!);
    properties.removeWhere((p) => p.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Property>>> getProperties() async => Right(properties);

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async =>
      throw UnimplementedError();
}

void main() {
  late MockLandlordRepo mockRepo;
  late LandlordPropertiesProvider provider;

  final bogotaProp = PropertyModel.fromJson(PropertyFixtures.validApartmentBogotaJson);

  setUp(() {
    mockRepo = MockLandlordRepo();
    mockRepo.properties.add(bogotaProp);

    provider = LandlordPropertiesProvider(
      getPropertiesByLandlordUseCase: GetPropertiesByLandlordUseCase(mockRepo),
      createPropertyUseCase: CreatePropertyUseCase(mockRepo),
      updatePropertyUseCase: UpdatePropertyUseCase(mockRepo),
      deletePropertyUseCase: DeletePropertyUseCase(mockRepo),
    );
  });

  group('LandlordPropertiesProvider Tests [RF-05]', () {
    test('fetchPropertiesByLandlord should populate landlord properties and active count [RF-05.1]', () async {
      await provider.fetchPropertiesByLandlord(bogotaProp.arrendadorId);

      expect(provider.properties, hasLength(1));
      expect(provider.activePropertiesCount, 1);
      expect(provider.inactivePropertiesCount, 0);
    });

    test('createProperty should add new property and increment active count [RF-05.1]', () async {
      await provider.fetchPropertiesByLandlord(bogotaProp.arrendadorId);
      final newPropData = PropertyFixtures.validHouseMedellinJson;
      final success = await provider.createProperty(newPropData);

      expect(success, isTrue);
      expect(provider.properties, hasLength(2));
      expect(provider.activePropertiesCount, 2);
    });

    test('deleteProperty should remove property and update state [RF-05.4]', () async {
      await provider.fetchPropertiesByLandlord(bogotaProp.arrendadorId);
      final success = await provider.deleteProperty(bogotaProp.id);

      expect(success, isTrue);
      expect(provider.properties, isEmpty);
    });
  });
}
