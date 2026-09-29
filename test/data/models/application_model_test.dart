import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';
import '../../fixtures/fixtures.dart';

void main() {
  group('ApplicationModel Serialization & Domain Entity Tests [RF-04, RF-06]', () {
    test('should correctly deserialize valid pending application JSON into ApplicationModel', () {
      final json = ApplicationFixtures.validPendingApplicationJson;
      final model = ApplicationModel.fromJson(json);

      expect(model.id, json['id']);
      expect(model.arrendatarioId, json['arrendatario_id']);
      expect(model.arrendadorId, json['arrendador_id']);
      expect(model.propiedadId, json['propiedad_id']);
      expect(model.estado, 'Pendiente');
      expect(model.ingresosMensuales, '8500000');
      expect(model.documentoUrl, isNotEmpty);
      expect(model.refPersonales, isNotEmpty);
      expect(model, isA<Application>());
    });

    test('should correctly serialize ApplicationModel back to JSON', () {
      final model = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);
      final json = model.toJson();

      expect(json['id'], model.id);
      expect(json['arrendatario_id'], model.arrendatarioId);
      expect(json['estado'], model.estado);
      expect(json['ingresos_mensuales'], '8500000');
      expect(json['documento_url'], model.documentoUrl);
    });

    test('should serialize for creation using toJsonCreate without metadata IDs', () {
      final model = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);
      final jsonCreate = model.toJsonCreate();

      expect(jsonCreate.containsKey('id'), isFalse);
      expect(jsonCreate.containsKey('created_at'), isFalse);
      expect(jsonCreate.containsKey('updated_at'), isFalse);
      expect(jsonCreate['arrendatario_id'], model.arrendatarioId);
      expect(jsonCreate['ingresos_mensuales'], '8500000');
    });

    test('should correctly deserialize and serialize application with datosContextuales [RF-14, RF-15, RF-16, RF-17]', () {
      final jsonWithContext = Map<String, dynamic>.from(ApplicationFixtures.validPendingApplicationJson)
        ..['datos_contextuales'] = {
          'tipo_categoria': 'residencial',
          'numero_ocupantes': 3,
          'descripcion_familiar': 'Familia de 3 integrantes',
          'tiene_mascotas': true,
          'detalle_mascotas': 'Un perro',
        };

      final model = ApplicationModel.fromJson(jsonWithContext);
      expect(model.datosContextuales, isNotNull);
      expect(model.datosContextuales, isA<ResidentialContextData>());
      final residential = model.datosContextuales as ResidentialContextData;
      expect(residential.numeroOcupantes, equals(3));
      expect(residential.tieneMascotas, isTrue);

      final jsonResult = model.toJson();
      expect(jsonResult['datos_contextuales'], isNotNull);
      expect(jsonResult['datos_contextuales']['tipo_categoria'], equals('residencial'));

      final jsonCreate = model.toJsonCreate();
      expect(jsonCreate['datos_contextuales'], isNotNull);
      expect(jsonCreate['datos_contextuales']['tipo_categoria'], equals('residencial'));
    });
  });
}
