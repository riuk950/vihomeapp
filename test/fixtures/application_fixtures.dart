/// Fixtures de prueba para Solicitudes Financieras [RF-04, RF-06]
class ApplicationFixtures {
  static const Map<String, dynamic> validPendingApplicationJson = {
    'id': 'app_5e4f2b1a-9c8d-4e7f-1a2b-3c4d5e6f7a8b',
    'arrendatario_id': 'usr_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
    'arrendador_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'propiedad_id': 'prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a',
    'estado': 'Pendiente',
    'empresa': 'Tech Solutions S.A.S.',
    'cargo': 'Ingeniero de Software',
    'tiempo_empleo': '2 años',
    'ingresos_mensuales': '8500000',
    'otros_ingresos': '1000000',
    'documento_url': 'https://storage.vihome.app/applications/app_201/extracto.pdf',
    'ref_personales': [
      {
        'nombre': 'Carlos Gómez',
        'telefono': '3001234567',
        'relacion': 'Familiar',
      }
    ],
    'created_at': '2026-03-17T09:15:00.000Z',
    'updated_at': '2026-03-17T09:15:00.000Z',
  };

  static const Map<String, dynamic> validApprovedApplicationJson = {
    'id': 'app_9a8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d',
    'arrendatario_id': 'usr_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
    'arrendador_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'propiedad_id': 'prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a',
    'estado': 'Aprobada',
    'empresa': 'Tech Solutions S.A.S.',
    'cargo': 'Ingeniero de Software',
    'tiempo_empleo': '2 años',
    'ingresos_mensuales': '8500000',
    'documento_url': 'https://storage.vihome.app/applications/app_202/extracto.pdf',
    'created_at': '2026-03-17T09:15:00.000Z',
    'updated_at': '2026-03-18T10:00:00.000Z',
  };
}
