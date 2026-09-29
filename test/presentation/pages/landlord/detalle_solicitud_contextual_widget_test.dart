import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';
import 'package:vihomeapp/presentation/pages/landlord/widgets/detalle_solicitud_contextual_card.dart';

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('DetalleSolicitudContextualCard [RF-17.1, RF-17.2]', () {
    testWidgets('renders friendly fallback banner for legacy applications (null contextData)', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const DetalleSolicitudContextualCard(contextData: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Solicitud estándar previa (sin datos contextuales adicionales)'),
        findsOneWidget,
      );
    });

    testWidgets('renders residential family composition and pet information', (tester) async {
      const data = ResidentialContextData(
        numeroOcupantes: 4,
        descripcionFamiliar: 'Familia conformada por padres y dos hijos.',
        tieneMascotas: true,
        detalleMascotas: 'Un perro Golden Retriever',
      );

      await tester.pumpWidget(
        createTestableWidget(
          const DetalleSolicitudContextualCard(contextData: data),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Composición Familiar y Convivencia'), findsOneWidget);
      expect(find.text('4 personas'), findsOneWidget);
      expect(find.text('Familia conformada por padres y dos hijos.'), findsOneWidget);
      expect(find.text('Sí - Un perro Golden Retriever'), findsOneWidget);
    });

    testWidgets('renders individual occupation and guardian info for minors', (tester) async {
      const data = IndividualContextData(
        ocupacion: 'Estudiante',
        entidadLaboralEducativa: 'Universidad de Antioquia',
        esMenorDeEdad: true,
        acudiente: GuardianInfo(
          nombreCompleto: 'Carlos Eduardo Restrepo',
          telefono: '3123456789',
          parentesco: 'Padre/Madre',
        ),
      );

      await tester.pumpWidget(
        createTestableWidget(
          const DetalleSolicitudContextualCard(contextData: data),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ocupación y Solicitante'), findsOneWidget);
      expect(find.text('Estudiante'), findsOneWidget);
      expect(find.text('Universidad de Antioquia'), findsOneWidget);
      expect(find.text('Carlos Eduardo Restrepo'), findsOneWidget);
      expect(find.text('3123456789'), findsOneWidget);
      expect(find.text('Padre/Madre'), findsOneWidget);
    });

    testWidgets('renders commercial business info, NIT and economic activity', (tester) async {
      const data = CommercialContextData(
        razonSocial: 'Cafetería El Grano SAS',
        nit: '901.888.777-3',
        actividadEconomica: 'Comercialización de café y alimentos preparados.',
      );

      await tester.pumpWidget(
        createTestableWidget(
          const DetalleSolicitudContextualCard(contextData: data),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Información Comercial'), findsOneWidget);
      expect(find.text('Cafetería El Grano SAS'), findsOneWidget);
      expect(find.text('901.888.777-3'), findsOneWidget);
      expect(
        find.text('Comercialización de café y alimentos preparados.'),
        findsOneWidget,
      );
    });
  });
}
