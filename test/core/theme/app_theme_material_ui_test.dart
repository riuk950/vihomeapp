import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

void main() {
  group('AppTheme Material UI Parity and Integrity Tests', () {
    test('AppTheme.ligthTheme preserves Material 3 and brand tokens using material_ui', () {
      final theme = AppTheme.ligthTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.primaryColor, const Color(0xFF0E4E82));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F7F8));
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.dialogTheme.backgroundColor, const Color(0xFFF6F7F8));
      expect(theme.appBarTheme.backgroundColor, const Color(0xFFF6F7F8));
    });

    test('AppTheme.darkTheme preserves base brand tokens using material_ui', () {
      final theme = AppTheme.darkTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.primaryColor, const Color(0xFF0E4E82));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F7F8));
    });

    test('Zero legacy flutter/material.dart imports remain across lib/ and test/', () {
      final legacyImport = "import 'package:flutter/material.dart';";
      final legacyRawPackage = 'package:flutter/material.dart';

      final scannedDirs = [Directory('lib'), Directory('test')];
      final filesWithLegacyImport = <String>[];

      for (final dir in scannedDirs) {
        if (!dir.existsSync()) continue;
        final entities = dir.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File &&
              entity.path.endsWith('.dart') &&
              !entity.path.endsWith('app_theme_material_ui_test.dart')) {
            final content = entity.readAsStringSync();
            if (content.contains(legacyImport) || content.contains(legacyRawPackage)) {
              filesWithLegacyImport.add(entity.path);
            }
          }
        }
      }

      expect(
        filesWithLegacyImport,
        isEmpty,
        reason: 'Archivos encontrados con el paquete legado: $filesWithLegacyImport',
      );
    });

    test('Production entry points and core theme import material_ui', () {
      final keyFiles = [
        'lib/core/theme/app_theme.dart',
        'lib/app/app.dart',
        'lib/core/router/app_router.dart',
      ];

      for (final filePath in keyFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: 'El archivo $filePath debe existir.');
        final content = file.readAsStringSync();
        expect(
          content.contains("import 'package:material_ui/material_ui.dart';"),
          isTrue,
          reason: 'El archivo $filePath debe importar package:material_ui/material_ui.dart',
        );
      }
    });
  });
}
