import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/context_form_validator.dart';

void main() {
  group('ContextualFormValidator - Residencial [RF-14, CL-10, CL-12]', () {
    test('validateOccupants should accept valid integers between 1 and 20', () {
      expect(ContextualFormValidator.validateOccupants('1'), isNull);
      expect(ContextualFormValidator.validateOccupants('4'), isNull);
      expect(ContextualFormValidator.validateOccupants('20'), isNull);
    });

    test('validateOccupants should reject 0, negative numbers or non-numeric values [CL-10]', () {
      expect(ContextualFormValidator.validateOccupants('0'), isNotNull);
      expect(ContextualFormValidator.validateOccupants('-2'), isNotNull);
      expect(ContextualFormValidator.validateOccupants('abc'), isNotNull);
      expect(ContextualFormValidator.validateOccupants(''), isNotNull);
      expect(ContextualFormValidator.validateOccupants(null), isNotNull);
      expect(ContextualFormValidator.validateOccupants('25'), isNotNull);
    });

    test('validateFamilyDescription should require between 10 and 500 chars', () {
      expect(ContextualFormValidator.validateFamilyDescription('Corto'), isNotNull);
      expect(
        ContextualFormValidator.validateFamilyDescription('Somos una pareja de esposos con dos hijos.'),
        isNull,
      );
      expect(ContextualFormValidator.validateFamilyDescription('a' * 501), isNotNull);
    });

    test('validatePetDetails should be required only when hasPets is true [RF-14.3, CL-12]', () {
      // If hasPets is false, null or empty details are accepted
      expect(ContextualFormValidator.validatePetDetails(hasPets: false, details: null), isNull);
      expect(ContextualFormValidator.validatePetDetails(hasPets: false, details: ''), isNull);

      // If hasPets is true, empty or too short is rejected
      expect(ContextualFormValidator.validatePetDetails(hasPets: true, details: null), isNotNull);
      expect(ContextualFormValidator.validatePetDetails(hasPets: true, details: '  '), isNotNull);
      expect(ContextualFormValidator.validatePetDetails(hasPets: true, details: 'un'), isNotNull);

      // Valid details
      expect(ContextualFormValidator.validatePetDetails(hasPets: true, details: 'Un perro labrador'), isNull);
      expect(ContextualFormValidator.validatePetDetails(hasPets: true, details: 'a' * 151), isNotNull);
    });
  });

  group('ContextualFormValidator - Habitación/Individual [RF-15, CL-11]', () {
    test('validateOccupation should require non-empty value', () {
      expect(ContextualFormValidator.validateOccupation('Estudiante'), isNull);
      expect(ContextualFormValidator.validateOccupation(''), isNotNull);
      expect(ContextualFormValidator.validateOccupation(null), isNotNull);
    });

    test('validateWorkplaceOrSchool should require between 3 and 100 chars', () {
      expect(ContextualFormValidator.validateWorkplaceOrSchool('UN'), isNotNull);
      expect(ContextualFormValidator.validateWorkplaceOrSchool('Universidad Nacional'), isNull);
      expect(ContextualFormValidator.validateWorkplaceOrSchool('a' * 101), isNotNull);
    });

    test('validateGuardianName should be required only when isMinor is true [CL-11]', () {
      // Not minor: passes even if null
      expect(ContextualFormValidator.validateGuardianName(isMinor: false, name: null), isNull);

      // Minor: required, alphabetical with accents, spaces and dashes
      expect(ContextualFormValidator.validateGuardianName(isMinor: true, name: null), isNotNull);
      expect(ContextualFormValidator.validateGuardianName(isMinor: true, name: 'Ana'), isNotNull); // < 5
      expect(ContextualFormValidator.validateGuardianName(isMinor: true, name: 'Juan 123'), isNotNull); // digits
      expect(
        ContextualFormValidator.validateGuardianName(isMinor: true, name: 'Martha Cecilia Gómez de la Torre'),
        isNull,
      );
    });

    test('validateGuardianPhone should require 10 digits or international format [CL-11]', () {
      expect(ContextualFormValidator.validateGuardianPhone(isMinor: false, phone: null), isNull);

      expect(ContextualFormValidator.validateGuardianPhone(isMinor: true, phone: null), isNotNull);
      expect(ContextualFormValidator.validateGuardianPhone(isMinor: true, phone: '310123'), isNotNull); // short
      expect(ContextualFormValidator.validateGuardianPhone(isMinor: true, phone: '3104567890'), isNull); // 10 digits
      expect(ContextualFormValidator.validateGuardianPhone(isMinor: true, phone: '+573104567890'), isNull); // international
    });

    test('validateGuardianRelationship should require non-empty when isMinor is true', () {
      expect(ContextualFormValidator.validateGuardianRelationship(isMinor: false, relationship: null), isNull);
      expect(ContextualFormValidator.validateGuardianRelationship(isMinor: true, relationship: null), isNotNull);
      expect(ContextualFormValidator.validateGuardianRelationship(isMinor: true, relationship: 'Madre'), isNull);
    });
  });

  group('ContextualFormValidator - Comercial [RF-16]', () {
    test('validateBusinessName should require between 3 and 100 chars', () {
      expect(ContextualFormValidator.validateBusinessName('AB'), isNotNull);
      expect(ContextualFormValidator.validateBusinessName('Café Origen S.A.S.'), isNull);
      expect(ContextualFormValidator.validateBusinessName('a' * 101), isNotNull);
    });

    test('validateNit should require 6-20 alphanumeric chars with dots or dashes', () {
      expect(ContextualFormValidator.validateNit('123'), isNotNull); // < 6
      expect(ContextualFormValidator.validateNit('901345678'), isNull);
      expect(ContextualFormValidator.validateNit('901.345.678-2'), isNull);
      expect(ContextualFormValidator.validateNit('NIT-VALIDO-1'), isNull);
      expect(ContextualFormValidator.validateNit('NIT@#%'), isNotNull); // invalid symbols
    });

    test('validateEconomicActivity should require between 10 and 500 chars', () {
      expect(ContextualFormValidator.validateEconomicActivity('Panadería'), isNotNull); // < 10
      expect(
        ContextualFormValidator.validateEconomicActivity('Comercialización de café especial y panadería.'),
        isNull,
      );
      expect(ContextualFormValidator.validateEconomicActivity('a' * 501), isNotNull);
    });
  });
}
