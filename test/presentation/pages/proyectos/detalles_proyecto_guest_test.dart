import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/domain/entities/constructora.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/project_repository.dart';
import 'package:vihomeapp/domain/usecases/project/get_constructora_usecase.dart';
import 'package:vihomeapp/presentation/pages/proyectos/detalles_proyecto_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';

class _FakeGuestAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  User? get user => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isGuest => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProjectRepo implements ProjectRepository {
  @override
  Future<Constructora> getConstructora(String id) async {
    return const Constructora(
      id: 'const-1',
      nombre: 'Constructora Horizonte',
      nit: '900123456',
      whatsapp: '573001112233',
    );
  }

  @override
  Future<List<Project>> getProjects() async => [];
}

Project _sampleProject() {
  return Project(
    id: 'proj-1',
    constructoraId: 'const-1',
    tipoPropiedad: 'Apartamentos VIS',
    precioDesde: 180000000,
    precioHasta: 250000000,
    habitaciones: 3,
    banos: 2,
    area: 62,
    descripcion: 'Proyecto residencial con zonas verdes.',
    ubicacionPrincipal: 'Norte de Bogotá',
    lat: 4.72,
    lng: -74.04,
    estrato: 4,
    estado: 'En construcción',
    parqueaderos: 1,
    financiacion: true,
    coutaInicial: 30,
    cantidadPisos: 12,
    aplicaSubsidio: true,
    fotos: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
DEBUG_MODE=true
MAPBOX_ACCESS_TOKEN=
ADMOB_BANNER_ID=ca-app-pub-test
API_BASE_URL=https://api.example.com
''');
  });

  setUp(() async {
    GuestAccessGuard.resetForTesting();
    await getIt.reset();
    getIt.registerLazySingleton<GetConstructoraUseCase>(
      () => GetConstructoraUseCase(_FakeProjectRepo()),
    );
  });

  tearDown(() async {
    GuestAccessGuard.resetForTesting();
    await getIt.reset();
  });

  group('DetallesProyectoPage - Rol Invitado (RF-2.3, RF-4.1, RF-4.3, RF-8.4)', () {
    testWidgets('Permite lectura pública y redirige a /login al pulsar Contactar y Compartir', (tester) async {
      GuestRedirectContext? lastRedirect;

      final router = GoRouter(
        initialLocation: '/proyecto-detalle',
        routes: [
          GoRoute(
            path: '/proyecto-detalle',
            builder: (context, state) =>
                DetallesProyectoPage(project: _sampleProject()),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              lastRedirect = state.extra as GuestRedirectContext?;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    GuestAccessGuard.resetDebounce();
                    context.pop();
                  },
                  child: const Text('LOGIN_PROJECT'),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => _FakeGuestAuthProvider(),
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apartamentos VIS'), findsWidgets);
      expect(find.text('Contactar'), findsOneWidget);

      // Pulsar Contactar -> redirige con motivo projectContact
      await tester.tap(find.text('Contactar'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_PROJECT'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.projectContact);

      // Regresar y pulsar Compartir -> redirige con motivo share
      await tester.tap(find.text('LOGIN_PROJECT'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_PROJECT'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.share);
    });
  });
}
