import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import '../../fixtures/fixtures.dart';

void main() {
  group('PropertyModel Serialization & Domain Entity Tests [RF-02, RF-03, RF-05]', () {
    test('should correctly deserialize valid property JSON into PropertyModel and Property entity', () {
      final json = PropertyFixtures.validApartmentBogotaJson;
      final model = PropertyModel.fromJson(json);

      expect(model.id, json['id']);
      expect(model.arrendadorId, json['arrendador_id']);
      expect(model.tipoPropiedad, json['tipo_propiedad']);
      expect(model.titulo, json['titulo']);
      expect(model.ciudad, json['ciudad']);
      expect(model.precio, json['precio']);
      expect(model.habitaciones, json['habitaciones']);
      expect(model.banos, json['banos']);
      expect(model.publicado, isTrue);
      expect(model.fotos, isNotEmpty);
      expect(model, isA<Property>());
    });

    test('should serialize PropertyModel back to JSON with correct keys', () {
      final model = PropertyModel.fromJson(PropertyFixtures.validHouseMedellinJson);
      final json = model.toJson();

      expect(json['id'], model.id);
      expect(json['tipo_propiedad'], model.tipoPropiedad);
      expect(json['ciudad'], 'Medellín');
      expect(json['precio'], 4500000.0);
      expect(json['fotos'], hasLength(1));
    });
  });
}
