import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/property/create_property_usecase.dart';
import '../../../fixtures/fixtures.dart';

class MockPropertyRepository implements PropertyRepository {
  final List<Property> _storage = [];
  bool isPremium = false;

  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async {
    final landlordId = propertyData['arrendador_id'] as String;
    final existingCount = _storage.where((p) => p.arrendadorId == landlordId).length;

    // Validación de plan gratuito vs premium [RF-05.2, RF-05.3]
    if (!isPremium && existingCount >= 1) {
      return const Left(ValidationFailure(
        'El plan gratuito solo permite una (1) propiedad activa. Actualiza a premium para publicar más.',
      ));
    }

    // Validación de al menos 1 foto obligatoria [RF-05.1]
    final photos = propertyData['fotos'] as List<dynamic>?;
    if (photos == null || photos.isEmpty) {
      return const Left(ValidationFailure('Debe incluir al menos una fotografía.'));
    }

    final newProperty = PropertyModel.fromJson(propertyData);
    _storage.add(newProperty);
    return Right(newProperty);
  }

  @override
  Future<Either<Failure, List<Property>>> getProperties() async => Right(_storage);

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async =>
      Right(_storage.where((p) => p.arrendadorId == landlordId).toList());

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
  late MockPropertyRepository mockRepository;
  late CreatePropertyUseCase createPropertyUseCase;

  setUp(() {
    mockRepository = MockPropertyRepository();
    createPropertyUseCase = CreatePropertyUseCase(mockRepository);
  });

  group('CreatePropertyUseCase & Plan Limits Tests [RF-05]', () {
    test('should allow creating 1 property on free plan [RF-05.1, RF-05.2]', () async {
      mockRepository.isPremium = false;
      final result = await createPropertyUseCase(PropertyFixtures.validApartmentBogotaJson);

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Should not fail on first property'),
        (property) => expect(property.titulo, contains('Chapinero')),
      );
    });

    test('should block creating 2nd property on free plan with clean error [RF-05.2]', () async {
      mockRepository.isPremium = false;
      // 1ra propiedad
      await createPropertyUseCase(PropertyFixtures.validApartmentBogotaJson);

      // 2da propiedad sin suscripción premium
      final result = await createPropertyUseCase(PropertyFixtures.validHouseMedellinJson);

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('solo permite una (1) propiedad'));
        },
        (property) => fail('Should block second property on free plan'),
      );
    });

    test('should allow creating multiple properties when premium subscription is active [RF-05.3]', () async {
      mockRepository.isPremium = true;

      final res1 = await createPropertyUseCase(PropertyFixtures.validApartmentBogotaJson);
      final res2 = await createPropertyUseCase(PropertyFixtures.validHouseMedellinJson);

      expect(res1.isRight, isTrue);
      expect(res2.isRight, isTrue);
    });

    test('should reject property creation without photos [RF-05.1]', () async {
      final result = await createPropertyUseCase(PropertyFixtures.invalidPropertyMissingPhotosJson);

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('al menos una fotografía')),
        (property) => fail('Should require at least one photo'),
      );
    });
  });
}
