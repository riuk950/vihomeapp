import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/utils/external_contact_launcher.dart';

void main() {
  group('ExternalContactLauncher', () {
    test('RF-20.2, QA 1.1: buildPhoneUri generates valid tel: URI', () {
      final uri = ExternalContactLauncher.buildPhoneUri('312 456 7890');
      expect(uri.scheme, 'tel');
      expect(uri.path, '3124567890');
    });

    test('RF-20.2, QA 1.17: buildWhatsAppUri generates valid wa.me URI with message', () {
      const message = 'Hola Carlos, te contacto desde ViHome';
      final uri = ExternalContactLauncher.buildWhatsAppUri(
        '3124567890',
        message: message,
      );
      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/573124567890');
      expect(uri.queryParameters['text'], message);
    });

    test('QA 1.17: buildWhatsAppDefaultMessage creates standardized greeting', () {
      final message = ExternalContactLauncher.buildWhatsAppDefaultMessage(
        recipientName: 'Carlos Restrepo',
        propertyTitle: 'Apartamento 402',
      );
      expect(
        message,
        'Hola Carlos Restrepo, te contacto desde ViHome respecto a la postulación para el inmueble Apartamento 402',
      );
    });

    test('RF-20.2: launchPhone invokes launcher with tel: URI and returns true on success', () async {
      Uri? launchedUri;
      final success = await ExternalContactLauncher.launchPhone(
        '3009876543',
        launcher: (uri, {LaunchMode? mode}) async {
          launchedUri = uri;
          return true;
        },
      );

      expect(success, isTrue);
      expect(launchedUri?.scheme, 'tel');
      expect(launchedUri?.path, '3009876543');
    });

    test('QA 1.4, QA 1.13: launchPhone handles exception safely returning false', () async {
      final success = await ExternalContactLauncher.launchPhone(
        '3009876543',
        launcher: (uri, {LaunchMode? mode}) async {
          throw Exception('ActivityNotFoundException');
        },
      );

      expect(success, isFalse);
    });

    test('RF-20.2: launchWhatsApp invokes launcher with externalApplication mode', () async {
      Uri? launchedUri;
      LaunchMode? usedMode;

      final success = await ExternalContactLauncher.launchWhatsApp(
        '3124567890',
        message: 'Hola',
        launcher: (uri, {LaunchMode? mode}) async {
          launchedUri = uri;
          usedMode = mode;
          return true;
        },
      );

      expect(success, isTrue);
      expect(launchedUri?.host, 'wa.me');
      expect(usedMode, LaunchMode.externalApplication);
    });

    test('QA 1.4, QA 1.13: launchWhatsApp handles error safely returning false', () async {
      final success = await ExternalContactLauncher.launchWhatsApp(
        '3124567890',
        launcher: (uri, {LaunchMode? mode}) async {
          return false;
        },
      );

      expect(success, isFalse);
    });

    test('copyToClipboard saves text using provided handler', () async {
      String? copiedText;
      await ExternalContactLauncher.copyToClipboard(
        '3124567890',
        clipboardSetter: (text) async {
          copiedText = text;
        },
      );

      expect(copiedText, '3124567890');
    });
  });
}
