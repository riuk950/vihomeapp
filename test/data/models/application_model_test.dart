import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
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
  });
}
