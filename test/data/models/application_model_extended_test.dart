import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_model.dart';

void main() {
  group('ApplicationModel Extended Deserialization & Resilience Tests [RF-18.2, RF-18.3, CL-15, CL-16, QA 1.10, QA 1.11, QA 1.12]', () {
    test('RF-18.2, RF-18.3: Deserializes direct contact and property snapshot fields', () {
      final json = {
        'id': 'sol-100',
        'arrendatario_id': 'usr-t1',
        'arrendador_id': 'usr-l1',
        'propiedad_id': 'prop-p1',
        'estado': 'pendiente',
        'created_at': '2026-09-29T10:00:00.000Z',
        'updated_at': '2026-09-29T10:00:00.000Z',
        'nombre_arrendatario': 'Carlos Alberto Restrepo',
        'telefono_arrendatario': '3124567890',
        'nombre_arrendador': 'Beatriz Eugenia Salazar',
        'telefono_arrendador': '3009876543',
        'titulo_propiedad': 'Apartamento 402 Edificio Los Sauces',
        'direccion_propiedad': 'Calle 45 # 18-32',
        'precio_renta': 2100000.0,
      };

      final model = ApplicationModel.fromJson(json);

      expect(model.id, 'sol-100');
      expect(model.nombreArrendatario, 'Carlos Alberto Restrepo');
      expect(model.telefonoArrendatario, '3124567890');
      expect(model.nombreArrendador, 'Beatriz Eugenia Salazar');
      expect(model.telefonoArrendador, '3009876543');
      expect(model.tituloPropiedad, 'Apartamento 402 Edificio Los Sauces');
      expect(model.direccionPropiedad, 'Calle 45 # 18-32');
      expect(model.precioRenta, 2100000.0);
    });

    test('RF-18.2, RF-18.3: Deserializes nested join maps (arrendatario, arrendador, propiedades)', () {
      final json = {
        'id': 'sol-200',
        'arrendatario_id': 'usr-t2',
        'arrendador_id': 'usr-l2',
        'propiedad_id': 'prop-p2',
        'estado': 'aceptada',
        'created_at': '2026-09-29T11:00:00.000Z',
        'updated_at': '2026-09-29T11:00:00.000Z',
        'arrendatario': {
          'nombre': 'Laura Marcela Gómez',
          'telefono_contacto': '3151234567',
        },
        'arrendador': {
          'nombre': 'Jorge Iván Vélez',
          'telefono': '3109876543',
        },
        'propiedades': {
          'titulo': 'Casa Campestre Los Álamos',
          'direccion': 'Vereda El Hato Km 2',
          'precio_renta': 4500000,
        },
      };

      final model = ApplicationModel.fromJson(json);

      expect(model.nombreArrendatario, 'Laura Marcela Gómez');
      expect(model.telefonoArrendatario, '3151234567');
      expect(model.nombreArrendador, 'Jorge Iván Vélez');
      expect(model.telefonoArrendador, '3109876543');
      expect(model.tituloPropiedad, 'Casa Campestre Los Álamos');
      expect(model.direccionPropiedad, 'Vereda El Hato Km 2');
      expect(model.precioRenta, 4500000.0);
    });

    test('QA 1.10, CL-15: Uses defensive fallback "Inmueble no disponible" when property is deleted or null', () {
      final json = {
        'id': 'sol-300',
        'arrendatario_id': 'usr-t3',
        'arrendador_id': 'usr-l3',
        'propiedad_id': 'prop-deleted',
        'estado': 'pendiente',
        'created_at': '2026-09-29T12:00:00.000Z',
        'updated_at': '2026-09-29T12:00:00.000Z',
        'propiedades': null,
        'titulo_propiedad': null,
      };

      final model = ApplicationModel.fromJson(json);

      expect(model.tituloPropiedad, 'Inmueble no disponible');
    });

    test('QA 1.11, CL-16: Uses defensive fallback "Usuario no disponible" when counterparty user is deleted', () {
      final json = {
        'id': 'sol-400',
        'arrendatario_id': 'usr-deleted-t',
        'arrendador_id': 'usr-deleted-l',
        'propiedad_id': 'prop-p4',
        'estado': 'pendiente',
        'created_at': '2026-09-29T13:00:00.000Z',
        'updated_at': '2026-09-29T13:00:00.000Z',
        'nombre_arrendatario': null,
        'nombre_arrendador': null,
        'arrendatario': null,
        'arrendador': null,
      };

      final model = ApplicationModel.fromJson(json);

      expect(model.nombreArrendatario, 'Usuario no disponible');
      expect(model.nombreArrendador, 'Usuario no disponible');
      expect(model.telefonoArrendatario, isNull);
      expect(model.telefonoArrendador, isNull);
    });

    test('QA 1.12: Tolerates unmapped or unexpected state strings without throwing', () {
      final json = {
        'id': 'sol-500',
        'arrendatario_id': 'usr-t5',
        'arrendador_id': 'usr-l5',
        'propiedad_id': 'prop-p5',
        'estado': 'cancelada_por_inquilino',
        'created_at': '2026-09-29T14:00:00.000Z',
        'updated_at': '2026-09-29T14:00:00.000Z',
      };

      final model = ApplicationModel.fromJson(json);

      expect(model.estado, 'cancelada_por_inquilino');
    });

    test('Serialization to JSON retains contact fields and preserves compatibility', () {
      final model = ApplicationModel.fromJson({
        'id': 'sol-600',
        'arrendatario_id': 'usr-t6',
        'arrendador_id': 'usr-l6',
        'propiedad_id': 'prop-p6',
        'estado': 'aceptada',
        'created_at': '2026-09-29T15:00:00.000Z',
        'updated_at': '2026-09-29T15:00:00.000Z',
        'nombre_arrendatario': 'Carlos Restrepo',
        'telefono_arrendatario': '3124567890',
        'nombre_arrendador': 'Beatriz Salazar',
        'telefono_arrendador': '3009876543',
        'titulo_propiedad': 'Apartamento 402',
      });

      final json = model.toJson();

      expect(json['id'], 'sol-600');
      expect(json['nombre_arrendatario'], 'Carlos Restrepo');
      expect(json['telefono_arrendatario'], '3124567890');
      expect(json['nombre_arrendador'], 'Beatriz Salazar');
      expect(json['telefono_arrendador'], '3009876543');
      expect(json['titulo_propiedad'], 'Apartamento 402');
    });
  });
}
