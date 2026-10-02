import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_context_data_model.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';

void main() {
  group('ApplicationContextDataModel Serialization [RF-14, RF-15, RF-16, RF-17]', () {
    test('should serialize and deserialize ResidentialContextData correctly', () {
      const entity = ResidentialContextData(
        numeroOcupantes: 4,
        descripcionFamiliar: 'Familia con dos hijos',
        tieneMascotas: true,
        detalleMascotas: 'Un perro Beagle',
      );

      final json = ApplicationContextDataModel.toJson(entity);
      expect(json, isNotNull);
      expect(json!['tipo_categoria'], equals('residencial'));
      expect(json['numero_ocupantes'], equals(4));
      expect(json['descripcion_familiar'], equals('Familia con dos hijos'));
      expect(json['tiene_mascotas'], isTrue);
      expect(json['detalle_mascotas'], equals('Un perro Beagle'));

      final deserialized = ApplicationContextDataModel.fromJson(json);
      expect(deserialized, equals(entity));
    });

    test('should serialize and deserialize IndividualContextData with acudiente correctly', () {
      const entity = IndividualContextData(
        ocupacion: 'Estudiante',
        entidadLaboralEducativa: 'Universidad Nacional',
        esMenorDeEdad: true,
        acudiente: GuardianInfo(
          nombreCompleto: 'Martha Gómez',
          telefono: '3104567890',
          parentesco: 'Madre',
        ),
      );

      final json = ApplicationContextDataModel.toJson(entity);
      expect(json, isNotNull);
      expect(json!['tipo_categoria'], equals('individual'));
      expect(json['ocupacion'], equals('Estudiante'));
      expect(json['es_menor_de_edad'], isTrue);
      expect(json['acudiente'], isNotNull);
      expect(json['acudiente']['nombre_completo'], equals('Martha Gómez'));

      final deserialized = ApplicationContextDataModel.fromJson(json);
      expect(deserialized, equals(entity));
    });

    test('should serialize and deserialize CommercialContextData correctly', () {
      const entity = CommercialContextData(
        razonSocial: 'Café Del Sol SAS',
        nit: '901.234.567-8',
        actividadEconomica: 'Cafetería y repostería',
      );

      final json = ApplicationContextDataModel.toJson(entity);
      expect(json, isNotNull);
      expect(json!['tipo_categoria'], equals('comercial'));
      expect(json['razon_social'], equals('Café Del Sol SAS'));
      expect(json['nit'], equals('901.234.567-8'));
      expect(json['actividad_economica'], equals('Cafetería y repostería'));

      final deserialized = ApplicationContextDataModel.fromJson(json);
      expect(deserialized, equals(entity));
    });

    test('should handle null or invalid JSON gracefully without throwing', () {
      expect(ApplicationContextDataModel.fromJson(null), isNull);
      expect(ApplicationContextDataModel.fromJson({}), isNull);
      expect(ApplicationContextDataModel.fromJson({'tipo_categoria': 'desconocido'}), isNull);
      expect(ApplicationContextDataModel.toJson(null), isNull);
    });
  });
}
