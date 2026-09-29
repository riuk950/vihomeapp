import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/property_category_resolver.dart';

void main() {
  group('PropertyCategoryResolver [RF-13.1, RF-13.2, CL-14]', () {
    test('should classify residential types accurately (case-insensitive & accents)', () {
      expect(PropertyCategoryResolver.resolve('Casa'), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('apartamento'), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('Apartamento duplex'), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('Finca campestre'), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('CABAÑA'), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('Lote'), equals(PropertyCategory.residential));
    });

    test('should classify individual types accurately (habitaciones, apartaestudios)', () {
      expect(PropertyCategoryResolver.resolve('Habitación'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('habitacion'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('Habitación amoblada'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('Cuarto estudiantil'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('Apartaestudio'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('aparta-estudio'), equals(PropertyCategory.individual));
      expect(PropertyCategoryResolver.resolve('Suite ejecutiva'), equals(PropertyCategory.individual));
    });

    test('should classify commercial types accurately (locales, oficinas, bodegas)', () {
      expect(PropertyCategoryResolver.resolve('Local comercial'), equals(PropertyCategory.commercial));
      expect(PropertyCategoryResolver.resolve('LOCAL'), equals(PropertyCategory.commercial));
      expect(PropertyCategoryResolver.resolve('Oficina'), equals(PropertyCategory.commercial));
      expect(PropertyCategoryResolver.resolve('Bodega industrial'), equals(PropertyCategory.commercial));
    });

    test('should prioritize commercial over residential for mixed types', () {
      expect(PropertyCategoryResolver.resolve('Casa local comercial'), equals(PropertyCategory.commercial));
    });

    test('should fallback to residential for unknown or empty input [CL-14]', () {
      expect(PropertyCategoryResolver.resolve(null), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve(''), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('   '), equals(PropertyCategory.residential));
      expect(PropertyCategoryResolver.resolve('Categoría Inexistente 123'), equals(PropertyCategory.residential));
    });
  });
}
