import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_filter_bar.dart';

void main() {
  Widget buildTestWidget({
    required String currentFilter,
    required ValueChanged<String> onFilterSelected,
    int totalCount = 0,
    int pendingCount = 0,
    int acceptedCount = 0,
    int rejectedCount = 0,
    double width = 400,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SolicitudesFilterBar(
              currentFilter: currentFilter,
              onFilterSelected: onFilterSelected,
              totalCount: totalCount,
              pendingCount: pendingCount,
              acceptedCount: acceptedCount,
              rejectedCount: rejectedCount,
            ),
          ),
        ),
      ),
    );
  }

  group('SolicitudesFilterBar (RF-21.1, RF-21.2, QA 1.17, RNF-14)', () {
    testWidgets('debe renderizar los 4 chips con sus contadores numéricos respectivos',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentFilter: 'Todas',
          onFilterSelected: (_) {},
          totalCount: 15,
          pendingCount: 6,
          acceptedCount: 5,
          rejectedCount: 4,
        ),
      );

      // Verificamos que se muestren los textos de los 4 filtros con sus insignias de conteo
      expect(find.text('Todas (15)'), findsOneWidget);
      expect(find.text('Pendientes (6)'), findsOneWidget);
      expect(find.text('Aceptadas (5)'), findsOneWidget);
      expect(find.text('Rechazadas (4)'), findsOneWidget);
    });

    testWidgets('debe reflejar el estado seleccionado en el chip correspondiente',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentFilter: 'Pendientes',
          onFilterSelected: (_) {},
          totalCount: 10,
          pendingCount: 3,
          acceptedCount: 4,
          rejectedCount: 3,
        ),
      );

      // Buscamos los ChoiceChips o FilterChips
      final chipFinder = find.byType(ChoiceChip);
      expect(chipFinder, findsNWidgets(4));

      final todasChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Todas (10)'),
      );
      final pendientesChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Pendientes (3)'),
      );
      final aceptadasChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Aceptadas (4)'),
      );
      final rechazadasChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Rechazadas (3)'),
      );

      expect(todasChip.selected, isFalse);
      expect(pendientesChip.selected, isTrue);
      expect(aceptadasChip.selected, isFalse);
      expect(rechazadasChip.selected, isFalse);
    });

    testWidgets('debe disparar onFilterSelected con la clave correcta al presionar un chip',
        (tester) async {
      String? selectedFilter;

      await tester.pumpWidget(
        buildTestWidget(
          currentFilter: 'Todas',
          onFilterSelected: (val) => selectedFilter = val,
          totalCount: 5,
          pendingCount: 2,
          acceptedCount: 2,
          rejectedCount: 1,
        ),
      );

      // Tocamos el chip de Pendientes
      final pendientesFinder = find.byKey(const Key('filter_chip_pendientes'));
      await tester.ensureVisible(pendientesFinder);
      await tester.tap(pendientesFinder);
      await tester.pumpAndSettle();

      expect(selectedFilter, equals('Pendientes'));

      // Tocamos el chip de Aceptadas
      final aceptadasFinder = find.byKey(const Key('filter_chip_aceptadas'));
      await tester.ensureVisible(aceptadasFinder);
      await tester.tap(aceptadasFinder);
      await tester.pumpAndSettle();

      expect(selectedFilter, equals('Aceptadas'));

      // Tocamos el chip de Rechazadas
      final rechazadasFinder = find.byKey(const Key('filter_chip_rechazadas'));
      await tester.ensureVisible(rechazadasFinder);
      await tester.tap(rechazadasFinder);
      await tester.pumpAndSettle();

      expect(selectedFilter, equals('Rechazadas'));
    });

    testWidgets('debe tolerar mayúsculas y minúsculas en currentFilter',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentFilter: 'aceptadas', // En minúscula
          onFilterSelected: (_) {},
          totalCount: 1,
          pendingCount: 0,
          acceptedCount: 1,
          rejectedCount: 0,
        ),
      );

      final aceptadasChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Aceptadas (1)'),
      );
      expect(aceptadasChip.selected, isTrue);
    });

    testWidgets('no debe generar overflow visual en pantallas ultra-estrechas de 320 px (RNF-12)',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentFilter: 'Todas',
          onFilterSelected: (_) {},
          totalCount: 999,
          pendingCount: 300,
          acceptedCount: 400,
          rejectedCount: 299,
          width: 320, // Resolución mínima móvil
        ),
      );

      // Verificamos que no haya excepciones de RenderFlex overflow
      expect(tester.takeException(), isNull);

      // Verificamos que todos los chips existan y puedan ser desplazados horizontalmente
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.text('Todas (999)'), findsOneWidget);
    });
  });
}
