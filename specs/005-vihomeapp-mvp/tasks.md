# Tareas de Implementación: Sistema de Calificación y Confianza - Ranking de Estrellas (005-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), organizadas en estricto orden de dependencias arquitectónicas (Clean Architecture). Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF), Casos Límite (CL) y Hallazgos de QA que cubre, junto con un criterio de aceptación medible y verificable ("Hecho cuando:").

---

## Fase 1: Utilidades Centrales y Lógica Matemática (Core / Utils)

- [x] **Tarea 1.1: Calculadora de Calificaciones y Reputación (`RatingCalculator`)**
  - **RF Cubiertos:** RF-25.2, RF-25.3, RF-27.1, RF-27.2, RF-27.3, CL-23, QA-6, QA-7, QA-14
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `RatingCalculator` en `lib/core/utils/` para la lógica matemática del sistema de reputación:
    - Cálculo de promedio aritmético redondeado a un decimal con regla simétrica *round-half-up* ($4.85 \to 4.9$; $4.84 \to 4.8$).
    - Manejo seguro de 0 reseñas sin división por cero ($0/0$).
    - Proyección del estado neutral (*"Sin calificaciones aún"*) si no es verificado, o del puntaje base inicial ($3.0 ★$ provisional) si `isVerified == true`.
    - Transición automática al 100% sobre calificaciones reales cuando `totalReviews >= 1`.
  - **Hecho cuando:** `flutter test test/core/utils/rating_calculator_test.dart` retorne exit code 0 validando todos los cálculos de promedio, redondeo, estado neutral, puntaje base verificado y transiciones.

- [x] **Tarea 1.2: Sanitizador de Comentarios y Control de Contenido (`CommentSanitizer`)**
  - **RF Cubiertos:** RF-24.2, RF-24.5, CL-21, QA-13
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `CommentSanitizer` en `lib/core/utils/` para normalizar y asegurar los comentarios:
    - Recorte de espacios en blanco al inicio y al final (`trim()`).
    - Colapso de saltos de línea excesivos (`\n{3,}`) a un máximo de 2 consecutivos para preservar la simetría de la interfaz.
    - Detección de comentarios vacíos o compuestos únicamente por espacios en blanco, tratándolos como nulos/ausentes.
    - Validación y truncamiento seguro al límite máximo de 500 caracteres.
  - **Hecho cuando:** `flutter test test/core/utils/comment_sanitizer_test.dart` retorne exit code 0 validando la sanitización de saltos de línea, detección de comentarios en blanco y la restricción estricta de 500 caracteres.

- [x] **Tarea 1.3: Excepciones de Dominio de Calificaciones (`ReviewExceptions`)**
  - **RF Cubiertos:** RF-23.2, RF-23.3, RF-23.5, RF-28.1, QA-11, QA-16
  - **Descripción:** Definir la jerarquía de excepciones específicas del módulo de calificaciones en `lib/core/errors/review_exceptions.dart`:
    - `SelfRatingNotAllowedException`: Intento de calificar a uno mismo.
    - `AlreadyRatedException`: Intento de calificar más de una vez la misma solicitud.
    - `RatingWindowExpiredException`: Intento de calificar tras superar el plazo de 60 días.
    - `UnauthorizedRatingException`: Emisión de calificación por un usuario ajeno a la postulación.
    - `TargetUserUnavailableException`: Usuario evaluado suspendido o inexistente.
    - `SessionExpiredRatingException`: Token de autenticación vencido durante el envío.
  - **Hecho cuando:** `flutter test test/core/errors/review_exceptions_test.dart` retorne exit code 0 validando la tipificación, mensajes amigables y serialización de todas las excepciones.

---

## Fase 2: Capa de Dominio y Modelos de Datos (Domain & Data)

- [x] **Tarea 2.1: Entidades de Dominio `Review` y `UserReputation` y Contrato `ReviewRepository`**
  - **RF Cubiertos:** RF-23.2, RF-23.3, RF-24.3, RF-25.1, RF-26.1, RF-27.1, RF-27.2, RNF-15, CL-22, QA-4, QA-6
  - **Descripción:** 
    - Implementar la entidad inmutable `Review` en `lib/domain/entities/review.dart` con validación de autocalificación (`reviewerId != targetUserId`) y propiedades inalterables (`id`, `solicitudId`, `reviewerId`, `targetUserId`, `rating`, `comment`, `createdAt`).
    - Implementar la entidad de valor `UserReputation` en `lib/domain/entities/user_reputation.dart` con `userId`, `averageRating`, `totalReviews`, `isVerified`, `statusLabel` y propiedades de formateo descriptivo (*"Basado en N reseñas"*).
    - Definir la interfaz abstracta `ReviewRepository` en `lib/domain/repositories/review_repository.dart` con las operaciones `createReview`, `getUserReputation`, `getUserReviews` y `canUserRateApplication`.
  - **Hecho cuando:** `flutter test test/domain/entities/review_test.dart test/domain/entities/user_reputation_test.dart` retorne exit code 0 validando la inmutabilidad, cálculo de propiedades derivadas e igualdad por valor.

- [x] **Tarea 2.2: Modelos de Datos `ReviewModel` y `UserReputationModel`**
  - **RF Cubiertos:** RF-24.2, RF-24.3, RF-25.4, RF-26.4, RNF-15, QA-8
  - **Descripción:** Implementar las clases de datos en `lib/data/models/`:
    - `ReviewModel`: Deserialización desde JSON de Supabase y serialización para inserción (`toJson`), con soporte para campos opcionales (`comment == null`) y timestamps ISO 8601.
    - `UserReputationModel`: Deserialización y ensamblado de datos agregados de reputación y reseñas recientes provenientes de consultas a la base de datos.
  - **Hecho cuando:** `flutter test test/data/models/review_model_test.dart test/data/models/user_reputation_model_test.dart` retorne exit code 0 validando el mapeo bidireccional y la tolerancia a campos nulos.

- [x] **Tarea 2.3: Implementación del Repositorio `ReviewRepositoryImpl` y Datasource Remoto**
  - **RF Cubiertos:** RF-23.1, RF-23.2, RF-23.5, RF-28.1, CL-19, CL-20, QA-9, QA-10, QA-11
  - **Descripción:** Implementar el acceso a datos en `lib/data/`:
    - `ReviewRemoteDataSource` y `ReviewRemoteDataSourceImpl` (`lib/data/datasources/`) para interactuar con la tabla `reviews` de Supabase.
    - `ReviewRepositoryImpl` (`lib/data/repositories/`) implementando el contrato de dominio: captura de códigos de error de Postgres (23505 para unicidad violada $\to$ `AlreadyRatedException`, 23514 para check constraint $\to$ `ReviewValidationException`), expiración de ventana de 60 días y control de conectividad.
  - **Hecho cuando:** `flutter test test/data/repositories/review_repository_impl_test.dart` retorne exit code 0 con mocks verificando todos los flujos de éxito y mapeo estricto de excepciones.

---

## Fase 3: Gestión de Estado y Lógica Reactiva (Presentation / Provider)

- [x] **Tarea 3.1: Proveedor de Estado `ReviewProvider`**
  - **RF Cubiertos:** RF-24.1, RF-24.4, RF-25.2, RF-28.1, RF-28.2, CL-20, QA-16
  - **Descripción:** Implementar `ReviewProvider` en `lib/presentation/providers/review_provider.dart`:
    - Manejo de estados de carga (`isLoading`), éxito y error.
    - Método `submitReview(...)` con validación interactiva previa (bloqueo si la puntuación es 0 y deshabilitación durante el envío para evitar dobles clics).
    - Métodos para consultar reputación por usuario (`fetchUserReputation`) y verificar elegibilidad para calificar (`checkCanRate`).
    - Preservación del borrador (estrellas y comentario) ante fallo de red o expiración de sesión para permitir el reintento inmediato sin pérdida de datos.
  - **Hecho cuando:** `flutter test test/presentation/providers/review_provider_test.dart` retorne exit code 0 validando la máquina de estados, el bloqueo de pulsación concurrente, la resiliencia ante errores de red y la notificación reactiva a los escuchas.

- [x] **Tarea 3.2: Registro en el Contenedor de Inyección de Dependencias (`get_it`)**
  - **RF Cubiertos:** RNF-16, Constitución 2.1
  - **Descripción:** Registrar `ReviewRemoteDataSource`, `ReviewRepository` y `ReviewProvider` en el contenedor central de inyección de dependencias `lib/core/di/injection_container.dart` (o service locator correspondiente), asegurando la resolución adecuada de instancias para producción y tests.
  - **Hecho cuando:** `flutter test test/core/di/review_di_test.dart` retorne exit code 0 validando que todas las dependencias del módulo de calificaciones se resuelvan correctamente.

---

## Fase 4: Componentes Reutilizables de Interfaz de Usuario (Widgets)

- [x] **Tarea 4.1: Barra Interactiva de Estrellas con Accesibilidad Semántica (`RatingStarsBar`)**
  - **RF Cubiertos:** RF-24.1, RF-26.1, RNF-17
  - **Descripción:** Implementar pruebas de widgets y el componente `RatingStarsBar` en `lib/presentation/widgets/rating_stars_bar.dart`:
    - Modo interactivo (para calificar) y modo de solo lectura (para visualización).
    - 5 estrellas doradas/ámbar con respuesta al toque y actualización visual fluida.
    - Soporte completo de accesibilidad mediante `Semantics` que declare ordenadamente a lectores de pantalla (TalkBack / VoiceOver) la puntuación seleccionada (ej. *"Calificar con 4 de 5 estrellas"*).
  - **Hecho cuando:** `flutter test test/presentation/widgets/rating_stars_bar_test.dart` retorne exit code 0 validando la selección táctil de estrellas, el modo lectura y los metadatos de accesibilidad semántica.

- [x] **Tarea 4.2: Insignia Compacta de Reputación para Inmuebles y Mapas (`RatingBadge`)**
  - **RF Cubiertos:** RF-26.2, RF-26.3, RF-27.1, RF-27.2, QA-5
  - **Descripción:** Implementar pruebas de widgets y el componente `RatingBadge` en `lib/presentation/widgets/rating_badge.dart`:
    - Diseño compacto con ícono de estrella y promedio numérico: ej. `4.8 ★ (12)`.
    - Etiqueta contextual para tarjetas de inmueble: *"Propietario: 4.8 ★ (12)"*.
    - Presentación de insignia neutral cuando el usuario no cuenta con reseñas (*"Nuevo"* o *"Sin calificaciones"*).
    - Despliegue del distintivo de confianza para propietarios verificados sin reseñas (*"3.0 ★ Inicial"*).
  - **Hecho cuando:** `flutter test test/presentation/widgets/rating_badge_test.dart` retorne exit code 0 validando todos los estados visuales en tamaños reducidos sin generar desbordamientos (*RenderFlex overflow*).

- [x] **Tarea 4.3: Tarjeta de Reseña Individual para Listados (`ReviewListItem`)**
  - **RF Cubiertos:** RF-26.4, QA-3, QA-8
  - **Descripción:** Implementar pruebas de widgets y el componente `ReviewListItem` en `lib/presentation/widgets/review_list_item.dart`:
    - Exhibición del avatar y nombre del evaluador.
    - Fecha relativa utilizando `ApplicationDateFormatter` (ej. *"Hace 3 días"* o *"14 sep 2026"*).
    - Visualización de la puntuación en estrellas otorgada.
    - Cuerpo del comentario con soporte multilinea sanitizado y truncamiento elíptico seguro.
  - **Hecho cuando:** `flutter test test/presentation/widgets/review_list_item_test.dart` retorne exit code 0 validando la correcta renderización de datos y la sanitización de textos extensos.

---

## Fase 5: Modal Interactivo y Visualización en Perfiles / Solicitudes

- [x] **Tarea 5.1: Modal Deslizable de Calificación (`RatingBottomSheetModal`)**
  - **RF Cubiertos:** RF-23.1, RF-24.1, RF-24.2, RF-24.4, RF-24.5, RF-28.1, RF-28.2, QA-1, QA-13
  - **Descripción:** Implementar pruebas de widgets y el modal interactivo `RatingBottomSheetModal` en `lib/presentation/widgets/rating_bottom_sheet_modal.dart`:
    - Título claro identificando a la contraparte evaluada (nombre y rol: Arrendador o Arrendatario).
    - Integración de `RatingStarsBar` con validación que impida enviar si no hay puntuación seleccionada.
    - Campo de texto opcional con contador dinámico de caracteres restantes (ej. *"450/500"*).
    - Botón de envío que muestra un indicador circular de carga (`CircularProgressIndicator`) y se desactiva durante la petición de red.
    - Gestión de errores amigables (alerta flotante o mensaje en el modal sin perder el borrador).
  - **Hecho cuando:** `flutter test test/presentation/widgets/rating_bottom_sheet_modal_test.dart` retorne exit code 0 validando el ciclo completo de validación interactiva, conteo de caracteres, bloqueo de doble clic y emisión.

- [x] **Tarea 5.2: Disparador de Calificación en Tarjetas de Solicitud y Detalle**
  - **RF Cubiertos:** RF-23.1, RF-23.4, RF-24.6, CL-19, QA-1, QA-2
  - **Descripción:** Integrar el botón contextual de calificación en la interfaz existente:
    - En `ApplicationCardLandlord` y `ApplicationCardTenant`: desplegar el botón *"Calificar Arrendador"* o *"Calificar Arrendatario"* únicamente cuando la solicitud se encuentre en estado `Aceptada` y no haya sido calificada previamente.
    - En `SolicitudDetailPage`: incorporar el botón de acción en la barra inferior o encabezado.
    - Ocultamiento estricto si la solicitud está `Pendiente`, `Rechazada`, si ya fue evaluada por ese usuario o si superó la ventana de 60 días.
  - **Hecho cuando:** `flutter test test/presentation/pages/landlord/solicitudes_landlord_rating_integration_test.dart test/presentation/pages/tenant/solicitudes_tenant_rating_integration_test.dart` retorne exit code 0 validando la presencia, activación y apertura modal del botón de calificación en las solicitudes elegibles.

- [x] **Tarea 5.3: Encabezado de Reputación y Lista de Opiniones en Perfil de Usuario**
  - **RF Cubiertos:** RF-26.1, RF-26.4, RF-27.1, RF-27.2, RF-27.3, QA-3, QA-4, QA-8
  - **Descripción:** Implementar el componente visual de perfil `UserReputationHeader` y la sección `UserReviewsListWidget` en `lib/presentation/widgets/`:
    - Despliegue del promedio numérico (ej. `4.8`), estrellas gráficas y contador (*"Basado en N reseñas"*).
    - Exhibición del estado neutral (*"Sin calificaciones aún"*) o del puntaje base inicial (*"3.0 ★ Puntaje inicial de confianza"* para verificados).
    - Lista deslizable vertical u horizontal con los comentarios de transacciones reales usando `ReviewListItem`.
  - **Hecho cuando:** `flutter test test/presentation/widgets/user_reputation_header_test.dart` retorne exit code 0 verificando todos los estados de perfil y el despliegue ordenado de reseñas.

---

## Fase 6: Verificación Integral de Suite de Pruebas y Calidad Transversal

- [x] **Tarea 6.1: Ejecución Completa de la Suite de Pruebas Automatizadas**
  - **RF Cubiertos:** Cobertura integral de la entrega (RF-23 a RF-28, CL-19 a CL-23, QA-1 a QA-16)
  - **Descripción:** Ejecutar la totalidad de las suites de prueba unitarias, de modelos, de repositorios, de proveedores y de widgets de la aplicación, certificando 100% de pruebas pasando y cero regresión sobre módulos previos.
  - **Hecho cuando:** El comando `flutter test` retorne exit code 0 con la totalidad de pruebas aprobadas exitosamente.

- [x] **Tarea 6.2: Verificación de Análisis Estático de Código y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal del código (Constitución 2.1, 2.3)
  - **Descripción:** Ejecutar el análisis estático en todo el proyecto ViHome, garantizando cero advertencias, cero errores de tipado y cero problemas de linter.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).
