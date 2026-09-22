/// Fixtures de prueba para Inmuebles y Propiedades [RF-02, RF-03, RF-05]
class PropertyFixtures {
  static const Map<String, dynamic> validApartmentBogotaJson = {
    'id': 'prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a',
    'arrendador_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'tipo_propiedad': 'apartamento',
    'titulo': 'Apartamento moderno en Chapinero Alto',
    'direccion': 'Calle 65 # 4-20',
    'ciudad': 'Bogotá',
    'descripcion': 'Hermoso apartamento con vista panorámica, 2 habitaciones y balcón.',
    'precio': 2800000.0,
    'precio_renta': 2800000.0,
    'precio_venta': null,
    'habitaciones': 2,
    'banos': 2,
    'metros_cuadrados': 75.5,
    'lat': 4.6482837,
    'lng': -74.0597321,
    'publicado': true,
    'estado': 'Disponible',
    'fotos': [
      'https://storage.vihome.app/properties/prop_8f3a_01.jpg',
      'https://storage.vihome.app/properties/prop_8f3a_02.jpg'
    ],
    'created_at': '2026-03-16T14:00:00.000Z',
    'updated_at': '2026-03-16T14:00:00.000Z',
  };

  static const Map<String, dynamic> validHouseMedellinJson = {
    'id': 'prop_9a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d',
    'arrendador_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'tipo_propiedad': 'casa',
    'titulo': 'Casa campestre en El Poblado',
    'direccion': 'Carrera 25 # 10-50',
    'ciudad': 'Medellín',
    'descripcion': 'Casa amplia con jardín y terraza.',
    'precio': 4500000.0,
    'precio_renta': 4500000.0,
    'precio_venta': null,
    'habitaciones': 4,
    'banos': 3,
    'metros_cuadrados': 180.0,
    'lat': 6.2087853,
    'lng': -75.5654321,
    'publicado': true,
    'estado': 'Disponible',
    'fotos': [
      'https://storage.vihome.app/properties/prop_casa_01.jpg'
    ],
    'created_at': '2026-03-16T15:00:00.000Z',
    'updated_at': '2026-03-16T15:00:00.000Z',
  };

  static const Map<String, dynamic> invalidPropertyMissingPhotosJson = {
    'id': 'prop_no_photos',
    'arrendador_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'tipo_propiedad': 'apartamento',
    'titulo': 'Propiedad sin fotos',
    'direccion': 'Calle 10 # 5-20',
    'ciudad': 'Cali',
    'descripcion': 'Sin descripción',
    'precio': 1500000.0,
    'habitaciones': 1,
    'banos': 1,
    'metros_cuadrados': 40.0,
    'lat': 3.4516,
    'lng': -76.5320,
    'publicado': true,
    'estado': 'Disponible',
    'fotos': <String>[],
    'created_at': '2026-03-16T15:00:00.000Z',
    'updated_at': '2026-03-16T15:00:00.000Z',
  };
}
