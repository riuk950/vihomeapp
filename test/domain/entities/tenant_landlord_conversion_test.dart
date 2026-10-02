import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';

void main() {
  group('Tenant and Landlord Entity Conversion Tests', () {
    const tenant = Tenant(
      id: 'user-uuid-123',
      primerNombre: 'Carlos',
      segundoNombre: 'Andrés',
      primerApellido: 'Pérez',
      segundoApellido: 'Gómez',
      documento: '1098765432',
      direccionContacto: 'Carrera 15 # 45 - 20',
      tipoDocumento: 'CC',
      telefonoContacto: '3001234567',
      fcmToken: 'token-abc-123',
    );

    const landlord = Landlord(
      id: 'landlord-uuid-456',
      primerNombre: 'María',
      segundoNombre: null,
      primerApellido: 'Rodríguez',
      segundoApellido: 'Silva',
      documento: '9876543210',
      direccionContacto: 'Calle 100 # 19 - 40',
      tipoDocumento: 'CE',
      telefonoContacto: '3159876543',
      fcmToken: null,
    );

    test('Tenant.toLandlord maps all fields correctly', () {
      final convertedLandlord = tenant.toLandlord();

      expect(convertedLandlord.id, tenant.id);
      expect(convertedLandlord.primerNombre, tenant.primerNombre);
      expect(convertedLandlord.segundoNombre, tenant.segundoNombre);
      expect(convertedLandlord.primerApellido, tenant.primerApellido);
      expect(convertedLandlord.segundoApellido, tenant.segundoApellido);
      expect(convertedLandlord.documento, tenant.documento);
      expect(convertedLandlord.tipoDocumento, tenant.tipoDocumento);
      expect(convertedLandlord.telefonoContacto, tenant.telefonoContacto);
      expect(convertedLandlord.direccionContacto, tenant.direccionContacto);
      expect(convertedLandlord.fcmToken, tenant.fcmToken);
      expect(convertedLandlord.nombre, 'Carlos Pérez');
    });

    test('Tenant.fromLandlord maps all fields correctly', () {
      final convertedTenant = Tenant.fromLandlord(landlord);

      expect(convertedTenant.id, landlord.id);
      expect(convertedTenant.primerNombre, landlord.primerNombre);
      expect(convertedTenant.segundoNombre, isNull);
      expect(convertedTenant.primerApellido, landlord.primerApellido);
      expect(convertedTenant.segundoApellido, landlord.segundoApellido);
      expect(convertedTenant.documento, landlord.documento);
      expect(convertedTenant.tipoDocumento, landlord.tipoDocumento);
      expect(convertedTenant.telefonoContacto, landlord.telefonoContacto);
      expect(convertedTenant.direccionContacto, landlord.direccionContacto);
      expect(convertedTenant.fcmToken, isNull);
      expect(convertedTenant.nombre, 'María Rodríguez');
    });

    test('Landlord.toTenant maps all fields correctly', () {
      final convertedTenant = landlord.toTenant();

      expect(convertedTenant.id, landlord.id);
      expect(convertedTenant.primerNombre, landlord.primerNombre);
      expect(convertedTenant.primerApellido, landlord.primerApellido);
      expect(convertedTenant.documento, landlord.documento);
      expect(convertedTenant.tipoDocumento, landlord.tipoDocumento);
      expect(convertedTenant.telefonoContacto, landlord.telefonoContacto);
      expect(convertedTenant.direccionContacto, landlord.direccionContacto);
    });

    test('Landlord.fromTenant maps all fields correctly', () {
      final convertedLandlord = Landlord.fromTenant(tenant);

      expect(convertedLandlord.id, tenant.id);
      expect(convertedLandlord.primerNombre, tenant.primerNombre);
      expect(convertedLandlord.primerApellido, tenant.primerApellido);
      expect(convertedLandlord.documento, tenant.documento);
      expect(convertedLandlord.tipoDocumento, tenant.tipoDocumento);
      expect(convertedLandlord.telefonoContacto, tenant.telefonoContacto);
      expect(convertedLandlord.direccionContacto, tenant.direccionContacto);
    });

    test('copyWith updates specific fields and preserves others', () {
      final updatedTenant = tenant.copyWith(
        telefonoContacto: '3110000000',
        direccionContacto: 'Avenida Siempre Viva 123',
      );

      expect(updatedTenant.id, tenant.id);
      expect(updatedTenant.primerNombre, tenant.primerNombre);
      expect(updatedTenant.telefonoContacto, '3110000000');
      expect(updatedTenant.direccionContacto, 'Avenida Siempre Viva 123');

      final updatedLandlord = landlord.copyWith(
        primerNombre: 'Ana María',
      );

      expect(updatedLandlord.id, landlord.id);
      expect(updatedLandlord.primerNombre, 'Ana María');
      expect(updatedLandlord.primerApellido, landlord.primerApellido);
    });
  });
}
