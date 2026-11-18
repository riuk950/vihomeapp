import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  final User? _user;
  _FakeAuthProvider({User? user}) : _user = user;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    GuestAccessGuard.resetForTesting();
  });

  tearDown(() {
    GuestAccessGuard.resetForTesting();
  });

  group('GuestAccessGuard', () {
    testWidgets('Retorna true sin navegar cuando el usuario está autenticado (RF-7.1)', (tester) async {
      var loginPushCount = 0;
      var guardResult = false;
      final authProvider = _FakeAuthProvider(
        user: const User(id: 'u1', email: 'a@b.com', role: 'arrendatario'),
      );

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  guardResult = GuestAccessGuard.requireAuth(
                    context,
                    reason: GuestRedirectReason.profile,
                    sourcePath: '/home',
                  );
                },
                child: const Text('TRY_ACTION'),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              loginPushCount++;
              return const Scaffold(body: Text('LOGIN'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.text('TRY_ACTION'));
      await tester.pumpAndSettle();

      expect(guardResult, isTrue);
      expect(loginPushCount, 0);
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('Redirige por push con GuestRedirectContext cuando es invitado y previene doble toque rápido (RF-3.4, RF-4.4)', (tester) async {
      var loginBuildCount = 0;
      GuestRedirectContext? receivedContext;
      final authProvider = _FakeAuthProvider(user: null);

      DateTime fakeNow = DateTime(2026, 11, 18, 12, 0, 0);
      GuestAccessGuard.configureClockForTesting(() => fakeNow);

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  GuestAccessGuard.requireAuth(
                    context,
                    reason: GuestRedirectReason.rentApplication,
                    sourcePath: '/property-details',
                  );
                },
                child: const Text('SOLICITAR'),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              loginBuildCount++;
              receivedContext = state.extra as GuestRedirectContext?;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('BACK'),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Doble toque inmediato dentro de la ventana de debounce (< 350 ms)
      await tester.tap(find.text('SOLICITAR'));
      fakeNow = fakeNow.add(const Duration(milliseconds: 50));
      await tester.tap(find.text('SOLICITAR'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(loginBuildCount, 1);
      expect(receivedContext?.reason, GuestRedirectReason.rentApplication);
      expect(receivedContext?.showRestrictionBanner, isTrue);
      expect(receivedContext?.canReturnToPreviousView, isTrue);

      // Pop regresa exactamente a la vista anterior
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('SOLICITAR'), findsOneWidget);
    });
  });
}
