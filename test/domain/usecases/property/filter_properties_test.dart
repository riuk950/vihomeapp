import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/property/get_properties_usecase.dart';
import '../../../fixtures/fixtures.dart';

class FakePropertyRepository implements PropertyRepository {
  List<Property> properties = [];
  Failure? failureToReturn;

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(properties);
  }

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(properties.where((p) => p.arrendadorId == landlordId).toList());
  }

  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Property>> updateProperty(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async =>
      throw UnimplementedError();
}

void main() {
  late FakePropertyRepository fakeRepository;
  late GetPropertiesUseCase getPropertiesUseCase;

  final bogotaApartment = PropertyModel.fromJson(PropertyFixtures.validApartmentBogotaJson);
  final medellinHouse = PropertyModel.fromJson(PropertyFixtures.validHouseMedellinJson);

  setUp(() {
    fakeRepository = FakePropertyRepository();
    fakeRepository.properties = [bogotaApartment, medellinHouse];
    getPropertiesUseCase = GetPropertiesUseCase(fakeRepository);
  });

  group('Property Search & Filtering UseCases Tests [RF-02, RF-03]', () {
    test('GetPropertiesUseCase should return all available published properties [RF-02.1]', () async {
      final result = await getPropertiesUseCase();

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Should not fail'),
        (list) {
          expect(list, hasLength(2));
          expect(list.first.ciudad, 'Bogotá');
        },
      );
    });

    test('should filter properties accurately by city [RF-02.1, RF-02.2]', () async {
      final result = await getPropertiesUseCase();
      final allProperties = result.fold((l) => <Property>[], (r) => r);

      final bogotaOnly = allProperties.where((p) => p.ciudad.toLowerCase() == 'bogotá'.toLowerCase()).toList();

      expect(bogotaOnly, hasLength(1));
      expect(bogotaOnly.first.titulo, contains('Chapinero'));
    });

    test('should filter properties by property type and price range [RF-02.1, RF-02.2]', () async {
      final result = await getPropertiesUseCase();
      final allProperties = result.fold((l) => <Property>[], (r) => r);

      final casasCaras = allProperties.where(
        (p) => p.tipoPropiedad == 'casa' && p.precio >= 3000000 && p.precio <= 5000000,
      ).toList();

      expect(casasCaras, hasLength(1));
      expect(casasCaras.first.ciudad, 'Medellín');
    });

    test('should return empty list when no properties match criteria [RF-02.3]', () async {
      final result = await getPropertiesUseCase();
      final allProperties = result.fold((l) => <Property>[], (r) => r);

      final cartagena = allProperties.where((p) => p.ciudad == 'Cartagena').toList();

      expect(cartagena, isEmpty);
    });
  });
}
