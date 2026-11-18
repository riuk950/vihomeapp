import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/domain/usecases/landlord/get_landlord_profile_usecase.dart';
import 'package:vihomeapp/presentation/pages/propiedades/detalles_propiedades_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

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

class _FakeTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  bool get isVerified => false;

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAdManager implements AdManager {
  @override
  void showInterstitialAd({required bool isPremium}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingLandlordRepo implements LandlordRepository {
  @override
  Future<Either<Failure, Landlord>> getLandlordProfile(String userId) async {
    return const Left(ServerFailure('Acceso restringido o datos incompletos'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockReviewRepo implements ReviewRepository {
  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async =>
      UserReputation(
        userId: userId,
        averageRating: 4.7,
        totalReviews: 8,
        isVerified: true,
      );

  @override
  Future<List<Review>> getUserReviews(String userId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Property _sampleProperty({String estado = 'arriendo'}) {
  return Property(
    id: 'prop-guest-1',
    arrendadorId: 'landlord-1',
    titulo: 'Apartamento Luminoso Chapinero',
    descripcion: '',
    tipoPropiedad: 'Apartamento',
    estado: estado,
    precio: 2200000,
    habitaciones: 2,
    banos: 2,
    metrosCuadrados: 75,
    direccion: 'Calle 50 # 7-10',
    ciudad: 'Bogotá',
    lat: 4.64,
    lng: -74.06,
    fotos: const [],
    amenidades: const ['Parqueadero', 'Gimnasio'],
    publicado: true,
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
    getIt.registerLazySingleton<AdManager>(() => _FakeAdManager());
    getIt.registerLazySingleton<GetLandlordProfileUseCase>(
      () => GetLandlordProfileUseCase(_FailingLandlordRepo()),
    );
  });

  tearDown(() async {
    GuestAccessGuard.resetForTesting();
    await getIt.reset();
  });

  group('DetallesPropiedadesPage - Rol Invitado (RF-2.3, RF-4.1..RF-4.4, RF-8.4)', () {
    testWidgets('Renderiza con user=null y datos incompletos, y Solicitar Arriendo redirige a /login sin diálogo de perfil incompleto', (tester) async {
      GuestRedirectContext? lastRedirect;
      final router = GoRouter(
        initialLocation: '/property-details',
        routes: [
          GoRoute(
            path: '/property-details',
            builder: (context, state) => DetallesPropiedadesPage(
              property: _sampleProperty(estado: 'arriendo'),
              user: null,
            ),
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
                  child: const Text('LOGIN_FOR_GUEST'),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
                create: (_) => _FakeGuestAuthProvider()),
            ChangeNotifierProvider<TenantProvider>(
                create: (_) => _FakeTenantProvider()),
            ChangeNotifierProvider<ApplicationProvider>(
                create: (_) => _FakeApplicationProvider()),
            ChangeNotifierProvider<ReviewProvider>(
                create: (_) => ReviewProvider(_MockReviewRepo())),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Información pública visible aun sin fotos ni perfil del propietario (RF-2.3, RF-8.4)
      expect(find.text('Apartamento Luminoso Chapinero'), findsOneWidget);
      expect(find.text('Solicitar Arriendo'), findsOneWidget);

      // Pulsar Solicitar Arriendo -> redirige directo a /login (RF-4.2)
      await tester.tap(find.text('Solicitar Arriendo'));
      await tester.pumpAndSettle();

      expect(find.text('Perfil incompleto'), findsNothing);
      expect(find.text('LOGIN_FOR_GUEST'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.rentApplication);

      // Regresar al detalle y probar Compartir -> redirige con motivo share (RF-4.3)
      await tester.tap(find.text('LOGIN_FOR_GUEST'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_FOR_GUEST'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.share);
    });

    testWidgets('En propiedad en venta, pulsar Contactar por WhatsApp como invitado redirige a /login (RF-4.1, RF-4.3)', (tester) async {
      GuestRedirectContext? lastRedirect;
      final router = GoRouter(
        initialLocation: '/property-details',
        routes: [
          GoRoute(
            path: '/property-details',
            builder: (context, state) => DetallesPropiedadesPage(
              property: _sampleProperty(estado: 'venta'),
              user: null,
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              lastRedirect = state.extra as GuestRedirectContext?;
              return const Scaffold(body: Text('LOGIN_WHATSAPP'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
                create: (_) => _FakeGuestAuthProvider()),
            ChangeNotifierProvider<TenantProvider>(
                create: (_) => _FakeTenantProvider()),
            ChangeNotifierProvider<ApplicationProvider>(
                create: (_) => _FakeApplicationProvider()),
            ChangeNotifierProvider<ReviewProvider>(
                create: (_) => ReviewProvider(_MockReviewRepo())),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final whatsappBtn = find.text('Contactar por WhatsApp');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      await tester.ensureVisible(whatsappBtn);
      await tester.tap(whatsappBtn);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_WHATSAPP'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.whatsappContact);
    });
  });
}
