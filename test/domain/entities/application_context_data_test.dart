import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';

void main() {
  group('ApplicationContextData [RF-13.2, RF-14, RF-15, RF-16]', () {
    test('ResidentialContextData should hold immutable values and support equality', () {
      const data1 = ResidentialContextData(
        numeroOcupantes: 3,
        descripcionFamiliar: 'Familia con un hijo',
        tieneMascotas: true,
        detalleMascotas: 'Un gato persa',
      );

      const data2 = ResidentialContextData(
        numeroOcupantes: 3,
        descripcionFamiliar: 'Familia con un hijo',
        tieneMascotas: true,
        detalleMascotas: 'Un gato persa',
      );

      expect(data1, equals(data2));
      expect(data1.numeroOcupantes, equals(3));
      expect(data1.tieneMascotas, isTrue);
      expect(data1.detalleMascotas, equals('Un gato persa'));
    });

    test('IndividualContextData with GuardianInfo should hold immutable values and support equality', () {
      const guardian = GuardianInfo(
        nombreCompleto: 'Martha Gómez',
        telefono: '3104567890',
        parentesco: 'Madre',
      );

      const data = IndividualContextData(
        ocupacion: 'Estudiante',
        entidadLaboralEducativa: 'Universidad Nacional',
        esMenorDeEdad: true,
        acudiente: guardian,
      );

      expect(data.ocupacion, equals('Estudiante'));
      expect(data.esMenorDeEdad, isTrue);
      expect(data.acudiente, equals(guardian));
      expect(data.acudiente?.nombreCompleto, equals('Martha Gómez'));
    });

    test('CommercialContextData should hold commercial fields correctly', () {
      const data = CommercialContextData(
        razonSocial: 'Café Origen SAS',
        nit: '901345678-2',
        actividadEconomica: 'Venta de café especial',
      );

      expect(data.razonSocial, equals('Café Origen SAS'));
      expect(data.nit, equals('901345678-2'));
      expect(data.actividadEconomica, equals('Venta de café especial'));
    });

    test('Sealed pattern matching should exhaustively match all 3 types', () {
      final List<ApplicationContextData> items = [
        const ResidentialContextData(
          numeroOcupantes: 2,
          descripcionFamiliar: 'Pareja',
          tieneMascotas: false,
        ),
        const IndividualContextData(
          ocupacion: 'Empleado',
          entidadLaboralEducativa: 'Tech Inc',
          esMenorDeEdad: false,
        ),
        const CommercialContextData(
          razonSocial: 'Tienda ABC',
          nit: '123456789',
          actividadEconomica: 'Comercio',
        ),
      ];

      final types = items.map((item) {
        return switch (item) {
          ResidentialContextData() => 'residential',
          IndividualContextData() => 'individual',
          CommercialContextData() => 'commercial',
        };
      }).toList();

      expect(types, equals(['residential', 'individual', 'commercial']));
    });
  });
}
