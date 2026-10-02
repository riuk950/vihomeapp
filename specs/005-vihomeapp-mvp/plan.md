# Plan Técnico de Implementación: Sistema de Calificación y Confianza - Ranking de Estrellas (005-vihomeapp-mvp)

Este documento define la arquitectura técnica, la estructura modular en capas (Clean Architecture), el modelo de datos para persistencia y API, las decisiones técnicas justificadas, la resolución de hallazgos de QA y la estrategia de verificación automatizada para el **Sistema de Calificación y Confianza (Ranking de Estrellas)** de ViHome, en estricto cumplimiento de la [Constitución del Proyecto](docs/constitution.md) y de la especificación funcional [specs/005-vihomeapp-mvp/spec.md](specs/005-vihomeapp-mvp/spec.md).

---

## 1. Resolución Integral de Hallazgos de Auditoría QA

El siguiente cuadro formaliza la subsanación técnica y de diseño para cada una de las 16 observaciones identificadas en la auditoría de la especificación:

| ID QA | Hallazgo Detectado por QA | Solución Técnica en el Plan | Cobertura RF / CL |
| :--- | :--- | :--- | :--- |
| **QA-1** | Ambigüedad en el punto de acceso para disparar la calificación en la interfaz. | Se incorpora un botón de acción primario contextual (*"Calificar Arrendador"* o *"Calificar Arrendatario"*) en dos puntos estratégicos: (1) En la tarjeta de la solicitud (`ApplicationCardTenant` y `ApplicationCardLandlord`), y (2) En la vista de detalle de solicitud (`SolicitudDetailPage`). Al pulsarlo, despliega la hoja modal interactiva `RatingBottomSheetModal`. | RF-23.1, RF-24.1 |
| **QA-2** | Discrepancia entre estados terminales (`Aceptada` vs `Finalizada`). | Se unifica el criterio con el modelo de solicitudes preexistente: el estado habilitador en este MVP es `aceptada` (transacción exitosamente pactada). El dominio provee el predicado extensible `application.canBeRated` (`estado == 'aceptada' || estado == 'finalizada'`) para futura compatibilidad sin fricciones. | RF-23.1, RF-23.4 |
| **QA-3** | Alcance de visibilidad de los comentarios de texto (¿públicos o restringidos?). | Se define una política de transparencia comunitaria: el promedio numérico y contador de reseñas son completamente públicos en tarjetas de propiedades y perfiles. Los comentarios textuales son visibles en una pestaña pública del perfil del usuario evaluado (`UserReviewsListWidget`). | RF-26.1, RF-26.4 |
| **QA-4** | Criterio conceptual y técnico de "Usuario Verificado". | Se incorpora el atributo booleano de dominio `isVerified` en la entidad `User` (mapeado como `is_verified` en la base de datos). Permite evaluar limpiamente la regla de confianza inicial sin acoplarse al flujo documental. | RF-27.2, RF-27.3 |
| **QA-5** | Propagación de reputación ante múltiples propiedades del mismo arrendador. | Las tarjetas de inmuebles en listados y mapa incorporan el componente `RatingBadge` con el indicador semántico explícito: *"Propietario: 4.8 ★ (12)"*, educando al usuario de que la calificación certifica al anfitrión. | RF-25.1, RF-26.2, RF-26.3 |
| **QA-6** | Contradicción entre inmutabilidad de reseñas y carácter provisional del puntaje inicial (3.0 ★). | El puntaje base de 3.0 ★ para usuarios verificados sin reseñas **NO** se inserta como un registro en la tabla de calificaciones (`reviews`). Es un valor de confianza proyectado por el dominio (`UserReputation.initialTrustRating = 3.0`). Al ingresar la primera reseña real, el cálculo matemático opera exclusivamente sobre transacciones reales inmutables. | RF-24.3, RF-25.4, RF-27.2, RF-27.3, RNF-15 |
| **QA-7** | Indeterminación matemática del promedio ante cero (0) reseñas ($0/0$). | La entidad `UserReputation` y la utilidad `RatingCalculator` encapsulan el cálculo con guardas seguras: si `totalReviews == 0`, el promedio es `null` / `0.0`. Si `isVerified == true`, el indicador visual es 3.0; si no, expone el estado neutral *"Sin calificaciones aún"*, eliminando cualquier riesgo de error aritmético. | RF-25.3, RF-27.1, RF-27.2 |
| **QA-8** | Coexistencia de RF-26.4 con Duda Abierta sobre renderizado de opiniones individuales. | Se resuelve la duda abierta: el MVP incluye formalmente el componente `ReviewListItem` y la sección de lectura de reseñas recientes en el perfil de usuario evaluado. | RF-26.4 |
| **QA-9** | Múltiples solicitudes aprobadas entre los mismos dos usuarios. | La restricción de unicidad se establece a nivel de tupla compuesta `(solicitud_id, reviewer_id)`. Si las mismas partes concretan un nuevo contrato para otra propiedad (`solicitud_id_2`), cada parte queda autorizada para emitir una nueva evaluación por esa experiencia independiente. | RF-23.2, CL-20 |
| **QA-10** | Caducidad o ventana temporal máxima para calificar. | Se fija una ventana límite de **60 días calendario** desde la fecha de aprobación de la solicitud (`application.updatedAt`). Superado este plazo, `application.isRatingPeriodExpired` retorna verdadero y el botón se desactiva informando que el periodo de evaluación expiró. | RF-23.1, CL-19 |
| **QA-11** | Manejo ante cuenta de contraparte eliminada o suspendida. | Si el usuario a evaluar ya no existe en el sistema, `ReviewRepository` retorna la excepción controlada `TargetUserUnavailableException` y la interfaz presenta el mensaje: *"El usuario ya no se encuentra disponible en la plataforma"*. Las reseñas históricas preexistentes permanecen intactas en la base de datos. | RF-23.5, CL-16 |
| **QA-12** | Propiedad archivada o eliminada tras la aprobación de la solicitud. | Dado que la evaluación califica a la persona física y está anclada a la solicitud aprobada, el borrado del anuncio en el catálogo **NO** inhabilita calificar al propietario. La solicitud conserva el histórico y permite emitir la calificación. | RF-23.1, RF-25.1 |
| **QA-13** | Sanitización de saltos de línea repetitivos y caracteres especiales en comentarios. | Se implementa `CommentSanitizer.sanitize(String text)` que colapsa saltos de línea consecutivos (`\n{3,}`) a un máximo de 2 saltos simples, recorta espacios en blanco exteriores (`trim()`) y trunca rígidamente a 500 caracteres, previniendo distorsiones visuales. | RF-24.2, RF-24.5, CL-21 |
| **QA-14** | Criterio de desempate en redondeo a un decimal. | Se fija matemáticamente la regla de redondeo simétrico a la mitad hacia arriba (*round-half-up*): `(rating * 10).round() / 10`. Ejemplo: $4.85 \to 4.9$; $4.84 \to 4.8$. | RF-25.3 |
| **QA-15** | Corrección de sintaxis formal EARS (Conflicto Constitución 2.2). | Se corrigen todas las cláusulas EARS para emplear estrictamente: `MIENTRAS la solicitud se encuentre en estado Aceptada...`, `CUANDO el usuario seleccione una puntuación...`, `DONDE el usuario agregue un comentario...` y `SI la solicitud no está autorizada, ENTONCES...`. | Constitución 2.2, RF-23, RF-24 |
| **QA-16** | Retroalimentación accionable y expiración de sesión (Constitución 2.4). | Ante expiración del token (error 401 / `SessionExpiredException`), `ReviewProvider` conserva el borrador en memoria y despliega un diálogo con acción de reautenticación sin pérdida de la información digitada. | Constitución 2.4, RF-28.1 |

---

## 2. Estructura de Módulos (Clean Architecture)

El módulo se organiza dentro de la arquitectura limpia existente en el proyecto ViHome, respetando la regla de dependencias unidireccionales y la inyección con `get_it`:

```
lib/
├── core/
│   ├── errors/
│   │   └── review_exceptions.dart             # Excepciones de dominio: AlreadyRatedException, RatingWindowExpiredException, etc.
│   └── utils/
│       ├── rating_calculator.dart             # Lógica matemática pura de promedios, redondeo round-half-up y conteos
│       └── comment_sanitizer.dart             # Limpieza de saltos de línea, espacios redundantes y límite de 500 caracteres
├── domain/
│   ├── entities/
│   │   ├── review.dart                        # Entidad inmutable de Calificación (id, solicitudId, reviewerId, targetUserId, rating, etc.)
│   │   └── user_reputation.dart               # Entidad de Reputación (userId, averageRating, totalReviews, isVerified, etc.)
│   └── repositories/
│       └── review_repository.dart             # Contrato de dominio (createReview, getUserReputation, getUserReviews, canUserRate)
├── data/
│   ├── datasources/
│   │   ├── review_remote_datasource.dart      # Interfaz de acceso remoto a Supabase
│   │   └── review_remote_datasource_impl.dart # Implementación concreta contra tablas Supabase 'reviews' y vistas agregadas
│   ├── models/
│   │   ├── review_model.dart                  # Serialización/deserialización JSON de reseñas
│   │   └── user_reputation_model.dart         # Mapeo de datos agregados de reputación
│   └── repositories/
│       └── review_repository_impl.dart        # Implementación del repositorio con mapeo de excepciones y robustez de red
└── presentation/
    ├── providers/
    │   └── review_provider.dart               # Gestor de estado (Provider): emisión de calificaciones, caché local y estados de carga
    └── widgets/
        ├── rating_stars_bar.dart              # Selector interactivo de estrellas (1-5) con soporte semántico accesible (WCAG AA)
        ├── rating_badge.dart                  # Insignia compacta (ej. "4.8 ★ (12)") para tarjetas de inmuebles y mapa
        ├── user_reputation_header.dart        # Encabezado visual de perfil: promedio, estrellas gráficas y badge de verificación
        ├── review_list_item.dart              # Tarjeta de opinión individual con nombre, fecha relativa, estrellas y texto
        └── rating_bottom_sheet_modal.dart     # Modal interactivo para calificar a la contraparte con validación en tiempo real
```

---

## 3. Modelo de Datos JSON y Esquema Supabase

### 3.1. Propuesta de Esquema para Supabase (SQL DDL)
*Responde a la sugerencia requerida en la Historia de Usuario:*

```sql
-- Tabla principal de calificaciones
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    solicitud_id UUID NOT NULL REFERENCES public.solicitudes(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    
    -- Restricción de negocio: Una sola calificación por usuario emisor en cada solicitud (RF-23.2, CL-20)
    CONSTRAINT unique_review_per_solicitud_user UNIQUE (solicitud_id, reviewer_id),
    -- Restricción de negocio: Impedir autocalificación a nivel de base de datos (RF-23.3, CL-22)
    CONSTRAINT check_no_self_review CHECK (reviewer_id <> target_user_id)
);

-- Índices de consulta rápida para tarjetas de inmuebles y perfiles (RNF-16)
CREATE INDEX IF NOT EXISTS idx_reviews_target_user ON public.reviews(target_user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_solicitud ON public.reviews(solicitud_id);
```

---

### 3.2. Ejemplos Concretos de Cargas Útiles JSON

#### Ejemplo A: Registro de Calificación Válida (Emisión por Arrendatario)
* **RF Cubiertos:** RF-23.1, RF-24.1, RF-24.2, RF-24.3, RF-25.1
* **Descripción:** Calificación enviada por el arrendatario `usr-tenant-01` hacia el propietario `usr-landlord-01` tras completarse la solicitud `sol-1002-cccc-dddd`.

```json
{
  "id": "rev-5001-aaaa-bbbb",
  "solicitud_id": "sol-1002-cccc-dddd",
  "reviewer_id": "usr-tenant-01",
  "reviewer_name": "Carlos Alberto Restrepo",
  "target_user_id": "usr-landlord-01",
  "rating": 5,
  "comment": "Excelente atención durante todo el proceso. La entrega del apartamento fue puntual y las condiciones del inmueble coincidieron al 100% con la publicación.",
  "created_at": "2026-09-30T14:35:00.000Z"
}
```

#### Ejemplo B: Perfil de Usuario con Múltiples Reseñas Reales (Consolidado)
* **RF Cubiertos:** RF-25.2, RF-25.3, RF-25.4, RF-26.1, RF-26.4
* **Descripción:** Reputación calculada para un Arrendador con 12 calificaciones reales recibidas.

```json
{
  "user_id": "usr-landlord-01",
  "user_name": "Beatriz Eugenia Salazar",
  "is_verified": true,
  "average_rating": 4.8,
  "total_reviews": 12,
  "display_text": "Basado en 12 reseñas",
  "recent_reviews": [
    {
      "id": "rev-5001-aaaa-bbbb",
      "author_name": "Carlos Alberto Restrepo",
      "rating": 5,
      "comment": "Excelente atención durante todo el proceso.",
      "created_at": "2026-09-30T14:35:00.000Z"
    },
    {
      "id": "rev-4998-xxxx-yyyy",
      "author_name": "Mariana Gómez",
      "rating": 4,
      "comment": "Muy amable y transparente en la firma del contrato.",
      "created_at": "2026-09-15T10:20:00.000Z"
    }
  ]
}
```

#### Ejemplo C: Usuario Verificado Nuevo (Puntaje Inicial de Confianza)
* **RF Cubiertos:** RF-27.2, CL-23, QA-4, QA-6
* **Descripción:** Usuario verificado que no cuenta con reseñas reales. Exhibe la confianza base provisional de 3.0 ★.

```json
{
  "user_id": "usr-tenant-new-01",
  "user_name": "Andrés Felipe Castro",
  "is_verified": true,
  "average_rating": null,
  "total_reviews": 0,
  "provisional_rating": 3.0,
  "status_label": "Puntaje inicial de confianza",
  "has_real_ratings": false
}
```

#### Ejemplo D: Usuario No Verificado sin Calificaciones (Estado Neutral)
* **RF Cubiertos:** RF-27.1, QA-7
* **Descripción:** Usuario nuevo sin verificación ni reseñas.

```json
{
  "user_id": "usr-tenant-anon-02",
  "user_name": "Usuario Registrado",
  "is_verified": false,
  "average_rating": null,
  "total_reviews": 0,
  "provisional_rating": null,
  "status_label": "Sin calificaciones aún",
  "has_real_ratings": false
}
```

---

## 4. Decisiones Técnicas Justificadas y Alternativas Descartadas

### Decisión 1: Proyección en memoria del puntaje inicial (3.0 ★) para verificados
* **Elección:** Calcular y proyectar el puntaje de 3.0 ★ en la entidad `UserReputation` en capa de dominio cuando `isVerified == true && totalReviews == 0`, sin escribir registros ficticios en la tabla `reviews`.
* **Justificación:** Cumple con la inmutabilidad de la base de datos (RNF-15), evita distorsionar el historial transaccional y permite la transición transparente al 100% de calificaciones reales en cuanto llega la primera reseña legítima (RF-27.3, QA-6).
* **Alternativa Descartada:** Insertar un registro inicial de 3 estrellas en la base de datos con un ID de sistema al momento de verificar al usuario. Se descartó porque provocaría que el usuario tenga permanentemente 1 reseña falsa y desvirtuaría los cálculos de auditoría.

### Decisión 2: Modal deslizable inferior (`RatingBottomSheetModal`) para emitir la reseña
* **Elección:** Desplegar una hoja inferior interactiva modal con selector de 5 estrellas, contador regresivo de caracteres (500 restantes) y botón de envío directo con prevención de doble pulsación.
* **Justificación:** Mantiene al usuario en el contexto de su solicitud, previene transiciones de pantalla pesadas en móvil y facilita la interacción en una sola mano.
* **Alternativa Descartada:** Navegar a una página completa independiente (`/rate-user`). Se descartó por ser una experiencia fragmentada y propensa a abandonos para una acción que toma menos de 20 segundos.

### Decisión 3: Restricción de integridad compuesta `(solicitud_id, reviewer_id)`
* **Elección:** Enforzar la unicidad tanto a nivel de lógica de aplicación en `ReviewProvider` como mediante restricción única en la base de datos (`UNIQUE(solicitud_id, reviewer_id)`).
* **Justificación:** Protege el sistema de condiciones de carrera ante toques rápidos repetidos (CL-20) y asegura que un mismo arrendatario pueda calificar al mismo arrendador en contratos posteriores distintos (QA-9).
* **Alternativa Descartada:** Restringir la relación por pares de usuarios `(reviewer_id, target_user_id)`. Se descartó porque impediría que un inquilino califique una segunda transacción legítima si alquila otro inmueble con el mismo propietario meses después.

### Decisión 4: Sanitización estricta de saltos de línea con `CommentSanitizer`
* **Elección:** Reemplazar secuencias de más de 2 saltos de línea por un doble salto estándar y recortar espacios en blanco.
* **Justificación:** Resuelve el hallazgo QA-13, impidiendo que usuarios maliciosos introduzcan 50 saltos de línea para generar tarjetas deformadas con *RenderFlex overflow* en pantallas de 320 px (RNF-12).
* **Alternativa Descartada:** Prohibir terminantemente cualquier salto de línea. Se descartó por restringir en exceso la legibilidad de párrafos en comentarios constructivos.

### Decisión 5: Inclusión de etiquetas de accesibilidad semántica (`Semantics`) en el selector de estrellas
* **Elección:** Envolver cada estrella interactiva en un widget `Semantics` que declare su valor ordinal y estado (ejemplo: *"Calificar con 4 estrellas de 5"*).
* **Justificación:** Garantiza cumplimiento estricto con WCAG 2.1 AA y RNF-17, permitiendo a personas con lectores de pantalla (TalkBack / VoiceOver) emitir su evaluación de forma autónoma.
* **Alternativa Descartada:** Utilizar simples íconos táctiles con `GestureDetector` sin metadatos de accesibilidad. Se descartó por violar las directrices de accesibilidad de la aplicación.

---

## 5. Estrategia de Tests y Verificación Integral

Siguiendo el principio de **Desarrollo Guiado por Comportamiento y Verificación** (Constitución 2.3), se establecen suites automatizadas de pruebas en las tres capas:

### 5.1. Matriz de Cobertura de Pruebas

| Capa | Archivo de Prueba | Escenarios Verificados | RF / CL / QA Cubiertos |
| :--- | :--- | :--- | :--- |
| **Core / Utils** | `test/core/utils/rating_calculator_test.dart` | • Cálculo de promedio aritmético simple.<br>• Redondeo round-half-up (4.85 $\to$ 4.9; 4.84 $\to$ 4.8).<br>• Manejo seguro de 0 reseñas sin división por cero.<br>• Determinación de estado neutral vs puntaje inicial verificado (3.0 ★).<br>• Transición al 100% de reseñas reales al ingresar la primera calificación. | RF-25.2, RF-25.3, RF-27.1 - RF-27.3, CL-23, QA-6, QA-7, QA-14 |
| **Core / Utils** | `test/core/utils/comment_sanitizer_test.dart` | • Recorte de espacios exteriores (`trim`).<br>• Colapso de saltos de línea excesivos a máximo 2.<br>• Detección de comentarios vacíos o compuestos únicamente por espacios.<br>• Truncamiento rígido y validación de límite de 500 caracteres. | RF-24.2, RF-24.5, CL-21, QA-13 |
| **Domain** | `test/domain/entities/review_test.dart` | • Inmutabilidad de la entidad `Review`.<br>• Igualdad por valor (`==` y `hashCode`).<br>• Restricción de autocalificación (`reviewerId != targetUserId`). | RF-23.3, RF-24.3, CL-22, RNF-15 |
| **Domain** | `test/domain/entities/user_reputation_test.dart` | • Estados de reputación: neutral, verificado sin reseñas, calificado.<br>• Formateo de texto descriptivo (*"Basado en N reseñas"*).<br>• Proyección de puntaje base de 3.0 ★ exclusivo para verificados. | RF-26.1, RF-27.1, RF-27.2, QA-4 |
| **Data** | `test/data/models/review_model_test.dart` | • Deserialización JSON de registros Supabase.<br>• Serialización JSON para payload de inserción.<br>• Mapeo seguro ante campos opcionales (`comment == null`). | RF-24.2, RF-24.3, RNF-15 |
| **Data** | `test/data/repositories/review_repository_impl_test.dart` | • Inserción exitosa de calificación contra datasource mockeado.<br>• Mapeo de violación de unicidad a `AlreadyRatedException`.<br>• Mapeo de autocalificación a `SelfRatingNotAllowedException`.<br>• Manejo de error de red con reintento. | RF-23.2, RF-23.3, RF-23.5, RF-28.1, CL-20 |
| **Presentation** | `test/presentation/providers/review_provider_test.dart` | • Flujo de emisión de calificación con validación de estrellas obligatorias.<br>• Bloqueo de envío múltiple concurrente (estado `isLoading`).<br>• Preservación del texto ante error de red para reintento.<br>• Notificación reactiva al recalcular el promedio del usuario evaluado. | RF-24.1, RF-24.4, RF-25.2, RF-28.1, RF-28.2 |
| **Widgets** | `test/presentation/widgets/rating_stars_bar_test.dart` | • Renderizado de 5 estrellas con selector táctil accesible.<br>• Selección de puntuación del 1 al 5 y emisión de callback.<br>• Etiquetas de accesibilidad semántica (`Semantics`) presentes. | RF-24.1, RNF-17 |
| **Widgets** | `test/presentation/widgets/rating_badge_test.dart` | • Renderizado de insignia en tarjeta de inmueble mostrando promedio del propietario.<br>• Manejo de estado neutral cuando el propietario no tiene reseñas.<br>• Despliegue de puntaje inicial de 3.0 ★ para propietarios verificados nuevos. | RF-26.2, RF-26.3, RF-27.1, RF-27.2, QA-5 |
| **Widgets** | `test/presentation/widgets/rating_bottom_sheet_modal_test.dart` | • Despliegue modal al presionar botón de calificar en solicitud aceptada.<br>• Validación interactiva: impide enviar sin seleccionar estrellas.<br>• Contador dinámico de caracteres restantes del comentario.<br>• Deshabilitación del botón de envío durante la petición de red.<br>• Cierre y confirmación tras registro exitoso. | RF-23.1, RF-24.1, RF-24.4, RF-24.5, RF-28.2, QA-1 |
| **Widgets** | `test/presentation/widgets/user_reputation_header_test.dart` | • Visualización de promedio numérico, representación gráfica de estrellas y contador de opiniones.<br>• Despliegue de pestaña de comentarios recientes con `ReviewListItem`. | RF-26.1, RF-26.4, QA-3, QA-8 |

---

## 6. Comandos de Verificación Automatizada

Los siguientes comandos permiten ejecutar la verificación continua y asegurar la ausencia de regresiones:

### Comando 1: Verificación de Utilidades Matemáticas, Sanitización y Entidades
```bash
flutter test test/core/utils/rating_calculator_test.dart test/core/utils/comment_sanitizer_test.dart test/domain/entities/review_test.dart test/domain/entities/user_reputation_test.dart
```
* **Salida Esperada:**
  ```text
  00:02 +24: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 2: Verificación de Capa de Datos y Modelos
```bash
flutter test test/data/models/review_model_test.dart test/data/repositories/review_repository_impl_test.dart
```
* **Salida Esperada:**
  ```text
  00:03 +16: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 3: Verificación de Lógica de Estado (Provider)
```bash
flutter test test/presentation/providers/review_provider_test.dart
```
* **Salida Esperada:**
  ```text
  00:02 +14: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 4: Verificación de Widgets e Interacción de Usuario
```bash
flutter test test/presentation/widgets/rating_stars_bar_test.dart test/presentation/widgets/rating_badge_test.dart test/presentation/widgets/rating_bottom_sheet_modal_test.dart test/presentation/widgets/user_reputation_header_test.dart
```
* **Salida Esperada:**
  ```text
  00:05 +20: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 5: Verificación Integral de No Regresión
```bash
flutter test
```
* **Salida Esperada:** Todas las suites de prueba existentes y nuevas ejecutadas exitosamente (100% passing).
* **Código de Salida:** `0`

### Comando 6: Análisis Estático de Código
```bash
flutter analyze
```
* **Salida Esperada:**
  ```text
  Analyzing vihomeapp...
  No issues found!
  ```
* **Código de Salida:** `0`
