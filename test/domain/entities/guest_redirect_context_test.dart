import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';

void main() {
  group('GuestRedirectContext & GuestRedirectReason', () {
    test('Todos los motivos restringidos muestran banner con mensaje en español (RF-3.2, RF-4.2, RF-4.3, RF-5.1, RNF-4)', () {
      for (final reason in GuestRedirectReason.values) {
        final ctx = GuestRedirectContext.fromReason(
          reason,
          sourcePath: '/property-details',
        );
        if (reason == GuestRedirectReason.onboardingLoginShortcut) {
          expect(ctx.showRestrictionBanner, isFalse);
          expect(ctx.bannerMessage, isNull);
        } else {
          expect(ctx.showRestrictionBanner, isTrue);
          expect(ctx.bannerMessage, isNotNull);
          expect(ctx.bannerMessage!.trim(), isNotEmpty);
        }
      }
    });

    test('onboardingShortcut configura showRestrictionBanner=false y canReturnToPreviousView=false (RF-1.3, RF-6.3)', () {
      final ctx = GuestRedirectContext.onboardingShortcut();
      expect(ctx.reason, GuestRedirectReason.onboardingLoginShortcut);
      expect(ctx.showRestrictionBanner, isFalse);
      expect(ctx.bannerMessage, isNull);
      expect(ctx.sourcePath, '/onboarding');
      expect(ctx.canReturnToPreviousView, isFalse);
    });

    test('Serialización toJson y fromJson es lossless para todos los motivos', () {
      for (final reason in GuestRedirectReason.values) {
        final original = GuestRedirectContext.fromReason(
          reason,
          sourcePath: '/home',
        );
        final decoded = GuestRedirectContext.fromJson(original.toJson());
        expect(decoded, equals(original));
      }
    });

    test('fromWireValue ante valor desconocido o nulo retorna respaldo seguro privateRoute', () {
      expect(
        GuestRedirectReason.fromWireValue(null),
        GuestRedirectReason.privateRoute,
      );
      expect(
        GuestRedirectReason.fromWireValue('unknown_reason'),
        GuestRedirectReason.privateRoute,
      );
      expect(
        GuestRedirectReason.fromWireValue('rent_application'),
        GuestRedirectReason.rentApplication,
      );
      expect(
        GuestRedirectReason.fromWireValue('session_expired'),
        GuestRedirectReason.sessionExpired,
      );
    });
  });
}
