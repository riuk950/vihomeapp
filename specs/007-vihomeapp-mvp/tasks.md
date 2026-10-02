# Tareas de Implementación: Persistencia de Datos al Cambiar Rol (007-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), organizadas en estricto orden de dependencias arquitectónicas (Clean Architecture). Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF), Casos Límite (CL) y Decisiones Técnicas (DT) que cubre, junto con un criterio de aceptación medible y verificable ("Hecho cuando:").

---

## Fase 1: Capa de Dominio y Datos (Modelos, Datasources y Sincronización)

- [x] **Tarea 1.1: Métodos de compatibilidad y mapeo en Entidades `Tenant` y `Landlord`**
  - **RF Cubiertos:** RF-37.1, RF-37.2, DT-1
  - **Descripción:** Extender `lib/domain/entities/tenant.dart` y `lib/domain/entities/landlord.dart` para proveer métodos de interoperabilidad y conversión de datos personales compartidos (`toLandlord()`, `fromLandlord()`, etc.), asegurando la integridad de campos obligatorios y opcionales.
  - **Hecho cuando:** Pruebas unitarias de conversión entre ambas entidades verifiquen que todos los campos (nombres, apellidos, documento, tipo de documento, teléfono, dirección) se transfieren íntegramente.

- [x] **Tarea 1.2: Sincronización automática de perfiles en `AuthRemoteDataSourceImpl`**
  - **RF Cubiertos:** RF-37.1, RF-37.2, RF-37.3, RNF-23, CL-35, CL-36, DT-1, DT-2
  - **Descripción:** Modificar `lib/data/datasources/auth_remote_datasource.dart`:
    - En `updateUserRole(String role)`:
      - Si `role == 'arrendador'`: consultar `info_arrendatarios` para el usuario actual. Si existen datos y no existen en `info_arrendadores` (o están vacíos), transferir los campos hacia `info_arrendadores` mediante `upsert`.
      - Si `role == 'arrendatario'`: consultar `info_arrendadores` para el usuario actual. Si existen datos y no existen en `info_arrendatarios` (o están vacíos), transferir los campos hacia `info_arrendatarios` mediante `upsert`.
    - Actualizar metadatos de autenticación y la tabla `profiles`.
  - **Hecho cuando:** `test/data/datasources/auth_remote_datasource_role_switch_test.dart` valide la sincronización bidireccional sin sobrescribir datos válidos.

- [x] **Tarea 1.3: Resiliencia con `maybeSingle()` en `LandlordRepositoryImpl`**
  - **RF Cubiertos:** RF-33.1, CL-32, DT-7
  - **Descripción:** Modificar `lib/data/repositories/landlord_repository_impl.dart`:
    - Cambiar `.single()` por `.maybeSingle()` en `getLandlordProfile`.
    - Si la consulta retorna null (perfil aún no existente), retornar un `Failure` controlado (`NotFoundFailure`) o manejar limpiamente el estado sin generar excepciones no capturadas de PostgREST.
  - **Hecho cuando:** Pruebas unitarias confirmen que consultar un landlord inexistente no arroja excepción no controlada.

---

## Fase 2: Capa de Presentación - Providers (`AuthProvider`, `LandlordProvider`, `TenantProvider`)

- [x] **Tarea 2.1: Soporte de alternancia de rol en `AuthProvider` (`switchRole`, `becomeTenant`)**
  - **RF Cubiertos:** RF-37.1, RF-37.2, RF-40.4, DT-3
  - **Descripción:** Modificar `lib/presentation/providers/auth_provider.dart`:
    - Implementar `Future<bool> switchRole(String newRole)`: valida si el rol actual ya es el solicitado (evitando llamadas redundantes). Si es diferente, invoca `updateUserRoleUseCase`, actualiza el usuario en sesión `_user = _user!.copyWith(role: newRole)` y notifica a los listeners.
    - Implementar `Future<bool> becomeTenant()` delegando en `switchRole('arrendatario')`.
    - Actualizar `becomeLandlord()` delegando en `switchRole('arrendador')`.
  - **Hecho cuando:** `test/presentation/providers/auth_provider_switch_role_test.dart` valide el cambio bidireccional y la prevención de llamadas redundantes.

---

## Fase 3: Capa de Presentación - Pantalla de Perfil de Usuario (`perfil_page.dart`)

- [x] **Tarea 3.1: Soporte de visualización simétrica de estado de verificación y mensajes**
  - **RF Cubiertos:** RF-38.1, RF-39.1, RF-39.2, DT-4
  - **Descripción:** Modificar `lib/presentation/pages/navegation/perfil_page.dart`:
    - En la cabecera de perfil, mostrar el estado de verificación (`MsnUserVerificado()` o `MsnUserComplete()`) tanto para `arrendatario` (escuchando `TenantProvider`) como para `arrendador` (escuchando `LandlordProvider`).
  - **Hecho cuando:** La vista de perfil muestre correctamente el distintivo de usuario verificado para ambos roles cuando sus datos estén completos.

- [x] **Tarea 3.2: Tarjeta y diálogo interactivo para alternar a Arrendatario**
  - **RF Cubiertos:** RF-40.2, RF-40.3, DT-5
  - **Descripción:** En `perfil_page.dart`:
    - Añadir la tarjeta interactiva *"Cambiar a rol Arrendatario"* cuando `user?.role == 'arrendador'` (con icono `Icons.person_search` o `Icons.person_outline` y texto descriptivo *"Explora inmuebles y gestiona tus solicitudes de arriendo"*).
    - Implementar diálogo de confirmación `_showBecomeTenantDialog(BuildContext context)`.
  - **Hecho cuando:** Al pulsar sobre la tarjeta en rol arrendador se abra el diálogo de confirmación accesible.

- [x] **Tarea 3.3: Navegación inteligente tras cambio de rol (Sin forzar completado de perfil si ya está verificado)**
  - **RF Cubiertos:** RF-38.1, RF-38.2, RF-38.3, RF-39.1, RF-39.2, CL-32, DT-4
  - **Descripción:** En `_showBecomeLandlordDialog` y `_showBecomeTenantDialog`:
    - Mostrar indicador de progreso no bloqueante.
    - Ejecutar el cambio de rol.
    - Cargar el perfil correspondiente del nuevo rol (`loadLandlordProfile` o `loadTenantProfile`).
    - Evaluar `isVerified`:
      - Si `isVerified == true`: Mostrar SnackBar de éxito (*"¡Tu rol ahora es Arrendador! Ya puedes publicar propiedades"* o *"¡Tu rol ahora es Arrendatario! Ya puedes explorar y solicitar arriendos"*). **NO redirigir a completar perfil**.
      - Si `isVerified == false`: Mostrar SnackBar informativo y redirigir a la pantalla de completar perfil del rol respectivo.
  - **Hecho cuando:** Las pruebas de widgets confirmen que un usuario con datos previos no es redirigido y recibe el SnackBar de éxito.

---

## Fase 4: Capa de Presentación - Precarga de Formularios de Perfil

- [x] **Tarea 4.1: Precarga de datos en `CompleteLandlordProfilePage`**
  - **RF Cubiertos:** RF-41.1, RF-41.3, DT-6
  - **Descripción:** Modificar `lib/presentation/pages/landlord/complete_landlord_profile_page.dart`:
    - En `initState`, verificar si `LandlordProvider.landlord` tiene datos; de lo contrario, verificar si `TenantProvider.tenant` tiene datos.
    - Si existen datos, inicializar los controladores: primer nombre, segundo nombre, primer apellido, segundo apellido, tipo de documento, documento, teléfono de contacto y dirección.
  - **Hecho cuando:** Al abrir `CompleteLandlordProfilePage` teniendo datos en `TenantProvider`, los campos aparezcan precargados.

- [x] **Tarea 4.2: Precarga de datos en `CompleteTenantProfilePage`**
  - **RF Cubiertos:** RF-41.2, RF-41.3, DT-6
  - **Descripción:** Modificar `lib/presentation/pages/tenant/complete_tenant_profile_page.dart`:
    - En `initState`, verificar si `TenantProvider.tenant` tiene datos; de lo contrario, verificar si `LandlordProvider.landlord` tiene datos.
    - Si existen datos, inicializar los controladores con la información previa.
  - **Hecho cuando:** Al abrir `CompleteTenantProfilePage` teniendo datos en `LandlordProvider`, los campos aparezcan precargados.

---

## Fase 5: Pruebas de Integración y Regresión Completa

- [x] **Tarea 5.1: Suite de pruebas de integración de persistencia de rol**
  - **RF Cubiertos:** Todos (RF-37 a RF-41)
  - **Descripción:** Crear `test/presentation/pages/profile/role_switch_persistence_integration_test.dart` validando:
    - Flujo completo de Arrendatario a Arrendador sin re-entrada de datos.
    - Flujo completo de Arrendador a Arrendatario.
    - Precarga en ambos formularios de perfil.
  - **Hecho cuando:** La suite pase con exit code 0.

- [x] **Tarea 5.2: Verificación de no-regresión y análisis estático**
  - **Descripción:** Ejecutar `flutter analyze` y `flutter test` en todo el proyecto asegurando 0 errores o advertencias y 100% de tests aprobados.
  - **Hecho cuando:** `flutter analyze` retorne sin incidencias y todas las pruebas pasen.

---

## Fase 6: Cierre en Notion y Repositorio Git

- [x] **Tarea 6.1: Actualización y cierre de la HU en Notion**
  - **Descripción:** Actualizar la Historia de Usuario `HU: Persistencia de Datos al Cambiar Rol` (ID: `3ed8442e-3f49-8047-b396-f0e69bed83d6`) en Notion, registrando el estado "Finalizado" y documentando las pruebas de aceptación cumplidas.
  - **Hecho cuando:** La página de Notion refleje el estado "Finalizado".

- [x] **Tarea 6.2: Commit semántico en Git**
  - **Descripción:** Crear commit en `develop` siguiendo las convenciones del repositorio: `feat 🆕: persistencia y sincronizacion automatica de datos al cambiar de rol entre arrendatario y arrendador (HU-32..36, RF-37..41)`.
  - **Hecho cuando:** El commit quede registrado en el árbol de Git.
