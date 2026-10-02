# Tareas de Implementación: Visualización de Ranking en Perfiles y Propiedades (006-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), organizadas en estricto orden de dependencias arquitectónicas (Clean Architecture). Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF), Casos Límite (CL) y Hallazgos de QA que cubre, junto con un criterio de aceptación medible y verificable ("Hecho cuando:").

---

## Fase 1: Extensiones de Componentes Base de UI (Widgets)

- [x] **Tarea 1.1: Extensión de `ReviewListItem` con Truncado a 3 Líneas y Alternancia "Ver más / Ver menos"**
  - **RF Cubiertos:** RF-29.2, CL-28, QA-6
  - **Descripción:** Modificar `lib/presentation/widgets/review_list_item.dart` y escribir sus pruebas unitarias en `test/presentation/widgets/review_list_item_expansion_test.dart`:
    - Incorporar control de texto colapsable con un límite inicial de 3 líneas (`maxLines: 3`, `TextOverflow.ellipsis`).
    - Añadir botón de acción accesible *"Ver más"* para comentarios extensos (hasta 500 caracteres).
    - Al ser pulsado, expandir la totalidad del texto y alternar la etiqueta a *"Ver menos"*.
    - Si el comentario tiene 3 líneas o menos, no renderizar el botón de alternancia.
  - **Hecho cuando:** `flutter test test/presentation/widgets/review_list_item_expansion_test.dart` retorne exit code 0 validando el truncado inicial, la expansión interactiva, el colapso posterior y la no visualización en comentarios cortos.

- [x] **Tarea 1.2: Extensión de `RatingBadge` con Soporte de Insignia Provisional y Adaptabilidad a 320 px**
  - **RF Cubiertos:** RF-31.2, CL-24, RNF-20, RNF-21, QA-8
  - **Descripción:** Extender `lib/presentation/widgets/rating_badge.dart` y escribir sus pruebas en `test/presentation/widgets/rating_badge_compact_test.dart`:
    - Añadir soporte para el parámetro opcional `isProvisional: bool` que renderice la variante compacta `3.0 ★ (Inicial)` con estilo visual diferenciado.
    - Soporte para estado neutral compacto cuando la calificación no esté disponible.
    - Garantizar que el componente no sufra desbordamientos horizontales (`RenderFlex overflow`) en layouts con ancho de 320 px.
    - Proveer etiquetas semánticas para lectores de pantalla.
  - **Hecho cuando:** `flutter test test/presentation/widgets/rating_badge_compact_test.dart` retorne exit code 0 validando la variante provisional, estado neutral y ausencia de desbordamiento en 320 px.

---

## Fase 2: Nuevo Modal de Reseñas del Propietario (`LandlordReputationBottomSheet`)

- [x] **Tarea 2.1: Hoja Modal Inferior de Opiniones del Arrendador (`LandlordReputationBottomSheet`)**
  - **RF Cubiertos:** RF-30.3, RF-32.1, RF-33.1, QA-1, QA-3
  - **Descripción:** Implementar el widget interactivo `LandlordReputationBottomSheet` en `lib/presentation/widgets/landlord_reputation_bottom_sheet.dart` y sus pruebas en `test/presentation/widgets/landlord_reputation_bottom_sheet_test.dart`:
    - Encabezado con información del arrendador y componente `UserReputationHeader`.
    - Lista deslizable de opiniones históricas renderizadas mediante `ReviewListItem`.
    - Indicador visual de carga durante la obtención de reseñas y estado amigable ante lista vacía (*"El arrendador aún no cuenta con reseñas de inquilinos"*).
    - Barra de arrastre superior y botón de cierre amigable para regresar de inmediato al detalle del inmueble sin abandonar el contexto.
  - **Hecho cuando:** `flutter test test/presentation/widgets/landlord_reputation_bottom_sheet_test.dart` retorne exit code 0 validando apertura, renderizado de encabezado, lista de reseñas y cierre.

---

## Fase 3: Integración en Detalle de Propiedad (`detalles_propiedades_page.dart`)

- [x] **Tarea 3.1: Insignia de Reputación y Disparador de Modal en la Tarjeta del Arrendador**
  - **RF Cubiertos:** RF-30.1, RF-30.2, RF-30.4, RF-31.1, RF-31.2, RF-32.2, RF-33.1, RNF-19, CL-24, CL-29, QA-1, QA-5, QA-7
  - **Descripción:** Integrar la consulta y visualización de reputación en `lib/presentation/pages/propiedades/detalles_propiedades_page.dart`:
    - Iniciar la consulta asíncrona de reputación del arrendador en `initState` / tras cargar los datos del propietario sin bloquear la pantalla principal.
    - En `_buildLandlordProfile()`, renderizar la insignia de reputación (`RatingBadge` / estrellas y promedio) junto al nombre del anfitrión.
    - Soporte para estados: cargando (esqueleto no invasivo), con reseñas (`4.8 ★ (12)`), verificado sin reseñas (`3.0 ★ Inicial`) y no verificado (`Sin calificaciones aún`).
    - Al tocar la insignia o la tarjeta del arrendador, invocar `showModalBottomSheet` desplegando `LandlordReputationBottomSheet`.
    - Si el usuario en sesión es el mismo propietario, exhibir su propia insignia idéntica a la vista de los postulantes.
  - **Hecho cuando:** `flutter test test/presentation/pages/propiedades/detalles_propiedades_rating_integration_test.dart` retorne exit code 0 validando la presencia del badge, estados neutrales, apertura modal y resiliencia ante errores de red.

---

## Fase 4: Integración en Pantallas Principales de Usuario (Perfil y Panel de Control)

- [x] **Tarea 4.1: Encabezado de Reputación y Listado de Opiniones en `perfil_page.dart`**
  - **RF Cubiertos:** RF-29.1, RF-29.2, RF-29.3, RF-31.1, RF-31.2, RF-31.3, RF-33.2, QA-2, QA-4
  - **Descripción:** Integrar la sección de reputación y opiniones en `lib/presentation/pages/navegation/perfil_page.dart`:
    - Cargar la reputación y opiniones del usuario autenticado mediante `ReviewProvider`.
    - Renderizar `UserReputationHeader` debajo de la tarjeta de bienvenida y estado de verificación.
    - Desplegar la sección de opiniones recibidas con `ReviewListItem`.
    - Integrar la recarga de datos con `RefreshIndicator` para refrescar reputación al deslizar hacia abajo.
  - **Hecho cuando:** `flutter test test/presentation/pages/navegation/perfil_page_rating_integration_test.dart` retorne exit code 0 validando el encabezado de reputación en el perfil, la lista de opiniones y el refresco.

- [x] **Tarea 4.2: Visualización de Ranking en el Panel de Control del Arrendador (`panel_page.dart`)**
  - **RF Cubiertos:** RF-34.1, RF-34.2, RF-34.3, RF-31.1, RF-31.2, RF-32.1, RF-32.2, RF-33.1
  - **Descripción:** Integrar la sección de reputación y ranking en `lib/presentation/pages/navegation/panel_page.dart`:
    - Consultar la reputación del usuario con rol de arrendador mediante `ReviewProvider`.
    - Renderizar la tarjeta de ranking (`UserReputationHeader` con interactividad) en la cabecera del panel del propietario, inmediatamente debajo del saludo y banner de verificación.
    - Permitir la apertura de `LandlordReputationBottomSheet` al pulsar sobre el componente para consultar las opiniones históricas.
    - Envolver el contenido con `RefreshIndicator` para soporte de recarga por deslizamiento vertical (*pull-to-refresh*).
  - **Hecho cuando:** `flutter test test/presentation/pages/navegation/panel_page_rating_integration_test.dart` retorne exit code 0 validando la presencia del ranking en el panel del arrendador, el manejo de estados (con reseñas, provisional `3.0 ★`, neutral) y el refresco.

---

## Fase 5: Verificación Integral de Suite de Pruebas y Calidad Transversal

- [x] **Tarea 5.1: Ejecución Completa de la Suite de Pruebas Automatizadas**
  - **RF Cubiertos:** Cobertura integral de la entrega (RF-29 a RF-34, RNF-19 a RNF-21, CL-24 a CL-29, QA-1 a QA-9)
  - **Descripción:** Ejecutar la totalidad de las suites de prueba unitarias y de widgets de ViHome, certificando 100% de pruebas pasando y 0 regresiones sobre los módulos previos.
  - **Hecho cuando:** El comando `flutter test` retorne exit code 0 con la totalidad de pruebas aprobadas exitosamente.

- [x] **Tarea 5.2: Verificación de Análisis Estático de Código y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal del código (Constitución 2.1, 2.3)
  - **Descripción:** Ejecutar el análisis estático en todo el proyecto ViHome, garantizando cero advertencias, cero errores de tipado y cero problemas de linter.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).

---

## Fase 6: Actualización Reactiva y Escucha de Ranking en la Navegación Entre Pantallas

- [x] **Tarea 6.1: Sincronización Automática de Ranking en `home_page.dart` al Conmutar a Pestaña de Perfil/Panel**
  - **RF Cubiertos:** RF-35.1, RF-35.2, RNF-22, CL-30
  - **Descripción:** Modificar `lib/presentation/pages/navegation/home_page.dart` para que, en `onTap(index)`, al seleccionar la pestaña correspondiente (`index == 3` - Panel para arrendador o Perfil para arrendatario), se dispare de forma asíncrona la sincronización de la reputación comunitaria y las opiniones del usuario mediante `reviewProvider.fetchUserReputation` y `reviewProvider.fetchUserReviews` sin bloquear el cambio de pestaña ni la fluidez de la interfaz.
  - **Hecho cuando:** Al cambiar al tab 3 en `HomePage`, se invoque la actualización de reputación y opiniones en `ReviewProvider`.

- [x] **Tarea 6.2: Escucha Reactiva y Sincronización de Retorno en `panel_page.dart` y `perfil_page.dart`**
  - **RF Cubiertos:** RF-35.1, RF-35.2, RF-35.4, RNF-22
  - **Descripción:** En `lib/presentation/pages/navegation/panel_page.dart` y `lib/presentation/pages/navegation/perfil_page.dart`, asegurar que el estado de reputación y ranking reaccione de inmediato a cambios notificados por `ReviewProvider` y se sincronice cuando la pantalla reingrese al primer plano de navegación.
  - **Hecho cuando:** Cualquier nueva calificación emitida o cambio de estado notificado en `ReviewProvider` se refleje inmediatamente en los widgets `UserReputationHeader` y listados de ambas pantallas sin recarga manual.

- [x] **Tarea 6.3: Consulta y Frescura de Reputación al Entrar y Reingresar a `detalles_propiedades_page.dart`**
  - **RF Cubiertos:** RF-35.3, RF-35.4, RNF-22
  - **Descripción:** En `lib/presentation/pages/propiedades/detalles_propiedades_page.dart`, asegurar que al ingresar o retornar al detalle del inmueble, se consulte la reputación más reciente del arrendador asociado para reflejar de inmediato cualquier cambio de calificación producido durante la sesión.
  - **Hecho cuando:** La insignia del propietario en `detalles_propiedades_page.dart` refleje los datos actualizados de reputación y opiniones sin conservar datos obsoletos.

- [x] **Tarea 6.4: Pruebas Automatizadas de Navegación y Escucha Reactiva de Ranking**
  - **RF Cubiertos:** RF-35.1, RF-35.2, RF-35.3, RF-35.4, RNF-22
  - **Descripción:** Crear `test/presentation/pages/navegation/ranking_navigation_listener_integration_test.dart` validando:
    1. Conmutación a la pestaña del Panel en `HomePage` gatilla `fetchUserReputation` y `fetchUserReviews`.
    2. Conmutación a la pestaña del Perfil en `HomePage` gatilla `fetchUserReputation` y `fetchUserReviews`.
    3. Emisión de una calificación actualiza reactivamente el ranking visible en `PanelPage` y `PerfilPage`.
    4. Entrada a `DetallesPropiedadesPage` consulta la reputación del propietario.
  - **Hecho cuando:** `flutter test test/presentation/pages/navegation/ranking_navigation_listener_integration_test.dart` retorne exit code 0 con 100% de éxito.

- [x] **Tarea 6.5: Verificación Integral de Suite de Pruebas y Linter**
  - **RF Cubiertos:** Cobertura integral (RF-29 a RF-35)
  - **Descripción:** Ejecutar `flutter test` y `flutter analyze` asegurando que no existan regresiones y que se mantengan 0 issues de linter.
  - **Hecho cuando:** `flutter test` y `flutter analyze` retornen exit code 0.

---

## Fase 7: Registro Automático de Calificación de Usuario Verificado al Completar Perfil

- [x] **Tarea 7.1: Adaptación de Capas Domain y Data para Calificaciones de Verificación de Perfil**
  - **RF Cubiertos:** RF-36.1, RF-36.2, RF-36.4, CL-31
  - **Descripción:** 
    1. En `lib/domain/entities/review.dart` y `lib/data/models/review_model.dart`, permitir que `solicitudId` sea opcional/nulo (`String? solicitudId`), ajustando la validación de autoevaluación para que aplique únicamente cuando `solicitudId != null`.
    2. En `lib/data/datasources/review_remote_datasource.dart` y su implementación `review_remote_datasource_impl.dart`, agregar `registerVerifiedUserReview({required String userId, String? userName})`, el cual evalúa si ya existe una calificación con comentario `'Usuario verificado'` para el usuario antes de insertar el registro de 3 estrellas en `reviews` con `solicitud_id = null`.
    3. En `lib/domain/repositories/review_repository.dart` y su implementación `lib/data/repositories/review_repository_impl.dart`, definir e implementar `Future<Review> registerVerifiedUserReview({required String userId, String? userName})`.
  - **Hecho cuando:** Los contratos y modelos soporten calificaciones de verificación con `solicitud_id` nulo y el datasource garantice idempotencia en la inserción.

- [x] **Tarea 7.2: Incorporación de Método `registerVerifiedUserReview` en `ReviewProvider`**
  - **RF Cubiertos:** RF-36.3, RF-36.5, RNF-22
  - **Descripción:** Modificar `lib/presentation/providers/review_provider.dart` para exponer `Future<void> registerVerifiedUserReview({required String userId, String? userName})`. Al completarse exitosamente la inserción, re-consultar automáticamente la reputación (`fetchUserReputation(userId)`) y las opiniones (`fetchUserReviews(userId)`) del usuario, notificando a los listeners para actualizar en tiempo real el ranking en todas las pantallas.
  - **Hecho cuando:** `ReviewProvider.registerVerifiedUserReview` persista la calificación, refresque el estado reactivo e informe a los widgets suscritos.

- [x] **Tarea 7.3: Invocación de Calificación de Usuario Verificado en Flujos de Completar Perfil**
  - **RF Cubiertos:** RF-36.1, RF-36.2, RF-36.3, RF-36.5, CL-31
  - **Descripción:**
    1. En `lib/presentation/pages/landlord/complete_landlord_profile_page.dart`: tras guardar con éxito el perfil del arrendador (`LandlordProvider.saveLandlordProfile`), invocar de forma asíncrona no bloqueante `ReviewProvider.registerVerifiedUserReview(userId: ..., userName: ...)`.
    2. En `lib/presentation/pages/tenant/complete_tenant_profile_page.dart`: tras guardar con éxito el perfil del arrendatario (`TenantProvider.saveTenantProfile`), invocar de forma asíncrona no bloqueante `ReviewProvider.registerVerifiedUserReview(userId: ..., userName: ...)`.
    3. Manejar cualquier error de red de forma resiliente para que la pantalla continúe su flujo y notifique al usuario sin interrupciones.
  - **Hecho cuando:** Tanto al completar perfil de arrendador como de arrendatario se envíe automáticamente la reseña de verificación a Supabase.

- [x] **Tarea 7.4: Pruebas Automatizadas de Integración para Calificación de Usuario Verificado**
  - **RF Cubiertos:** RF-36.1, RF-36.2, RF-36.3, RF-36.4, RF-36.5, CL-31
  - **Descripción:** Crear `test/presentation/pages/profile/verified_user_review_integration_test.dart` validando:
    1. Al completar perfil de arrendador, se llama a `registerVerifiedUserReview` con rating 3 y comentario "Usuario verificado".
    2. Al completar perfil de arrendatario, se llama a `registerVerifiedUserReview` con rating 3 y comentario "Usuario verificado".
    3. Idempotencia: el guardado posterior de datos no duplica la calificación de verificación.
    4. Resiliencia: si el servicio de reseñas falla, el flujo de completar perfil culmina con éxito.
  - **Hecho cuando:** `flutter test test/presentation/pages/profile/verified_user_review_integration_test.dart` pase al 100%.

- [x] **Tarea 7.5: Verificación Integral de Suite de Pruebas y Análisis Estático de Código**
  - **RF Cubiertos:** Cobertura integral (RF-29 a RF-36, DoD 6)
  - **Descripción:** Ejecutar `flutter test` y `flutter analyze` en todo el proyecto asegurando que no existan advertencias ni fallos en ninguna suite.
  - **Hecho cuando:** `flutter test` y `flutter analyze` retornen código de salida 0.


