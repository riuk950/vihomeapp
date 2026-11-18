import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/onboarding/complete_onboarding_usecase.dart';
import 'package:vihomeapp/domain/usecases/onboarding/get_onboarding_status_usecase.dart';
import 'package:vihomeapp/presentation/pages/onboarding/onboarding_page.dart';
import 'package:vihomeapp/presentation/pages/onboarding/widgets/onboarding_header.dart';
import 'package:vihomeapp/presentation/pages/onboarding/widgets/onboarding_slide_card.dart';
import 'package:vihomeapp/presentation/providers/onboarding_provider.dart';

class MockOnboardingRepository implements OnboardingRepository {
  OnboardingCompletionReason? lastReason;
  int? lastStep;
  bool saveSuccess = true;

  @override
  Future<OnboardingState> getOnboardingState() async => OnboardingState.notSeen();

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async {
    lastReason = reason;
    this.lastStep = lastStep;
    return saveSuccess;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockOnboardingRepository mockRepo;
  late OnboardingProvider onboardingProvider;

  setUp(() {
    mockRepo = MockOnboardingRepository();
    onboardingProvider = OnboardingProvider(
      getOnboardingStatusUseCase: GetOnboardingStatusUseCase(mockRepo),
      completeOnboardingUseCase: CompleteOnboardingUseCase(mockRepo),
    );
  });

  GuestRedirectContext? lastLoginExtra;

  Widget buildTestApp({
    Size screenSize = const Size(393, 852),
    VoidCallback? onLoginReached,
  }) {
    lastLoginExtra = null;
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Text('HOME_PAGE_DESTINATION')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            lastLoginExtra = state.extra as GuestRedirectContext?;
            onLoginReached?.call();
            return const Scaffold(body: Text('LOGIN_PAGE_DESTINATION'));
          },
        ),
      ],
    );

    return ChangeNotifierProvider<OnboardingProvider>.value(
      value: onboardingProvider,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('OnboardingPage - Verificación Visual y Funcional (RF-2, RF-3, RF-4, RF-5, RF-6)', () {
    testWidgets('1. Renderizado inicial: Paso 1 muestra contenido, retroceso oculto, Saltar visible y botón Continuar (RF-2)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Título y descripción del paso 1
      expect(find.text('Conecta con tu Espacio Ideal'), findsOneWidget);
      expect(find.textContaining('Encuentra propiedades exclusivas'), findsOneWidget);

      // Botón Saltar visible
      expect(find.text('Saltar'), findsOneWidget);

      // Botón retroceso oculto en el paso 1 (Visibility.visible == false)
      final header = tester.widget<OnboardingHeader>(find.byType(OnboardingHeader));
      expect(header.showBackButton, false);

      // Botón Continuar en paso 1
      expect(find.text('Continuar'), findsOneWidget);

      // Enlace Iniciar Sesión presente
      expect(find.textContaining('Iniciar Sesión'), findsOneWidget);

      // Tarjetas ilustrativas envueltas en IgnorePointer (RF-2.6)
      final slideCards = find.byType(OnboardingSlideCard);
      expect(slideCards, findsWidgets);
      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(of: slideCards.first, matching: find.byType(IgnorePointer)).first,
      );
      expect(ignorePointer.ignoring, true);
    });

    testWidgets('2. Navegación secuencial por los 4 pasos y cambio de CTA a Comenzar Ahora en paso 4 (RF-2.2, RF-2.3, RF-2.5)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Paso 1 -> Avanzar al Paso 2
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Conexión Directa y Transparente'), findsOneWidget);
      final headerPaso2 = tester.widget<OnboardingHeader>(find.byType(OnboardingHeader));
      expect(headerPaso2.showBackButton, true);

      // Paso 2 -> Avanzar al Paso 3
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Contratos Digitales Seguros'), findsOneWidget);

      // Paso 3 -> Avanzar al Paso 4
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Gestión Integral Sin Fricción'), findsOneWidget);
      // En el paso 4 el botón principal cambia a "Comenzar Ahora"
      expect(find.text('Comenzar Ahora'), findsOneWidget);
      expect(find.text('Continuar'), findsNothing);
    });

    testWidgets('3. Botón retroceso superior regresa al paso anterior (RF-3.2)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Ir a paso 2
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Conexión Directa y Transparente'), findsOneWidget);

      // Tocar retroceso
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Debe regresar a paso 1
      expect(find.text('Conecta con tu Espacio Ideal'), findsOneWidget);
    });

    testWidgets('4. Pulsar Comenzar Ahora en paso 4 guarda reason=completed y navega directo a /home en modo invitado (012 RF-1.1)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Avanzar al paso 4
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Pulsar Comenzar Ahora
      await tester.tap(find.text('Comenzar Ahora'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastReason, OnboardingCompletionReason.completed);
      expect(mockRepo.lastStep, 4);
      expect(find.text('HOME_PAGE_DESTINATION'), findsOneWidget);
    });

    testWidgets('5. Pulsar Saltar en cualquier paso guarda reason=skipped y navega directo a /home en modo invitado (012 RF-1.1)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastReason, OnboardingCompletionReason.skipped);
      expect(find.text('HOME_PAGE_DESTINATION'), findsOneWidget);
    });

    testWidgets('6. Pulsar Iniciar Sesión guarda reason=loginShortcut y navega a /login sin banner de restricción (012 RF-1.3)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Iniciar Sesión'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastReason, OnboardingCompletionReason.loginShortcut);
      expect(find.text('LOGIN_PAGE_DESTINATION'), findsOneWidget);
      expect(lastLoginExtra?.reason, GuestRedirectReason.onboardingLoginShortcut);
      expect(lastLoginExtra?.showRestrictionBanner, isFalse);
    });

    testWidgets('7. Error al guardar en almacenamiento local no bloquea la navegación a /home (012 RF-1.2)', (tester) async {
      mockRepo.saveSuccess = false;

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();

      // A pesar del error interno de guardado, el usuario llega a /home en modo invitado
      expect(find.text('HOME_PAGE_DESTINATION'), findsOneWidget);
    });

    testWidgets('8. Diseño responsivo sin RenderFlex overflow en pantalla compacta de 320x568 (RNF-3)', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 568 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Conecta con tu Espacio Ideal'), findsOneWidget);
    });

    testWidgets('9. Diseño responsivo sin RenderFlex overflow en pantalla grande de 430x932 (RNF-3)', (tester) async {
      tester.view.physicalSize = const Size(430 * 3, 932 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Conecta con tu Espacio Ideal'), findsOneWidget);
    });
  });
}
