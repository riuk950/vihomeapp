# Plan de Tareas: Flujo de Onboarding Inicial de ViHome (MVP)

**Especificación:** `specs/011-vihomeapp-mvp/spec.md`
**Plan técnico:** `specs/011-vihomeapp-mvp/plan.md`
**Constitución:** `docs/constitution.md`

---

## Fase 1: Recursos Gráficos Offline y Constantes Base
- [x] **Tarea 1.1:** Descargar y optimizar (< 150 KB c/u) las 4 imágenes locales de las pantallas de Stitch en `assets/images/onboarding/` (`onboarding_1_space.jpg`, `onboarding_2_connection.jpg`, `onboarding_3_contracts.jpg`, `onboarding_4_management.jpg`) y registrar `assets/images/onboarding/` en `pubspec.yaml`. Ejecutar `flutter pub get` (código de salida `0`). [RF-2.1, RF-8.1, RNF-1, DT-3]
- [x] **Tarea 1.2:** Crear `lib/core/constants/storage_keys.dart` declarando la constante compartida `kOnboardingStateKey = 'vihome_onboarding_state_v1'`. [RF-7.1, RF-7.3, DT-1]

## Fase 2: Capa de Dominio y Datos (Clean Architecture)
- [x] **Tarea 2.1:** Crear entidades inmutables de dominio en `lib/domain/entities/onboarding_state.dart` (`OnboardingState` y enum `OnboardingCompletionReason`: `completed`, `skipped`, `loginShortcut`, `existingSession`) y `lib/domain/entities/onboarding_step.dart` (`OnboardingStep` + lista constante inmutable de los 4 pasos en español). [RF-1, RF-2.1..RF-2.6, RNF-4, DT-1, DT-3]
- [x] **Tarea 2.2:** Crear el contrato `OnboardingRepository` en `lib/domain/repositories/onboarding_repository.dart` con `Future<OnboardingState> getOnboardingState()` y `Future<bool> markOnboardingSeen({required OnboardingCompletionReason reason, required int lastStep})`. [RF-1, RF-7, RF-8, DT-1]
- [x] **Tarea 2.3:** Implementar los casos de uso `GetOnboardingStatusUseCase` (`lib/domain/usecases/onboarding/get_onboarding_status_usecase.dart`) y `CompleteOnboardingUseCase` (`lib/domain/usecases/onboarding/complete_onboarding_usecase.dart`), exportándolos en `lib/domain/usecases/usecases.dart`. [RF-1.1..RF-1.4, RF-4.1, RF-5.1, RF-6.1, RF-8.2, RF-8.3, DT-1, DT-2]
- [x] **Tarea 2.4:** Crear `OnboardingStateModel` en `lib/data/models/onboarding_state_model.dart` con `toJson()` / `fromJson()` tolerante a JSON corrupto o campos faltantes (retorna `notSeen()` sin lanzar excepción). [RF-7.1, RF-8.3, DT-1]
- [x] **Tarea 2.5:** Implementar `OnboardingLocalDataSource` y `OnboardingLocalDataSourceImpl` (`lib/data/datasources/onboarding_local_datasource.dart`) sobre `SharedPreferences` usando `kOnboardingStateKey`, y `OnboardingRepositoryImpl` (`lib/data/repositories/onboarding_repository_impl.dart`) con bloques `try/catch` no bloqueantes. [RF-7.1..RF-7.4, RF-8.2, RF-8.3, DT-1]
- [x] **Tarea 2.6:** Registrar `OnboardingLocalDataSource`, `OnboardingRepository`, `GetOnboardingStatusUseCase`, `CompleteOnboardingUseCase` y `OnboardingProvider` en `lib/core/di/injection_container.dart`. [RF-1..RF-8, DT-1, DT-2]

## Fase 3: Preservación en AuthProvider, Enrutamiento y SplashScreen
- [x] **Tarea 3.1:** Modificar `AuthProvider.signOut()` y `AuthProvider.deleteAccount()` en `lib/presentation/providers/auth_provider.dart` para leer `kOnboardingStateKey` antes de `prefs.clear()` y restaurarlo inmediatamente después, garantizando que cerrar sesión o eliminar cuenta no reinicie el onboarding. [RF-7.3, DT-1]
- [x] **Tarea 3.2:** Actualizar `lib/core/router/app_router.dart` para registrar la ruta `/onboarding` (`name: 'onboarding'`), permitir el acceso a `/onboarding` cuando `!isAuthenticated` y redirigir a `/home` si `isAuthenticated` intenta acceder a `/onboarding`. [RF-1.1, RF-1.3, RF-4.1, RF-5.1, RF-6.1, RF-7.2, DT-2]
- [x] **Tarea 3.3:** Actualizar `SplashScreen._checkAuthAndNavigate()` en `lib/presentation/pages/navegation/splash_screen.dart`:
  - Si `isAuthenticated == true`: consultar `GetOnboardingStatusUseCase`; si aún no está marcado como visto, invocar `CompleteOnboardingUseCase(reason: existingSession, step: 0)` y navegar con `context.go('/home')`.
  - Si `isAuthenticated == false`: consultar `GetOnboardingStatusUseCase`; navegar con `context.go('/onboarding')` si `!hasSeenOnboarding` (incluyendo respaldo determinista ante error de lectura) o `context.go('/login')` si `hasSeenOnboarding`. [RF-1.1..RF-1.4, RF-8.3, DT-2]

## Fase 4: Capa de Presentación — Provider y UI del Onboarding (Azure Horizon)
- [x] **Tarea 4.1:** Crear `OnboardingProvider` (`lib/presentation/providers/onboarding_provider.dart`) gestionando índice actual (`0..3`), `goToNextStep()`, `goToPreviousStep()`, `setPage(int)`, guarda anti doble-toque/concurrencia (`_isTransitioning` / `_isExiting`) y `exitOnboarding(reason)` no bloqueante ante fallo de guardado. [RF-3.1..RF-3.7, RF-4.1, RF-5.1, RF-6.1, RF-7.5, RF-8.2, DT-4]
- [x] **Tarea 4.2:** Crear los widgets modulares en `lib/presentation/pages/onboarding/widgets/`:
  - `onboarding_header.dart`: botón de retroceso superior izquierdo oculto en paso 1 y activo en pasos 2–4 (área >= 48×48 + `Semantics`), y botón *"Saltar"* visible en los 4 pasos (área >= 48×48 + `Semantics`). [RF-2.1..RF-2.3, RF-3.2, RF-5.1, RNF-5, DT-4, DT-5]
  - `onboarding_slide_card.dart`: tarjeta flotante *Azure Horizon* (`#003760` / `#0E4E82` sobre `#F9F9FE`) con imagen local `Image.asset`, badges, tarjetas glassmorphism e iconos en órbita envueltos en `IgnorePointer` (estrictamente no interactivos). [RF-2.1, RF-2.6, RF-8.1, RNF-1, RNF-3, RNF-4, DT-3]
  - `onboarding_indicator.dart`: indicador de 4 posiciones animado (< 350 ms), no interactivo, con etiqueta `Semantics("Paso X de 4")`. [RF-2.6, RF-3.6, RNF-2, RNF-5, DT-4, DT-5]
  - `onboarding_footer.dart`: botón CTA principal (`"Continuar"` en pasos 1–3, `"Comenzar Ahora"` en paso 4, altura >= 48dp, contraste >= 4.5:1) y enlace inferior *"¿Ya tienes una cuenta? Iniciar Sesión"* (área >= 48dp). [RF-2.4, RF-2.5, RF-4.1, RF-6.1, RNF-5, DT-5]
- [x] **Tarea 4.3:** Crear `OnboardingPage` (`lib/presentation/pages/onboarding/onboarding_page.dart`) y exportarla en `lib/presentation/pages/pages.dart`:
  - `PageView.builder` con `ClampingScrollPhysics()` + `precacheImage` de los 4 assets locales.
  - `PopScope` (`canPop: currentPage == 0`; en pasos 2–4 retrocede un paso sin cerrar la app; en paso 1 permite salida sin marcar visto).
  - Bloqueo de orientación vertical (`DeviceOrientation.portraitUp`) en `initState` y restauración en `dispose`.
  - Tema claro de marca forzado (`Theme(data: AppTheme.ligthTheme)` + `AnnotatedRegion<SystemUiOverlayStyle>`).
  - Layout responsivo con `SafeArea` + `LayoutBuilder` + `SingleChildScrollView` evitando `RenderFlex overflow`.
  - Toda salida ejecuta `context.go('/login')` reemplazando el historial de navegación. [RF-2..RF-8, RNF-1..RNF-5, DT-3, DT-4, DT-5]

## Fase 5: Suite de Pruebas Automatizadas (Constitución Sección 2.3)
- [x] **Tarea 5.1:** Crear pruebas unitarias de modelo, datasource, repositorio y casos de uso:
  - `test/data/models/onboarding_state_model_test.dart`
  - `test/data/datasources/onboarding_local_datasource_test.dart`
  - `test/data/repositories/onboarding_repository_impl_test.dart`
  - `test/domain/usecases/onboarding/get_onboarding_status_usecase_test.dart`
  - `test/domain/usecases/onboarding/complete_onboarding_usecase_test.dart` [RF-1, RF-4..RF-8, DT-1]
- [x] **Tarea 5.2:** Crear pruebas unitarias de proveedores y preservación al cerrar sesión:
  - `test/presentation/providers/onboarding_provider_test.dart` (límites, doble toque, fallo no bloqueante).
  - `test/presentation/providers/auth_provider_onboarding_preservation_test.dart` (`signOut()` y `deleteAccount()` preservan `kOnboardingStateKey`). [RF-3, RF-7.3, RF-8.2, DT-1, DT-4]
- [x] **Tarea 5.3:** Crear pruebas de widget e integración de arranque y recorrido completo:
  - `test/presentation/pages/splash_screen_onboarding_test.dart` (`RF-1.1`..`RF-1.4`, `RF-8.3`).
  - `test/presentation/pages/onboarding_page_test.dart` (4 pantallas, swipe, botones, `PopScope`, `Saltar`, `Comenzar Ahora`, `Iniciar Sesión`, historial reemplazado `canPop == false`, cierre sin guardar en pasos 1–4, error de guardado no bloqueante, tamaños `320×568` y `430×932` sin overflow, áreas >= 48×48, `Semantics` y cero imágenes remotas). [RF-2..RF-8, RNF-1..RNF-5, DT-2..DT-5]

## Fase 6: Verificación Final, Regresión y Presentación
- [x] **Tarea 6.1:** Ejecutar `flutter analyze` y verificar 0 errores y 0 advertencias (código de salida `0`). [Constitución 2.3, DoD]
- [x] **Tarea 6.2:** Ejecutar la suite completa `flutter test` y verificar 100% en verde sin regresiones sobre las 346 pruebas previas + nuevas pruebas de onboarding (código de salida `0`). [Constitución 2.3, DoD]
- [x] **Tarea 6.3:** Verificar compilación de desarrollo `flutter build apk --flavor dev --target lib/env/main.dev.dart --debug` (código de salida `0`) confirmando empaquetado correcto de los assets locales. [RNF-1, DoD]
- [x] **Tarea 6.4:** Presentar resumen técnico de implementación y verificación para aprobación del usuario (sin hacer commit ni cerrar la HU en Notion hasta confirmación explícita).
