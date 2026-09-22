/// Fixtures de prueba para Usuario y Perfil [RF-01]
class UserFixtures {
  static const Map<String, dynamic> validLandlordJson = {
    'id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'email': 'carlos.arrendador@vihome.app',
    'name': 'Carlos Mendoza',
    'phone': '+573001234567',
    'role': 'landlord',
    'created_at': '2026-03-15T10:30:00.000Z',
  };

  static const Map<String, dynamic> validTenantJson = {
    'id': 'usr_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
    'email': 'maria.arrendataria@vihome.app',
    'name': 'María Gómez',
    'phone': '+573119876543',
    'role': 'tenant',
    'created_at': '2026-03-15T11:00:00.000Z',
  };

  static const Map<String, dynamic> invalidUserMissingEmailJson = {
    'id': 'usr_invalid',
    'name': 'Usuario Sin Email',
    'role': 'tenant',
  };
}
