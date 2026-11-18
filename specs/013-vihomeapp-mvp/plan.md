# Plan Técnico de Implementación: Migración de `package:flutter/material.dart` a `material_ui`

**Especificación de referencia:** `specs/013-vihomeapp-mvp/spec.md`
**Constitución de referencia:** `docs/constitution.md`
**HU en Notion:** `HU: Migración del Paquete material (Flutter SDK) a material_ui`

---

## 0. Resultado de Verificación Previa de Prerrequisitos (`RF-1.1` / `RF-1.2`)

Verificación ejecutada en el entorno local antes de modificar cualquier archivo:

| Parámetro | Valor verificado | Resultado |
| :--- | :--- | :---: |
| **Flutter SDK instalado** | `Flutter 3.44.0` (channel `stable`, rev. `559ffa3f75`) | ✅ Compatible |
| **Dart SDK instalado** | `Dart 3.12.0` | ✅ Compatible con `material_ui ^1.0.0` (`1.2.0`) |
| **Paquete oficial en pub.dev** | `material_ui` (publisher `flutter.dev`, última `1.11.1`) | ✅ Disponible |
| **Dry-run `material_ui` sin versión** | Resolvía `0.0.1` (placeholder pre-desacoplamiento) | ⚠️ Evitar |
| **Dry-run `material_ui:^1.11.1`** | Exit `65` — `material_ui >=1.4.0` exige `Dart >=3.13.0` | ⚠️ Requiere upgrade SDK |
| **Dry-run `material_ui:^1.0.0`** | Exit `0` — Resuelve **`material_ui 1.2.0`** (+ transitivas `cupertino_ui 1.0.2`, `flutter_localizations`, `intl 0.20.2`) sin conflictos | ✅ **Aprobado para ejecutar** |

> **Conclusión de prerrequisitos (`RF-1.1`):** El entorno cumple las condiciones para migrar limpiamente a la línea estable **`material_ui: ^1.0.0`** (resolviendo `1.2.0` en Flutter `3.44.0` / Dart `3.12.0`), dejando el proyecto listo para escalar automáticamente a `1.11.x` cuando se actualice el SDK a Flutter `>= 3.47.0`.

---

## 1. Estructura de Módulos Afectados y Trazabilidad a Requisitos

La migración preserva intacta la estructura **Clean Architecture** de `vihomeapp` (`Domain` → `Data` → `Presentation` + `Core` + `Test`), impactando únicamente el manifiesto de dependencias, los imports de diseño y los puntos de tematización/compatibilidad:

```text
vihomeapp/
├── pubspec.yaml                                      # [RF-2.1, RF-3.1, RNF-4, DT-1]
│                                                     # Agregar `material_ui: ^1.0.0` (resuelve 1.2.0 en Dart 3.12)
├── pubspec.lock                                      # [RF-2.1] Actualización determinista vía `flutter pub get`
│
├── lib/                                              # [RF-2.2, RF-2.3, RF-4.1..RF-4.3, RF-5.1] (64 archivos)
│   ├── app/
│   │   └── app.dart                                  # [RF-2.2, RF-2.4, RF-4.1, DT-3] `MaterialApp.router` + tema + puente si se requiere
│   ├── env/
│   │   ├── main.dev.dart                             # [RF-2.2, RF-6.3] Arranque sabor dev con `material_ui`
│   │   └── main.prod.dart                            # [RF-2.2, RF-6.3] Arranque sabor prod con `material_ui`
│   ├── core/
│   │   ├── theme/app_theme.dart                      # [RF-4.1, RNF-1, RNF-3, DT-3] `ThemeData`, `ColorScheme.fromSeed`, `DialogThemeData`, `AppBarTheme`, `ElevatedButtonThemeData`
│   │   ├── router/
│   │   │   ├── app_router.dart                       # [RF-2.2, RF-3.1, RF-4.2] Compatibilidad `go_router` + `material_ui`
│   │   │   └── guest_access_guard.dart               # [RF-2.2, RF-4.2]
│   │   └── utils/ui_feedback.dart                    # [RF-4.1, RF-5.1, RNF-5] `SnackBar` / `ScaffoldMessenger` con `material_ui`
│   ├── presentation/
│   │   ├── providers/                                # [RF-2.2] Providers que importan `material.dart` (ej. `project_provider.dart`)
│   │   ├── widgets/                                  # [RF-2.2, RF-4.1, RF-4.3, RNF-3]
│   │   │                                             # `guest_auth_banner.dart`, `alert_dialog.dart`, `btn_primary.dart`, `ad_banner_widget.dart`,
│   │   │                                             # `rating_badge.dart`, `landlord_reputation_bottom_sheet.dart`, etc.
│   │   └── pages/                                    # [RF-2.2, RF-3.1, RF-4.1..RF-4.3, RF-5.1]
│   │       ├── onboarding/                           # Preservación `011-vihomeapp-mvp`
│   │       ├── navegation/                           # Preservación `012-vihomeapp-mvp` y `010-account-deletion` (`Home`, `Arriendos`, `Ventas`, `Mapa`, `Perfil`, `Panel`, `Splash`)
│   │       ├── propiedades/                          # `DetallesPropiedadesPage`, `CrearPropiedadPage`, `EditarPropiedadesPage`, `MisPropiedadesPage`
│   │       ├── proyectos/                            # `ProyectosPage`, `DetallesProyectoPage`
│   │       ├── tenant/                               # Solicitudes contextuales y perfil arrendatario
│   │       ├── landlord/                             # Solicitudes y perfil arrendador
│   │       ├── suscripciones/                        # `SubscriptionPage`
│   │       └── user/                                 # `LoginPage`, `RegisterPage`
│
└── test/                                             # [RF-2.2, RF-2.3, RF-6.2, Constitución 2.3] (42 archivos + 1 nuevo test de paridad)
    ├── core/theme/
    │   └── app_theme_material_ui_test.dart           # [NUEVO - RF-2.2, RF-4.1, RNF-1, RNF-3, RNF-5]
    │                                                 # Verifica que `AppTheme` y `MaterialApp.router` operan sobre `material_ui`,
    │                                                 # colores/fuente preservados y 0 imports legados en `lib/` y `test/`
    └── (42 archivos existentes migrados a `package:material_ui/material_ui.dart`)
```

---

## 2. Modelo de Datos JSON y Ejemplos

### 2.1. Reporte de Auditoría de Migración (`MaterialUiMigrationAudit`)
Estructura JSON de verificación usada durante el proceso de migración y validación automatizada para auditar el estado de imports, compatibilidad de terceros y cumplimiento de `RF-1`..`RF-6`:

**Esquema de campos:**
| Campo | Tipo JSON | Obligatorio | Descripción | RF Cubierto |
| :--- | :--- | :---: | :--- | :--- |
| `flutterSdkVersion` | `string` | Sí | Versión exacta de Flutter SDK verificada (`"3.44.0"`). | `RF-1.1` |
| `dartSdkVersion` | `string` | Sí | Versión exacta de Dart SDK verificada (`"3.12.0"`). | `RF-1.1` |
| `materialUiConstraint` | `string` | Sí | Restricción declarada en `pubspec.yaml` (`"^1.0.0"`). | `RF-2.1` |
| `materialUiResolvedVersion` | `string` | Sí | Versión resuelta en `pubspec.lock` (`"1.2.0"`). | `RF-2.1` |
| `libFilesMigrated` | `integer` | Sí | Número de archivos en `lib/` migrados a `package:material_ui/material_ui.dart`. | `RF-2.2` |
| `testFilesMigrated` | `integer` | Sí | Número de archivos en `test/` migrados a `package:material_ui/material_ui.dart`. | `RF-2.2` |
| `remainingLegacyMaterialImports` | `integer` | Sí | Conteo de imports remanentes de `package:flutter/material.dart` (objetivo: `0`). | `RF-2.2`, `RF-2.3` |
| `thirdPartyCompatibility` | `array<object>` | Sí | Estado de cada dependencia UI externa y si requirió actualización o puente. | `RF-3.1`, `RF-3.2` |
| `verification` | `object` | Sí | Resultados de `flutter analyze`, `flutter test` y compilaciones Android `dev`/`prod`. | `RF-6.1`..`RF-6.3` |

**Ejemplo JSON de auditoría final esperada:**
```json
{
  "flutterSdkVersion": "3.44.0",
  "dartSdkVersion": "3.12.0",
  "materialUiConstraint": "^1.0.0",
  "materialUiResolvedVersion": "1.2.0",
  "libFilesMigrated": 64,
  "testFilesMigrated": 42,
  "remainingLegacyMaterialImports": 0,
  "thirdPartyCompatibility": [
    {
      "package": "go_router",
      "version": "16.3.0",
      "status": "compatible",
      "bridgeRequired": false,
      "notes": "Sin conflictos de tipo con MaterialApp.router"
    },
    {
      "package": "mapbox_maps_flutter",
      "version": "2.28.0",
      "status": "compatible",
      "bridgeRequired": false,
      "notes": "MapWidget y overlays compatibles sin cambios"
    },
    {
      "package": "cached_network_image",
      "version": "3.4.1",
      "status": "compatible",
      "bridgeRequired": false,
      "notes": "Placeholders y errorWidget compatibles"
    },
    {
      "package": "google_mobile_ads",
      "version": "7.0.0",
      "status": "compatible",
      "bridgeRequired": false,
      "notes": "AdWidget compatible dentro de Scaffold/Column"
    }
  ],
  "verification": {
    "analyzeIssues": 0,
    "testsTotal": 415,
    "testsPassed": 415,
    "androidDevBuildExitCode": 0,
    "androidProdBuildExitCode": 0
  }
}
```

---

## 3. Comandos, Salidas y Códigos de Salida

### 3.1. Comandos CLI de Migración, Auditoría, Pruebas y Compilación

| Paso | Propósito | Comando | Salida esperada (éxito) | Códigos de salida | RF / DoD |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | Verificar SDK local | `flutter --version` | `Flutter 3.44.0 ... Dart 3.12.0` | `0`: SDK detectado<br>`127`: Binario no encontrado | `RF-1.1` |
| 2 | Validar resolución sin modificar | `flutter pub add --dry-run "material_ui:^1.0.0"` | `+ material_ui 1.2.0` y `Would change ... dependencies.` | `0`: Resolución limpia<br>`65`: Conflicto de SDK o versiones | `RF-1.1`, `RF-1.2` |
| 3 | Incorporar `material_ui` estable | `flutter pub add "material_ui:^1.0.0"` | `Changed ... dependencies!` con `material_ui 1.2.0` en `pubspec.yaml` y `pubspec.lock` | `0`: Éxito<br>`65`: Conflicto de resolución | `RF-2.1` |
| 4 | Probar migración automática oficial | `dart fix --dry-run --code=migrate_design_widgets` | Lista de cambios propuestos (o aviso si la regla no existe en Dart 3.12) | `0`: Dry-run ejecutado<br>`1`/`64`: Regla no disponible (activa respaldo controlado DT-2) | `RF-2.2` |
| 5 | Aplicar migración de imports | `dart fix --apply --code=migrate_design_widgets` *(o reemplazo determinista verificado si el fix no está en Dart 3.12)* | 64 archivos en `lib/` y 42 en `test/` migrados a `package:material_ui/material_ui.dart` | `0`: Éxito<br>`1`: Error de escritura/sintaxis | `RF-2.2`, `RF-2.3` |
| 6 | Auditar 0 imports legados residuales | `grep -rn "package:flutter/material.dart" lib/ test/` | Salida vacía (0 coincidencias fuera de puentes explícitamente documentados) | `1` (grep sin coincidencias = **éxito** de migración)<br>`0`: Existen imports pendientes | `RF-2.2`, `RF-2.3` |
| 7 | Limpieza de cachés de build | `flutter clean && flutter pub get` | `Got dependencies!` | `0`: Éxito<br>`1`: Error en resolución/permisos | `RF-2.1`, `RNF-4` |
| 8 | Análisis estático completo | `flutter analyze` | `No issues found!` | `0`: 0 errores y 0 advertencias<br>`1`: Errores de tipo, imports ambiguos o lints | `RF-2.3`, `RF-3.1`, `RF-6.1` |
| 9 | Suite completa de regresión + paridad | `flutter test` | `All tests passed!` (412 pruebas previas + nuevas pruebas de paridad `material_ui`) | `0`: 100 % en verde<br>`1`: Fallo o regresión en algún test | `RF-4`, `RF-5`, `RF-6.2`, `DoD` |
| 10 | Compilación Android Desarrollo | `flutter build apk --flavor dev --target lib/env/main.dev.dart --debug` | `✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk` | `0`: Compilación exitosa<br>`1`: Error Dart/Gradle | `RF-6.3`, `DoD` |
| 11 | Compilación Android Producción | `flutter build apk --flavor prod --target lib/env/main.prod.dart --release` *(o `--debug` si el keystore de firma release no está configurado en entorno local, verificando tree-shaking/compilación)* | `✓ Built build/app/outputs/flutter-apk/app-prod-release.apk` | `0`: Compilación exitosa<br>`1`: Error Dart/Gradle/R8 o firma | `RF-6.3`, `DoD` |

### 3.2. Matriz de Salidas y Manejo de Incidentes Durante la Ejecución

| Situación detectada | Señal observada | Acción determinista del plan | RF Cubierto |
| :--- | :--- | :--- | :--- |
| `dart fix --code=migrate_design_widgets` no aplica cambios en Dart 3.12 | Salida `Nothing to fix!` o código desconocido | Ejecutar migración controlada de imports (`package:flutter/material.dart` → `package:material_ui/material_ui.dart`) en los 64 archivos de `lib/` y 42 de `test/`, preservando cláusulas `show`/`hide`/`as`, seguida de `flutter analyze` | `RF-2.2`, `RF-2.3` |
| Error `ambiguous_import` en algún archivo | `flutter analyze` reporta símbolo importado de ambas librerías | Remover el import legado `package:flutter/material.dart` o aplicar `hide` explícito únicamente si un paquete tercero exige un tipo específico | `RF-2.3`, `RF-6.1` |
| Error de tipo con paquete de terceros (`ThemeData`, `ColorScheme`, `BuildContext`) | `flutter analyze` reporta `argument_type_not_assignable` | 1) Evaluar si una actualización menor estable del paquete resuelve el tipo; 2) Si no, envolver el punto de integración con el puente de compatibilidad oficial (`MaterialUiCompatibilityBridge`) y documentarlo en el JSON de auditoría | `RF-3.1`, `RF-3.2` |
| Diferencia en APIs de `ThemeData` / `DialogThemeData` en `app_theme.dart` | `flutter analyze` o tests de tema fallan | Ajustar únicamente la propiedad equivalente en `lib/core/theme/app_theme.dart` manteniendo idénticos colores, radio `16`, fuente `Lato` y contraste >= 4.5:1 | `RF-4.1`, `RNF-1`, `RNF-3` |
| Falta firma/keystore local en `prod --release` | Gradle reporta keystore faltante solo en firma | Documentar claramente, verificar compilación `prod --debug` y `--profile` (o `release` sin firma) confirmando 0 errores de compilación Dart/R8 | `RF-6.3` |

---

## 4. Decisiones Técnicas Justificadas y Alternativas Descartadas

### DT-1: Adoptar `material_ui: ^1.0.0` (resuelve `1.2.0` estable en Flutter `3.44.0` / Dart `3.12.0`)
* **Cubre:** `RF-1.1`, `RF-1.2`, `RF-2.1`, `RNF-4`.
* **Decisión:** Agregar explícitamente `"material_ui:^1.0.0"` en `pubspec.yaml`, resolviendo la versión estable `1.2.0` del paquete oficial de `flutter.dev` sin necesidad de actualizar el SDK local de Flutter.
* **Justificación:**
  - Comprobado vía `--dry-run` con código de salida `0` y cero conflictos con las dependencias existentes.
  - Garantiza migración sobre la API estable `1.x` (no el paquete vacío `0.0.1`).
  - Permite actualización transparente a `1.11.x` en el futuro cuando el equipo suba a Flutter `>= 3.47.0` sin volver a tocar los imports.
* **Alternativas descartadas:**
  1. *Ejecutar `flutter pub add material_ui` sin versión:* Descartada porque en Dart `3.12.0` el solver selecciona `material_ui 0.0.1` (placeholder sin widgets), rompiendo toda la app.
  2. *Actualizar Flutter SDK a `>= 3.47.0` dentro de esta misma HU:* Descartada porque un upgrade de SDK impacta Gradle, Agp, CocoaPods y los 115 paquetes transitivos, excediendo el alcance de esta entrega (Fuera de Alcance #6) y multiplicando el riesgo de regresiones no relacionadas.

### DT-2: Migración en dos pasos (`dart fix` oficial + migración determinista verificada + auditoría `grep`)
* **Cubre:** `RF-2.2`, `RF-2.3`, `RF-6.1`, `RNF-4`.
* **Decisión:** Intentar primero la herramienta oficial `dart fix --apply --code=migrate_design_widgets`; si no está disponible o deja archivos pendientes en Dart `3.12.0`, ejecutar reemplazo determinista y exacto de `import 'package:flutter/material.dart'` → `import 'package:material_ui/material_ui.dart'` preservando cualquier directiva `show`/`hide`/`as` en los 64 archivos de `lib/` y 42 archivos de `test/`, seguido de verificación con `grep` para asegurar 0 imports legados residuales.
* **Alternativa descartada:**
  * *Migrar solo `lib/` dejando `test/` con `package:flutter/material.dart`:* Descartada porque causa fallos en `find.byType(...)` y errores de tipo en pruebas de widgets al mezclar widgets de `material_ui` con tipos del SDK legado (`RF-2.2`, `RF-6.2`).

### DT-3: Preservación estricta de `AppTheme`, `MaterialApp.router` y localización en español
* **Cubre:** `RF-2.4`, `RF-4.1`, `RF-4.2`, `RF-4.3`, `RNF-1`, `RNF-3`, `RNF-5`.
* **Decisión:** Conservar intactos todos los tokens de diseño en `lib/core/theme/app_theme.dart` (`primaryColor = 0xFF0E4E82`, `backgroundColor = 0xFFF6F7F8`, `fontFamily = 'Lato'`, `useMaterial3 = true`, `DialogThemeData`, `AppBarTheme`, `ElevatedButtonThemeData`, `ListTileThemeData`) y `lib/app/app.dart` (`MaterialApp.router`, `MediaQuery` con `textScaler: TextScaler.noScaling`). Verificar si `material_ui 1.2.0` requiere declarar `localizationsDelegates` de `material_ui` o `GlobalMaterialLocalizations` en `MaterialApp.router` para mantener etiquetas/diálogos por defecto en español (`RNF-5`).
* **Alternativa descartada:**
  * *Reescribir `AppTheme` aprovechando la migración:* Descartada porque contradice el requisito de migración 100 % transparente (Fuera de Alcance #1).

### DT-4: Estrategia quirúrgica para compatibilidad de paquetes de terceros
* **Cubre:** `RF-3.1`, `RF-3.2`, `RNF-1`, `RNF-4`.
* **Decisión:** Tras migrar imports y correr `flutter analyze`, clasificar cualquier error de compilación originado en paquetes externos (`go_router`, `mapbox_maps_flutter`, `cached_network_image`, `lottie`, `google_mobile_ads`, `file_picker`, `share_plus`):
  - Si no hay incompatibilidad (caso probable en `material_ui 1.2.0` por compatibilidad binaria/re-export con el SDK `3.44.0`), no tocar versiones de terceros.
  - Si surge una incompatibilidad puntual de tipo, resolverla con el puente oficial (`MaterialUiCompatibilityBridge`) o actualizando únicamente ese paquete a una versión estable compatible, dejando registro explícito en la documentación de cierre.
* **Alternativa descartada:**
  * *Ejecutar `flutter pub upgrade --major-versions` de forma masiva:* Descartada porque introduce cambios disruptivos en Firebase, Mapbox, Google Sign-In y GoRouter ajenos a esta HU (Fuera de Alcance #6).

### DT-5: Validación integral en Android (`dev` y `prod`) y prueba automatizada de guarda de migración
* **Cubre:** `RF-6.1`, `RF-6.2`, `RF-6.3`, `RNF-1`, `RNF-2`, `RNF-3`.
* **Decisión:** Incorporar un test dedicado (`test/core/theme/app_theme_material_ui_test.dart`) que verifique:
  1. Cero referencias residuales a `package:flutter/material.dart` en `lib/` y `test/` (previene regresiones futuras al agregar archivos nuevos).
  2. Paridad exacta de `AppTheme.ligthTheme` (`primaryColor`, `scaffoldBackgroundColor`, `useMaterial3`, `DialogThemeData`, `AppBarTheme`, `ElevatedButtonThemeData`) y renderizado sin errores de componentes críticos (`Scaffold`, `AppBar`, `BottomNavigationBar`, `AlertDialog`, `SnackBar`, `ElevatedButton`) importados desde `material_ui`.
  3. Ejecutar las 412 pruebas previas + `flutter build apk` en sabores `dev` y `prod`.
* **Alternativa descartada:**
  * *Validar únicamente con `flutter analyze` sin compilar `prod`:* Descartada porque omite problemas de tree-shaking de íconos/fuentes (`uses-material-design: true`) y R8/minificación en producción (`RF-6.3`).

---

## 5. Estrategia de Tests (Constitución Sección 2.3)

1. **Test nuevo de paridad y guarda contra regresión de imports (`test/core/theme/app_theme_material_ui_test.dart`):**
   - **Guarda estática de migración (`RF-2.2`, `RF-2.3`):** Recorre `lib/` y `test/` verificando que ningún archivo importe `package:flutter/material.dart` (0 coincidencias).
   - **Paridad de `AppTheme` (`RF-4.1`, `RNF-1`, `RNF-3`):** Valida `primaryColor == Color(0xFF0E4E82)`, `scaffoldBackgroundColor == Color(0xFFF6F7F8)`, `useMaterial3 == true`, `dialogTheme`, `appBarTheme`, `elevatedButtonTheme`, `listTileTheme`.
   - **Renderizado integrado de componentes `material_ui` (`RF-4.1`..`RF-4.3`, `RNF-5`):** Verifica `MaterialApp` con `AppTheme.ligthTheme`, `AppBar`, `BottomNavigationBar`, `ElevatedButton`, `AlertDialog`, `SnackBar` (`UiFeedback`) y `GuestAuthBanner` sin excepciones ni desbordamientos.
2. **Migración y ejecución de los 42 archivos de test existentes (`RF-6.2`):**
   - **Bienvenida inicial (`011-vihomeapp-mvp`):** `onboarding_page_test.dart`, `splash_screen_onboarding_test.dart` (incluye verificación en `320×568` y `430×932` y accesibilidad `>= 48×48`).
   - **Rol invitado (`012-vihomeapp-mvp`):** `app_router_guest_test.dart`, `guest_access_guard_test.dart`, `home_page_guest_test.dart`, `detalles_propiedades_guest_test.dart`, `detalles_proyecto_guest_test.dart`, `login_page_guest_test.dart`, `sign_out_guest_flow_test.dart`.
   - **Eliminación de cuenta (`010-account-deletion`):** `delete_account_dialog_test.dart`.
   - **Flujos base y widgets compartidos:** solicitudes contextuales, calificaciones/reseñas, creación/edición de propiedades, mapa de proyectos, suscripciones y `widget_test.dart` (412+ pruebas totales al 100 % en verde).
3. **Verificación de compilación en ambos sabores Android (`RF-6.3`):**
   - `flutter build apk --flavor dev --target lib/env/main.dev.dart --debug` (exit `0`).
   - `flutter build apk --flavor prod --target lib/env/main.prod.dart --release` (exit `0`; o si no hay keystore release local, verificación de compilación `prod` documentada).

---

## 6. Matriz de Trazabilidad Final (RF / RNF → Módulos → DT → Verificación)

| Requisito | Módulo(s) / Artefacto(s) | Decisión Técnica | Verificación / Tests |
| :--- | :--- | :---: | :--- |
| `RF-1.1`, `RF-1.2` | Entorno Flutter/Dart, `pubspec.yaml` | DT-1 | `flutter --version`, `flutter pub add --dry-run "material_ui:^1.0.0"` |
| `RF-2.1` | `pubspec.yaml`, `pubspec.lock` | DT-1 | `flutter pub add "material_ui:^1.0.0"`, `flutter pub get` |
| `RF-2.2`, `RF-2.3` | 64 archivos en `lib/` + 42 archivos en `test/` | DT-2 | `grep` (0 coincidencias), `app_theme_material_ui_test.dart`, `flutter analyze` |
| `RF-2.4` | `lib/app/app.dart`, `pubspec.yaml` | DT-3 | `app_theme_material_ui_test.dart`, `flutter test` |
| `RF-3.1`, `RF-3.2` | `app_router.dart`, `mapa_page.dart`, `ad_banner_widget.dart`, páginas con terceros | DT-4 | `flutter analyze`, `flutter test`, builds Android |
| `RF-4.1`..`RF-4.3` | `app_theme.dart`, `ui_feedback.dart`, `lib/presentation/**` | DT-3, DT-5 | `app_theme_material_ui_test.dart`, `onboarding_page_test.dart`, `login_page_guest_test.dart`, suite completa |
| `RF-5.1` | `ui_feedback.dart`, `arriendos_page.dart`, `ventas_page.dart`, `proyectos_page.dart`, `mapa_page.dart`, `delete_account_dialog_test.dart` | DT-3, DT-5 | `home_page_guest_test.dart`, `delete_account_dialog_test.dart`, `detalles_propiedades_guest_test.dart` |
| `RF-6.1` | Todo el proyecto (`lib/`, `test/`) | DT-2, DT-5 | `flutter analyze` (`No issues found!`, exit `0`) |
| `RF-6.2` | Toda la suite `test/` | DT-2, DT-5 | `flutter test` (415+ tests, 100 % verde, exit `0`) |
| `RF-6.3` | Sabores Android `dev` y `prod` | DT-5 | `flutter build apk --flavor dev ...` y `flutter build apk --flavor prod ...` (exit `0`) |
| `RNF-1`..`RNF-5` | `app_theme.dart`, `app.dart`, `lib/presentation/**`, `pubspec.yaml` | DT-1..DT-5 | `app_theme_material_ui_test.dart`, `onboarding_page_test.dart`, `login_page_guest_test.dart`, `flutter analyze`, `flutter test` |
