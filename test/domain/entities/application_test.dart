import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application.dart';

void main() {
  group('Application Entity Tests [RF-18.2, RF-18.3, RF-20.2, Constitución 2.3]', () {
    final now = DateTime(2026, 9, 29, 10, 0);

    test('should instantiate Application with contact info for landlord and tenant', () {
      final app = Application(
        id: 'sol-001',
        arrendatarioId: 'usr-tenant',
        arrendadorId: 'usr-landlord',
        propiedadId: 'prop-101',
        estado: 'pendiente',
        createdAt: now,
        updatedAt: now,
        nombreArrendatario: 'Carlos Restrepo',
        telefonoArrendatario: '3124567890',
        nombreArrendador: 'Beatriz Salazar',
        telefonoArrendador: '3009876543',
        tituloPropiedad: 'Apartamento 402',
        direccionPropiedad: 'Calle 45 # 18-32',
        precioRenta: 2100000.0,
      );

      expect(app.id, 'sol-001');
      expect(app.nombreArrendatario, 'Carlos Restrepo');
      expect(app.telefonoArrendatario, '3124567890');
      expect(app.nombreArrendador, 'Beatriz Salazar');
      expect(app.telefonoArrendador, '3009876543');
      expect(app.tituloPropiedad, 'Apartamento 402');
      expect(app.direccionPropiedad, 'Calle 45 # 18-32');
      expect(app.precioRenta, 2100000.0);
    });

    test('copyWith should preserve existing contact fields when not provided', () {
      final app = Application(
        id: 'sol-001',
        arrendatarioId: 'usr-tenant',
        arrendadorId: 'usr-landlord',
        propiedadId: 'prop-101',
        estado: 'pendiente',
        createdAt: now,
        updatedAt: now,
        nombreArrendatario: 'Carlos Restrepo',
        telefonoArrendatario: '3124567890',
        nombreArrendador: 'Beatriz Salazar',
        telefonoArrendador: '3009876543',
      );

      final updated = app.copyWith(estado: 'aceptada');

      expect(updated.estado, 'aceptada');
      expect(updated.nombreArrendatario, 'Carlos Restrepo');
      expect(updated.telefonoArrendatario, '3124567890');
      expect(updated.nombreArrendador, 'Beatriz Salazar');
      expect(updated.telefonoArrendador, '3009876543');
    });

    test('copyWith should update contact fields when explicitly passed', () {
      final app = Application(
        id: 'sol-001',
        arrendatarioId: 'usr-tenant',
        arrendadorId: 'usr-landlord',
        propiedadId: 'prop-101',
        estado: 'pendiente',
        createdAt: now,
        updatedAt: now,
      );

      final updated = app.copyWith(
        telefonoArrendatario: '3159998877',
        nombreArrendador: 'Beatriz Salazar Propietaria',
        telefonoArrendador: '3001112233',
      );

      expect(updated.telefonoArrendatario, '3159998877');
      expect(updated.nombreArrendador, 'Beatriz Salazar Propietaria');
      expect(updated.telefonoArrendador, '3001112233');
    });
  });
}
