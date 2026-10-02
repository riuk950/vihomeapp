import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/presentation/pages/navegation/mapa_page.dart';

void main() {
  group('AppRouter /mapa Route Parsing Tests [RF-42.3, RF-43.1, DT-1]', () {
    testWidgets('should build MapaPage with tipo="proyectos" from queryParameters',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/mapa?tipo=proyectos',
        routes: [
          GoRoute(
            path: '/mapa',
            name: 'mapa',
            builder: (context, state) {
              final tipo = state.uri.queryParameters['tipo'] ??
                  (state.extra is Map
                      ? (state.extra as Map)['tipo'] as String?
                      : null);
              return MapaPage(tipo: tipo);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      final mapaPageFinder = find.byType(MapaPage);
      expect(mapaPageFinder, findsOneWidget);

      final mapaPage = tester.widget<MapaPage>(mapaPageFinder);
      expect(mapaPage.tipo, equals('proyectos'));
    });

    testWidgets('should build MapaPage with tipo=null when no query parameter is provided',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/mapa',
        routes: [
          GoRoute(
            path: '/mapa',
            name: 'mapa',
            builder: (context, state) {
              final tipo = state.uri.queryParameters['tipo'] ??
                  (state.extra is Map
                      ? (state.extra as Map)['tipo'] as String?
                      : null);
              return MapaPage(tipo: tipo);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      final mapaPageFinder = find.byType(MapaPage);
      expect(mapaPageFinder, findsOneWidget);

      final mapaPage = tester.widget<MapaPage>(mapaPageFinder);
      expect(mapaPage.tipo, isNull);
    });

    testWidgets('should build MapaPage with tipo from extra Map',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.push('/mapa', extra: {'tipo': 'proyectos'});
                },
                child: const Text('Go to map'),
              ),
            ),
          ),
          GoRoute(
            path: '/mapa',
            name: 'mapa',
            builder: (context, state) {
              final tipo = state.uri.queryParameters['tipo'] ??
                  (state.extra is Map
                      ? (state.extra as Map)['tipo'] as String?
                      : null);
              return MapaPage(tipo: tipo);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.text('Go to map'));
      await tester.pumpAndSettle();

      final mapaPageFinder = find.byType(MapaPage);
      expect(mapaPageFinder, findsOneWidget);

      final mapaPage = tester.widget<MapaPage>(mapaPageFinder);
      expect(mapaPage.tipo, equals('proyectos'));
    });
  });
}
