# Plan de Tareas (Tasks) - MVP 013: Migración del Paquete Material a material_ui

## Resumen Ejecutivo
- **Objetivo:** Ejecutar la migración completa del paquete de diseño de `package:flutter/material.dart` a `package:material_ui/material_ui.dart` preservando 100% la paridad visual, funcional y arquitectónica.
- **Trazabilidad:** Basado en `specs/013-vihomeapp-mvp/spec.md` y `specs/013-vihomeapp-mvp/plan.md`.
- **HU Notion:** `41c8442e-3f49-81a8-bb02-dd64bd9b9d87` (Base de datos: `Tasksk`).

---

## Tareas de Implementación

### Fase 1: Incorporación de Dependencia y Resolución de Paquetes
- [x] **TASK-013-01**: Modificar `pubspec.yaml` para añadir `material_ui: ^1.0.0` en `dependencies` [RF-1.1, RNF-4.1].
- [x] **TASK-013-02**: Ejecutar `flutter pub get` y verificar resolución sin advertencias ni conflictos de dependencias transitivas [RF-1.1, RNF-5.1].

### Fase 2: Migración de Imports en Código de Producción (`lib/`)
- [x] **TASK-013-03**: Probar si `dart fix --apply --code=migrate_design_widgets` está disponible en el SDK local; de lo contrario, ejecutar reemplazo sistemático de imports [RF-2.1].
- [x] **TASK-013-04**: Reemplazar `import 'package:flutter/material.dart';` por `import 'package:material_ui/material_ui.dart';` en los 64 archivos detectados en `lib/` [RF-2.1, RNF-1.1].
- [x] **TASK-013-05**: Verificar que no queden referencias residuales en `lib/` mediante búsqueda textual [RF-2.2].

### Fase 3: Migración de Imports en Suite de Pruebas (`test/`)
- [x] **TASK-013-06**: Reemplazar `import 'package:flutter/material.dart';` por `import 'package:material_ui/material_ui.dart';` en los 42 archivos detectados en `test/` [RF-2.1, RNF-3.1].
- [x] **TASK-013-07**: Auditar que no queden imports de `package:flutter/material.dart` en `test/` [RF-2.2].

### Fase 4: Pruebas de Paridad de Tema y Guarda Anti-Regresión
- [x] **TASK-013-08**: Crear prueba unitaria y de auditoría estática `test/core/theme/app_theme_material_ui_test.dart` [RF-3.1, RF-6.1, RNF-1.1]:
  - Verificar que `AppTheme.ligthTheme` instancia ThemeData desde `material_ui`.
  - Validar valores de token: `primary = Color(0xFF0E4E82)`, `scaffoldBackground = Color(0xFFF6F7F8)`, `useMaterial3 = true`.
  - Validar que 0 archivos en `lib/` y `test/` mantengan `package:flutter/material.dart`.

### Fase 5: Análisis Estático y Resolución de Incompatibilidades
- [x] **TASK-013-09**: Ejecutar `flutter analyze` y asegurar cero errores (0 issues) [RF-6.2, RNF-2.1].
- [x] **TASK-013-10**: Si surgen conflictos con widgets de terceros, implementar o verificar `MaterialUiCompatibilityBridge` [RF-4.1, RF-4.2] *(N/A: API 100% compatible y transparente)*.

### Fase 6: Verificación de Regresión en Pruebas Unitarias y de Widgets
- [x] **TASK-013-11**: Ejecutar `flutter test` de toda la suite (esperado: >= 412 pruebas pasando, 0 fallos) [RF-5.1, RF-5.2, RNF-3.1] *(Resultado: 416/416 pruebas pasando en verde)*.

### Fase 7: Verificación de Compilación y Empaquetado Android
- [x] **TASK-013-12**: Ejecutar `flutter build apk --flavor dev --target lib/env/main.dev.dart --debug` [RF-6.3, RNF-2.1] *(Exitoso: app-dev-debug.apk en 18.8s)*.
- [x] **TASK-013-13**: Ejecutar `flutter build apk --flavor prod --target lib/env/main.prod.dart --debug` [RF-6.3, RNF-2.1] *(Exitoso: app-prod-debug.apk en 26.3s)*.

### Fase 8: Control de Versiones y Cierre en Notion
- [ ] **TASK-013-14**: Realizar commit en Git con mensaje convencional `feat(ui): migrar diseno base de flutter material a material_ui package` [RNF-4.1].
- [ ] **TASK-013-15**: Actualizar estado en Notion de la HU (`41c8442e-3f49-81a8-bb02-dd64bd9b9d87`) a `Finalizado` con bitácora de entrega.
