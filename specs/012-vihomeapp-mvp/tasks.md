# Plan de Tareas: Rol Invitado, Exploración Pública y Acceso Inicial a Arriendos (MVP)

**Especificación:** `specs/012-vihomeapp-mvp/spec.md`
**Plan técnico:** `specs/012-vihomeapp-mvp/plan.md`
**Constitución:** `docs/constitution.md`

---

## Fase 1: Entidad de Contexto de Redirección y Guarda Central de Acceso Invitado
- [x] **Tarea 1.1:** Crear `lib/domain/entities/guest_redirect_context.dart` definiendo el enum `GuestRedirectReason` (`profile`, `rentApplication`, `whatsappContact`, `projectContact`, `landlordReviews`, `share`, `externalMap`, `privateRoute`, `sessionExpired`, `onboardingLoginShortcut`) y la entidad inmutable `GuestRedirectContext` con mensajes contextuales en español neutro, bandera `showRestrictionBanner` (`false` solo para `onboardingLoginShortcut`), `sourcePath`, `canReturnToPreviousView` y métodos `toJson()` / `fromJson()`. [RF-1.3, RF-1.7, RF-3.2, RF-4.2, RF-4.3, RF-5.1, RF-6.2, RF-6.3, RNF-4, DT-2, DT-3]
- [x] **Tarea 1.2:** Crear `lib/core/router/guest_access_guard.dart` implementando `GuestAccessGuard.requireAuth(BuildContext context, {required GuestRedirectReason reason, required String sourcePath})` con guarda anti doble-toque (`_isRedirecting`) y navegación mediante `context.push('/login', extra: GuestRedirectContext.fromReason(...))` que preserva la vista pública anterior en el stack. [RF-3.1..RF-3.4, RF-4.2..RF-4.4, RF-6.2, RNF-3, DT-2]

## Fase 2: Estado de Sesión (`AuthProvider`), Limpieza Privada y Enrutamiento (`GoRouter`)
- [x] **Tarea 2.1:** Actualizar `lib/presentation/providers/auth_provider.dart`:
  - Exponer el getter semántico `bool get isGuest => !isAuthenticated;`.
  - Garantizar que ante sesión expirada, revocada o error durante `_initializeAuth()` el provider finalice con `_user = null` e `isInitialized = true` sin lanzar excepciones bloqueantes.
  - Suscribir de forma segura la escucha de cierre/expiración remota (`onAuthStateChange`) para limpiar `_user = null` y notificar listeners en caliente, preservando siempre `kOnboardingStateKey` en `signOut()` y `deleteAccount()`. [RF-1.5..RF-1.7, RF-7.1..RF-7.5, RNF-1, RNF-2, DT-1, DT-6]
- [x] **Tarea 2.2:** Verificar y añadir métodos de limpieza segura (`clear()` / `reset()`) en `ApplicationProvider`, `TenantProvider`, `LandlordProvider` y `SubscriptionProvider` para que al transicionar de autenticado a invitado no queden contadores, solicitudes, perfiles ni estado premium residuales. [RF-2.5, RF-7.3, RF-7.4, RNF-2, DT-4]
- [x] **Tarea 2.3:** Actualizar `lib/core/router/app_router.dart`:
  - Ampliar `isPublicRoute` para incluir `'/home'`, `'/property-details'`, `'/proyecto-detalle'` y `'/mapa'` (junto con `'/'`, `'/onboarding'`, `'/login'` y `'/register'`).
  - Redirigir toda ruta privada sin sesión a `'/login?reason=private_route'` para que `LoginPage` muestre el aviso contextual correspondiente.
  - En la ruta `'/property-details'`, eliminar el bloqueo `if (user == null)` que devolvía `'Error: Usuario no encontrado'` y pasar `user` como `User?` nullable a `DetallesPropiedadesPage`.
  - En la ruta `'/login'`, extraer `GuestRedirectContext?` desde `state.extra` o construirlo desde `state.uri.queryParameters['reason']` y pasarlo a `LoginPage`. [RF-1.4, RF-2.1..RF-2.3, RF-5.1, RF-6.2, RF-6.3, RNF-1, RNF-2, DT-2]

## Fase 3: Flujo Inicial (Onboarding y Splash) y Pantalla de Login para Invitados
- [x] **Tarea 3.1:** Actualizar `lib/presentation/pages/onboarding/onboarding_page.dart`:
  - Cambiar `_handleNextOrComplete()` (*"Comenzar Ahora"*) y `_handleSkip()` (*"Saltar"*) para navegar con `context.go('/home')` (incluso ante fallo de escritura local) descartando el onboarding del historial.
  - Actualizar `_handleLoginShortcut()` (*"¿Ya tienes una cuenta? Iniciar Sesión"*) para navegar con `context.go('/login', extra: GuestRedirectContext.onboardingShortcut())` sin mostrar banner de restricción. [RF-1.1, RF-1.2, RF-1.3, DT-4]
- [x] **Tarea 3.2:** Actualizar `lib/presentation/pages/navegation/splash_screen.dart`:
  - Cuando `!isAuthenticated` y `hasSeenOnboarding == true`, cambiar `context.go('/login')` por `context.go('/home')` para iniciar siempre en Arriendos en modo invitado.
  - Mantener el respaldo determinista hacia `'/onboarding'` si `!hasSeenOnboarding` o falla la lectura de onboarding sin sesión, y el ingreso directo a `'/home'` si hay sesión activa o si la sesión expiró con onboarding ya visto. [RF-1.4, RF-1.5, RF-1.6, DT-4]
- [x] **Tarea 3.3:** Crear el widget `lib/presentation/widgets/guest_auth_banner.dart` con mensaje contextual en español neutro, ícono informativo, contraste mínimo 4.5:1 (nivel AA), `Semantics` descriptivo y adaptación sin recortes ante texto escalado. [RF-3.2, RF-4.2, RF-4.3, RF-5.1, RNF-4, RNF-5, DT-3]
- [x] **Tarea 3.4:** Actualizar `lib/presentation/pages/user/login_page.dart` y verificar `lib/presentation/pages/user/register_page.dart`:
  - Aceptar `final GuestRedirectContext? redirectContext;` y renderizar `GuestAuthBanner` únicamente cuando `redirectContext?.showRestrictionBanner == true`.
  - Incorporar botón explícito *"Continuar como invitado"* (área táctil mínima 48×48 + `Semantics`) dentro del `SingleChildScrollView` para mantener accesibilidad con teclado virtual abierto y texto escalado.
  - Incorporar botón de retroceso superior y `PopScope(canPop: false, onPopInvokedWithResult: ...)` llamando a `_handleExitAsGuest()`: `context.pop()` si `context.canPop()`, o `context.go('/home')` si no existe historial previo (impidiendo regresar al onboarding).
  - Asegurar que tras fallos de login o recuperación de contraseña el retorno como invitado siga intacto, que desde `RegisterPage` el usuario pueda volver limpiamente a `/login`, y que tras login/registro exitoso navegue siempre con `context.go('/home')`. [RF-6.1..RF-6.5, RF-7.1, RF-7.2, RNF-4, RNF-5, DT-3]

## Fase 4: Vistas Públicas, Detalles, Cierre de Sesión y Eliminación de Cuenta
- [x] **Tarea 4.1:** Actualizar `lib/presentation/pages/navegation/home_page.dart`:
  - Mantener `_currentIndex = 0` (`ArriendosPage`) como vista inicial.
  - En `BottomNavigationBar.onTap`, interceptar `index == 3` (**Perfil**) cuando `authProvider.isGuest` invocando `GuestAccessGuard.requireAuth(context, reason: GuestRedirectReason.profile, sourcePath: '/home')` sin modificar `_currentIndex`.
  - Ejecutar `PushNotificationService.handleInitialMessage()` únicamente si `authProvider.isAuthenticated`.
  - En `_onAuthChanged()`, cuando el usuario pase a `null`, reiniciar `_currentIndex = 0` si estaba en `3`, limpiar `ApplicationProvider`, `TenantProvider`, `LandlordProvider` y `SubscriptionProvider`, y asegurar que la cuarta pestaña muestre `Perfil`. [RF-1.4, RF-2.1, RF-3.1..RF-3.4, RF-7.1..RF-7.4, RNF-1, RNF-2, DT-4]
- [x] **Tarea 4.2:** Actualizar `lib/presentation/pages/navegation/arriendos_page.dart`, `ventas_page.dart` y `lib/presentation/pages/proyectos/proyectos_page.dart` para ocultar por completo el botón/badge de notificaciones en `AppBar.actions` cuando `authProvider.isGuest`, manteniendo operativos búsqueda, filtros, botón de mapa y estados de error/reintento sin redirigir a login. [RF-2.2, RF-2.4, RF-8.1, RF-8.3, RNF-1, DT-5]
- [x] **Tarea 4.3:** Verificar y ajustar `lib/presentation/pages/navegation/mapa_page.dart` para garantizar exploración de marcadores y detalles en modo invitado y manejo de permiso de ubicación denegado con aviso comprensible y ubicación predeterminada (sin redirigir a `/login`). [RF-2.2, RF-8.1, RF-8.2, RF-8.4, RNF-1, DT-5]
- [x] **Tarea 4.4:** Actualizar `lib/presentation/pages/propiedades/detalles_propiedades_page.dart`:
  - Cambiar `final User user;` a `final User? user;`.
  - Mostrar `_buildTenantActionBar()` cuando `(widget.user == null || widget.user?.role == 'arrendatario') && widget.property.estado == 'arriendo'`.
  - Proteger con `GuestAccessGuard.requireAuth(...)`:
    1. `"Solicitar Arriendo"` (`rentApplication`) antes de validar `tenantProvider.isVerified`.
    2. `"Contactar por WhatsApp"` (`whatsappContact`).
    3. `"Compartir"` en `AppBar` (`share`).
    4. Tap en tarjeta/insignia de reputación que abre `LandlordReputationBottomSheet` (`landlordReviews`).
    5. Tap en mapa embebido que abre mapas externos (`externalMap`).
  - Confirmar manejo seguro de `isPremium = authProvider.user?.isPremium ?? false` y tolerancia a datos incompletos / fallos parciales de carga sin redirigir a `/login`. [RF-2.3, RF-2.5, RF-4.1..RF-4.4, RF-8.1, RF-8.4, RNF-1, DT-5]
- [x] **Tarea 4.5:** Actualizar `lib/presentation/pages/proyectos/detalles_proyecto_page.dart` protegiendo con `GuestAccessGuard.requireAuth(...)` los controles `"Contactar"` (`projectContact`), `"Compartir"` (`share`) y enlace a mapa externo (`externalMap`), manteniendo la visualización solo lectura y respaldos ante datos incompletos. [RF-2.3, RF-4.1, RF-4.3, RF-4.4, RF-8.4, RNF-1, DT-5]
- [x] **Tarea 4.6:** Actualizar `lib/presentation/pages/navegation/perfil_page.dart` y `lib/presentation/pages/navegation/panel_page.dart`:
  - Tras `authProvider.signOut()`, navegar con `context.go('/home')` (en lugar de `context.go('/login')`).
  - Tras `authProvider.deleteAccount() == true`, navegar con `context.go('/home')` preservando el mensaje de confirmación de cuenta eliminada (`010-account-deletion`); si retorna `false`, mantener sesión y mostrar error con reintento. [RF-7.3, RF-7.4, RF-7.5, DT-4]

## Fase 5: Auditoría de Políticas RLS en Supabase (Solo Lectura Pública `anon`)
- [x] **Tarea 5.1:** Auditar las políticas Row Level Security (RLS) del proyecto Supabase (y documentar/aplicar migración si alguna lectura pública está bloqueada para `anon`) asegurando `SELECT` público únicamente sobre el catálogo de propiedades, proyectos, constructoras y resumen público de arrendadores/reputación, y denegación estricta para `anon` en tablas privadas (`solicitudes`, `arrendatarios`, `profiles`, `suscripciones`, `notificaciones`). [RF-2.2, RF-2.3, RF-8.3, RNF-2, DT-6]

## Fase 6: Suite de Pruebas Automatizadas y Compatibilidad (`011` / `010`)
- [x] **Tarea 6.1:** Crear pruebas unitarias de entidades, guardas y sesión:
  - `test/domain/entities/guest_redirect_context_test.dart`
  - `test/core/router/guest_access_guard_test.dart`
  - `test/presentation/providers/auth_provider_guest_session_test.dart` [RF-1.5..RF-1.7, RF-3.4, RF-4.4, RF-7.3..RF-7.5, RNF-4, DT-1, DT-2]
- [x] **Tarea 6.2:** Crear `test/core/router/app_router_guest_test.dart` validando acceso libre a rutas públicas (`/home`, `/property-details` con `user == null`, `/proyecto-detalle`, `/mapa`) y redirección a `/login` en todas las rutas privadas. [RF-2.1..RF-2.3, RF-5.1, RNF-1, RNF-2, DT-2]
- [x] **Tarea 6.3:** Actualizar por compatibilidad con `012` las pruebas existentes afectadas de `011-vihomeapp-mvp` y `010-account-deletion`:
  - `test/presentation/pages/onboarding_page_test.dart` (*"Comenzar Ahora"* y *"Saltar"* → `/home`, incluso con error de guardado; *"Iniciar Sesión"* → `/login` sin banner).
  - `test/presentation/pages/splash_screen_onboarding_test.dart` (`hasSeen == true && isGuest` y sesión expirada/error → `/home`).
  - `test/presentation/pages/profile/delete_account_dialog_test.dart` (verificación de destino `/home` con mensaje de confirmación en éxito y sesión intacta en error). [RF-1.1..RF-1.6, RF-7.4, RF-7.5, DT-4]
- [x] **Tarea 6.4:** Crear pruebas de widgets y flujos completos del rol invitado:
  - `test/presentation/pages/navegation/home_page_guest_test.dart` (tabs públicas, ocultamiento de notificaciones, tap/doble tap en Perfil, regreso preservando tab, reversión `Panel` → `Perfil`).
  - `test/presentation/pages/propiedades/detalles_propiedades_guest_test.dart` (`user: null`, datos incompletos, Solicitar Arriendo sin diálogo de perfil incompleto, WhatsApp, Compartir, reseñas y mapa externo).
  - `test/presentation/pages/proyectos/detalles_proyecto_guest_test.dart` (solo lectura, datos incompletos, Contactar, Compartir y mapa externo).
  - `test/presentation/pages/user/login_page_guest_test.dart` (banner contextual vs onboarding sin banner, *"Continuar como invitado"*, `PopScope` con y sin historial, fallos de login sin romper retorno, accesibilidad >= 48×48, `Semantics`, pantalla `320×568` con teclado y texto escalado, login exitoso → `/home`).
  - `test/presentation/pages/profile/sign_out_guest_flow_test.dart` (cierre de sesión desde `PerfilPage` y `PanelPage` → `/home` en modo invitado, y pruebas de resiliencia sin conexión / permisos de ubicación denegados en Mapa sin redirigir a login). [RF-2..RF-8, RNF-1..RNF-5, DT-2..DT-5]

## Fase 7: Verificación Final, Regresión y Presentación
- [x] **Tarea 7.1:** Ejecutar `flutter analyze` y verificar `No issues found!` (código de salida `0`). [Constitución 2.3, RNF-1, DoD]
- [x] **Tarea 7.2:** Ejecutar la suite completa `flutter test` y verificar 100% de pruebas en verde sin regresiones sobre las 383 pruebas existentes + nuevas pruebas de rol invitado (código de salida `0`). [Constitución 2.3, DoD]
- [x] **Tarea 7.3:** Ejecutar `flutter build apk --flavor dev --target lib/env/main.dev.dart --debug` y verificar compilación limpia (código de salida `0`). [DoD]
- [x] **Tarea 7.4:** Presentar resumen técnico de implementación y verificación para aprobación del usuario (sin hacer commit ni cerrar la HU en Notion hasta confirmación explícita).
