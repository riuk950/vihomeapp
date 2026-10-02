import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/property/get_properties_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/get_property_types_usecase.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import '../../fixtures/fixtures.dart';

class MockPropRepo implements PropertyRepository {
  List<Property> propertyList = [];
  List<PropertyType> typeList = [];
  Failure? failure;

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    if (failure != null) return Left(failure!);
    return Right(propertyList);
  }

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async {
    if (failure != null) return Left(failure!);
    return Right(typeList);
  }

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async =>
      Right(propertyList);

  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Property>> updateProperty(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async =>
      throw UnimplementedError();
}

void main() {
  late MockPropRepo mockRepo;
  late PropertyProvider propertyProvider;

  final bogotaProp = PropertyModel.fromJson(PropertyFixtures.validApartmentBogotaJson);
  final medellinProp = PropertyModel.fromJson(PropertyFixtures.validHouseMedellinJson);

  setUp(() {
    mockRepo = MockPropRepo();
    mockRepo.propertyList = [bogotaProp, medellinProp];
    mockRepo.typeList = [
      const PropertyType(nombre: 'apartamento'),
      const PropertyType(nombre: 'casa'),
    ];

    propertyProvider = PropertyProvider(
      getPropertiesUseCase: GetPropertiesUseCase(mockRepo),
      getPropertyTypesUseCase: GetPropertyTypesUseCase(mockRepo),
    );
  });

  group('PropertyProvider State Management Tests [RF-02, RF-03]', () {
    test('fetchProperties should load properties into state [RF-02.1, RF-03.1]', () async {
      await propertyProvider.fetchProperties();

      expect(propertyProvider.properties, hasLength(2));
      expect(propertyProvider.isLoading, isFalse);
      expect(propertyProvider.errorMessage, isNull);
    });

    test('selectType should filter properties by selected property type [RF-02.2]', () async {
      await propertyProvider.fetchProperties();
      await propertyProvider.fetchPropertyTypes();

      final casaType = propertyProvider.propertyTypes.firstWhere((t) => t.nombre == 'casa');
      propertyProvider.selectType(casaType);

      expect(propertyProvider.properties, hasLength(1));
      expect(propertyProvider.properties.first.tipoPropiedad, 'casa');
    });

    test('selectType(null) should reset filters and display all properties [RF-02.2]', () async {
      await propertyProvider.fetchProperties();
      propertyProvider.selectType(null);

      expect(propertyProvider.properties, hasLength(2));
    });

    test('fetchProperties should handle failure and populate errorMessage [RNF-01]', () async {
      mockRepo.failure = const ServerFailure('Error al conectar con el servidor');
      await propertyProvider.fetchProperties();

      expect(propertyProvider.errorMessage, contains('Error al conectar'));
    });
  });
}
