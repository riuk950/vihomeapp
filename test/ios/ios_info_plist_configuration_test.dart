import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS Platform Configuration Tests (Info.plist & Podfile)', () {
    test('ios/Runner/Info.plist must contain all required Apple & Google privacy keys', () {
      final file = File('ios/Runner/Info.plist');
      expect(file.existsSync(), isTrue, reason: 'Info.plist file must exist');

      final content = file.readAsStringSync();

      // 1. Photo Library Permission (Required for FilePicker with images/documents)
      expect(content.contains('<key>NSPhotoLibraryUsageDescription</key>'), isTrue);
      expect(content.contains('galería'), isTrue);

      // 2. Camera Permission
      expect(content.contains('<key>NSCameraUsageDescription</key>'), isTrue);
      expect(content.contains('cámara'), isTrue);

      // 3. Google Mobile Ads (Required to prevent iOS launch crash)
      expect(content.contains('<key>GADApplicationIdentifier</key>'), isTrue);
      expect(content.contains('ca-app-pub-'), isTrue);
      expect(content.contains('<key>SKAdNetworkItems</key>'), isTrue);

      // 4. External URL and Contact Schemes
      expect(content.contains('<key>LSApplicationQueriesSchemes</key>'), isTrue);
      expect(content.contains('<string>whatsapp</string>'), isTrue);
      expect(content.contains('<string>https</string>'), isTrue);
      expect(content.contains('<string>tel</string>'), isTrue);
      expect(content.contains('<string>mailto</string>'), isTrue);
      expect(content.contains('<string>sms</string>'), isTrue);

      // 5. Location Usage Description
      expect(content.contains('<key>NSLocationWhenInUseUsageDescription</key>'), isTrue);
    });

    test('ios/Podfile must define platform :ios, 15.0 and permission_handler preprocessor macros', () {
      final file = File('ios/Podfile');
      expect(file.existsSync(), isTrue, reason: 'Podfile must exist');

      final content = file.readAsStringSync();

      // Platform deployment alignment
      expect(content.contains("platform :ios, '15.0'"), isTrue);
      expect(content.contains("IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'"), isTrue);

      // Permission macros for permission_handler
      expect(content.contains('PERMISSION_LOCATION=1'), isTrue);
      expect(content.contains('PERMISSION_PHOTOS=1'), isTrue);
      expect(content.contains('PERMISSION_CAMERA=1'), isTrue);
    });
  });
}
