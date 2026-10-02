# Plan Técnico de Implementación: Visualización de Ranking en Perfiles y Propiedades (006-vihomeapp-mvp)

Este documento define la arquitectura técnica, la estructura modular en capas (Clean Architecture), el modelo de datos JSON, las decisiones técnicas justificadas, la resolución de los 9 hallazgos de auditoría QA y la estrategia de verificación automatizada para la **Visualización de Ranking en Perfiles y Propiedades** en ViHome, en estricto cumplimiento de la [Constitución del Proyecto](docs/constitution.md) y de la especificación funcional [specs/006-vihomeapp-mvp/spec.md](specs/006-vihomeapp-mvp/spec.md).

---

## 1. Resolución Integral de Hallazgos de Auditoría QA

El siguiente cuadro formaliza la subsanación técnica y de diseño para cada una de las 9 observaciones detectadas en la revisión de aseguramiento de calidad:

| ID QA | Hallazgo Detectado por QA | Solución Técnica en el Plan | Cobertura RF / CL |
| :--- | :--- | :--- | :--- |
| **QA-1** | Ambigüedad en el acceso a perfil ajeno vs. opiniones en detalle de propiedad. | En la Pantalla de Detalle de Propiedad (`detalles_propiedades_page.dart`), al presionar la tarjeta o insignia de calificación del arrendador, se despliega la hoja modal inferior `LandlordReputationBottomSheet`. Esta presenta el resumen de reputación (`UserReputationHeader`) y la lista de opiniones históricas (`ReviewListItem`) sin romper el flujo ni abandonar el contexto del inmueble. | RF-29.1, RF-30.3 |
| **QA-2** | Tratamiento ante usuarios con roles duales (propietario e inquilino). | La reputación se modela de forma unificada sobre la persona física (`UserReputation.userId`), reflejando su trayectoria global en ViHome. En el contexto donde se visualice, se despliega una insignia contextual indicando su rol activo principal en esa pantalla. | RF-29.3, RF-29.4 |
| **QA-3** | Mecanismo de despliegue de opiniones históricas desde el detalle de la propiedad. | Se implementa el widget interactivo `LandlordReputationBottomSheet` accesible mediante `showModalBottomSheet`. Permite scroll interno, carga paginada/asíncrona y botón de cierre, sin requerir una ruta separada de `GoRouter`. | RF-30.3 |
| **QA-4** | Tensión entre mandato ubicuo de estrellas (`RF-29.1`) y estado sin reseñas (`RF-31.1`). | El componente `UserReputationHeader` maneja internamente la lógica de renderizado: si `totalReviews == 0 && !isVerified`, oculta las estrellas y renderiza el chip neutral `"Sin calificaciones aún"`. Si `isVerified == true`, renderiza `3.0 ★` con el chip `"Puntaje inicial de confianza"`. Si `totalReviews > 0`, renderiza el promedio real con sus estrellas. | RF-29.1, RF-31.1, RF-31.2 |
| **QA-5** | Visualización de la propia propiedad por parte del anfitrión titular. | En `detalles_propiedades_page.dart`, cuando `authProvider.user?.id == property.userId`, la tarjeta del arrendador muestra de forma idéntica su propia insignia de reputación pública, permitiéndole certificar cómo lo perciben los postulantes y consultar sus reseñas. | RF-30.4 |
| **QA-6** | Riesgo de desborde vertical por comentarios extensos en el listado. | Se extiende `ReviewListItem` con soporte para truncado a 3 líneas (`maxLines: 3`, `TextOverflow.ellipsis`) y un control accesible de alternancia `"Ver más"` / `"Ver menos"`, evitando scroll desmedido en perfiles con comentarios largos. | RF-29.2, CL-28 |
| **QA-7** | Modo fuera de línea o datos parciales en caché del inmueble. | La consulta de reputación en `detalles_propiedades_page.dart` se ejecuta de forma asíncrona mediante `ReviewProvider`. Si falla o no hay conexión, se muestra un estado sutil no invasivo (*"Reputación no disponible temporalmente"*) sin bloquear la información del inmueble ni generar pantallas de error. | RF-33.1, CL-29, RNF-19 |
| **QA-8** | Representación compacta del puntaje provisional en tarjetas de propiedad. | El widget `RatingBadge` incorpora la variante compacta `isProvisional: true` que muestra `3.0 ★ (Inicial)` con ancho controlado y padding adaptativo, garantizando legibilidad en pantallas de 320 px. | RF-31.2, CL-24, RNF-21 |
| **QA-9** | Preservación del principio 2.1 de la Constitución (Cero nombres de archivo en `spec.md`). | Se eliminaron todas las referencias a nombres de archivos y widgets del código en la especificación funcional, sustituyéndolos por términos conceptuales de negocio (*"Pantalla de Perfil de Usuario"* y *"Pantalla de Detalle de Propiedad"*). | Constitución 2.1 |

---

## 2. Estructura de Módulos (Clean Architecture)

El desarrollo aprovecha los contratos y modelos de datos creados en la especificación 005, enfocando los cambios en la capa de presentación y componentes de interfaz:

```
lib/
├── core/
│   └── utils/
│       └── rating_calculator.dart                 # [Reutilizado] Lógica matemática de promedio y redondeo
├── domain/
│   ├── entities/
│   │   ├── review.dart                            # [Reutilizado] Entidad de opinión/reseña
│   │   └── user_reputation.dart                   # [Reutilizado] Entidad de reputación de usuario
│   └── repositories/
│       └── review_repository.dart                 # [Reutilizado] Contrato de persistencia y consultas
├── data/
│   ├── models/
│   │   ├── review_model.dart                      # [Reutilizado] Serialización JSON de opiniones
│   │   └── user_reputation_model.dart             # [Reutilizado] Serialización JSON de reputación
│   └── repositories/
│       └── review_repository_impl.dart            # [Reutilizado] Repositorio Supabase
└── presentation/
    ├── providers/
    │   └── review_provider.dart                   # [Extendido] Métodos getLandlordReputation(userId) con caché
    ├── widgets/
    │   ├── rating_stars_bar.dart                  # [Reutilizado] Barra de estrellas accesibles
    │   ├── rating_badge.dart                      # [Extendido] Soporte para variante compacta provisional
    │   ├── review_list_item.dart                  # [Extendido] Soporte de truncado a 3 líneas con "Ver más"
    │   ├── user_reputation_header.dart            # [Reutilizado] Encabezado para perfil y modal
    │   └── landlord_reputation_bottom_sheet.dart  # [NUEVO] Hoja modal deslizable para ver reseñas del anfitrión
    └── pages/
        ├── navegation/
        │   ├── perfil_page.dart                   # [Integrado] Sección de reputación y reseñas del usuario
        │   └── panel_page.dart                    # [Integrado] Tarjeta de ranking y reputación del arrendador en su panel
        └── propiedades/
            └── detalles_propiedades_page.dart     # [Integrado] Insignia de reputación y modal en tarjeta del arrendador
```

---

## 3. Modelo de Datos JSON y Ejemplos

### 3.1. Modelo JSON: Reputación de Usuario (`UserReputation`)

```json
{
  "user_id": "7b8c9d0e-1f2a-3b4c-5d6e-7f8a9b0c1d2e",
  "average_rating": 4.8,
  "total_reviews": 12,
  "is_verified": true,
  "initial_trust_rating": 3.0
}
```

*Ejemplo de usuario verificado sin reseñas previas (Estado de Confianza Inicial):*
```json
{
  "user_id": "9a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d",
  "average_rating": 0.0,
  "total_reviews": 0,
  "is_verified": true,
  "initial_trust_rating": 3.0
}
```

*Ejemplo de usuario no verificado sin reseñas (Estado Neutral):*
```json
{
  "user_id": "1c2d3e4f-5a6b-7c8d-9e0f-1a2b3c4d5e6f",
  "average_rating": 0.0,
  "total_reviews": 0,
  "is_verified": false,
  "initial_trust_rating": 0.0
}
```

### 3.2. Modelo JSON: Colección de Opiniones (`List<Review>`)

```json
[
  {
    "id": "e1f2a3b4-c5d6-7e8f-9a0b-1c2d3e4f5a6b",
    "solicitud_id": "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
    "author_id": "3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d",
    "author_name": "Carlos Mendoza",
    "target_user_id": "7b8c9d0e-1f2a-3b4c-5d6e-7f8a9b0c1d2e",
    "rating": 5,
    "comment": "Excelente arrendador, muy atento en la entrega y formal con el contrato de arriendo.",
    "created_at": "2026-09-25T14:30:00.000Z"
  },
  {
    "id": "f2a3b4c5-d6e7-8f9a-0b1c-2d3e4f5a6b7c",
    "solicitud_id": "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
    "author_id": "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
    "author_name": "Valentina Gómez",
    "target_user_id": "7b8c9d0e-1f2a-3b4c-5d6e-7f8a9b0c1d2e",
    "rating": 4,
    "comment": "Todo el trámite fue rápido y transparente. Muy recomendado.",
    "created_at": "2026-09-18T10:15:00.000Z"
  }
]
```

---

## 4. Decisiones Técnicas Justificadas y Alternativas Descartadas

### **DT-1: Modal Deslizable (`BottomSheet`) vs. Nueva Ruta de Pantalla para Reseñas del Arrendador**
* **Decisión:** Implementar `LandlordReputationBottomSheet` como hoja modal inferior modal cuando el usuario presiona la calificación del propietario en el detalle de la propiedad.
* **Justificación:** Preserva el contexto visual y la intención de arriendo del usuario. Al cerrar el modal, el potencial inquilino continúa inmediatamente en la pantalla del inmueble listo para postular o contactar.
* **Alternativa Descartada:** Crear una nueva ruta de pantalla completa (`/landlord/:id/reviews`). Rompe la inmersión del usuario y añade sobrecarga de navegación en la pila de `GoRouter`.

### **DT-2: Carga Asíncrona No Bloqueante en `detalles_propiedades_page.dart`**
* **Decisión:** La información de reputación del arrendador se consulta de forma desacoplada mediante `ReviewProvider.loadUserReputation(landlordId)` en un micro-estado no bloqueante.
* **Justificación:** Si la red presenta latencia o timeout en el microservicio de reseñas, la propiedad se renderiza de inmediato con sus fotos, precio, amenidades y datos básicos sin degradar la experiencia principal.
* **Alternativa Descartada:** Forzar `await` coordinado dentro de `_loadLandlord()` bloqueando todo el renderizado de la pantalla. Crearía lentitud perceptiva innecesaria.

### **DT-3: Truncamiento Expansible ("Ver más / Ver menos") en `ReviewListItem`**
* **Decisión:** Comentarios superiores a 3 líneas se truncan con elipsis visual y presentan un botón interactivo que alterna la expansión en memoria del widget.
* **Justificación:** Un comentario de 500 caracteres puede ocupar hasta 150 píxeles verticales en móviles pequeños. El truncado mantiene compacta la lista y da control al usuario.
* **Alternativa Descartada:** Mostrar todo el texto sin límite o recortar permanentemente sin opción de ver el contenido completo.

### **DT-4: Reutilización de `UserReputationHeader` en Perfil de Usuario**
* **Decisión:** Emplear el widget ya probado y certificado `UserReputationHeader` en la sección superior del perfil propio en `perfil_page.dart`.
* **Justificación:** Garantiza coherencia de diseño absoluta (colores, fuentes, accesibilidad) y elimina duplicación de código, cumpliendo con el principio DRY.
* **Alternativa Descartada:** Escribir widgets ad-hoc separados para perfil y para el modal del arrendador.

### **DT-5: Integración del Ranking del Arrendador en `panel_page.dart`**
* **Decisión:** Integrar el componente de reputación (`UserReputationHeader` o tarjeta de ranking interactiva) en `panel_page.dart` para usuarios con rol de Arrendador, cargando la reputación asíncronamente mediante `ReviewProvider.fetchUserReputation` y `fetchUserReviews`.
* **Justificación:** El Panel de Control es la pantalla operativa principal del Arrendador; exponer aquí su calificación promedio y nivel de confianza le permite monitorear de forma inmediata su prestigio comunitario sin obligarlo a alternar a la pestaña de perfil.
* **Alternativa Descartada:** Relegar la consulta de reputación exclusivamente a `PerfilPage`, lo cual aísla el prestigio del arrendador de su centro de control operativo.

### **DT-6: Actualización Reactiva de Ranking y Escucha de Cambios en la Navegación (RF-35)**
* **Decisión:** Implementar la recarga y escucha dinámica del ranking en las transiciones de pantalla:
  1. En `home_page.dart`: al seleccionar la pestaña correspondiente (`index == 3`, que aloja `PanelPage` para arrendador o `PerfilPage` para arrendatario), invocar la sincronización en segundo plano de `fetchUserReputation` y `fetchUserReviews`.
  2. En `panel_page.dart` y `perfil_page.dart`: escuchar reactivamente a `ReviewProvider` y re-sincronizar el estado al retornar a la vista mediante listeners de ciclo de vida o navegación.
  3. En `detalles_propiedades_page.dart`: consultar la reputación más reciente del propietario al ingresar a la pantalla del inmueble, invalidando lecturas obsoletas.
  4. En `ReviewProvider`: notificar globalmente a todos los escuchas (`notifyListeners()`) e invalidar cachés tras el envío exitoso de cualquier calificación, actualizando en tiempo real las pantallas en memoria.
* **Justificación:** Debido al uso de `IndexedStack` en la navegación principal por pestañas, las pantallas permanecen montadas en memoria y `initState` no se re-ejecuta al alternar entre tabs. La sincronización basada en eventos de navegación garantiza datos 100% actualizados sin requerir gestos manuales del usuario ni recargas invasivas.
* **Alternativa Descartada:** Forzar la destrucción y reconstrucción de las páginas en cada cambio de tab (`IndexedStack` -> reemplazo destructivo). Provocaría pérdida del estado de scroll, recreación de controladores de mapas y parpadeos visuales indeseados.

### **DT-7: Persistencia e Idempotencia de Calificación de Usuario Verificado en Supabase (RF-36)**
* **Decisión:** Al completar satisfactoriamente el perfil de usuario (tanto arrendador en `CompleteLandlordProfilePage` como arrendatario en `CompleteTenantProfilePage`):
  1. **Adaptación de Base de Datos Supabase:** La columna `solicitud_id` de la tabla `public.reviews` se declara opcional (`NULL`) para evaluaciones generadas por el sistema al certificar datos. Se ajusta la restricción `check_no_self_review` para permitir `solicitud_id IS NULL`, y se agrega un índice único parcial `CREATE UNIQUE INDEX idx_unique_verified_review ON public.reviews (target_user_id) WHERE solicitud_id IS NULL;` para garantizar idempotencia y evitar duplicidad.
  2. **Contratos de Capas Domain y Data:** En `ReviewRemoteDataSource` y `ReviewRepository` se incorpora `registerVerifiedUserReview({required String userId, String? userName})`, el cual verifica previamente si ya existe una calificación con comentario `'Usuario verificado'` antes de insertar la evaluación de 3 estrellas.
  3. **Invocación no bloqueante en Presentation:** Al presionar "Completar Perfil" y confirmar el guardado exitoso en `LandlordProvider.saveLandlordProfile` o `TenantProvider.saveTenantProfile`, se invoca de forma asíncrona `ReviewProvider.registerVerifiedUserReview`. Si el servicio experimenta fallos de conectividad, se captura de forma defensiva para no bloquear la salida de la pantalla ni la retroalimentación positiva al usuario.
  4. **Reactividad inmediata:** Tras la inserción, `ReviewProvider` re-consulta la reputación (`fetchUserReputation`) y la lista de opiniones (`fetchUserReviews`), actualizando instantáneamente las vistas en memoria (`PerfilPage`, `PanelPage`, `RatingBadge`).
* **Justificación:** Resuelve de raíz la inquietud del usuario sobre la persistencia real del ranking en Supabase. En vez de depender exclusivamente de un fallback en memoria, la calificación inicial queda registrada como una fila formal en la tabla `reviews` con el texto explícito `"Usuario verificado"`.
* **Alternativa Descartada:** Requerir una solicitud ficticia (`solicitud_id` artificial). Violaría la integridad referencial y ensuciaría la tabla de solicitudes de arriendo.

---

## 5. Estrategia de Pruebas Automatizadas (TDD)

Se diseñará una suite exhaustiva de pruebas unitarias y de widgets que garantice 0 regresión sobre los 271 tests existentes:

1. **Pruebas de Componentes Actualizados:**
   - `test/presentation/widgets/review_list_item_expansion_test.dart`: Verificar renderizado compacto, activación de "Ver más", expansión completa y cambio a "Ver menos".
   - `test/presentation/widgets/rating_badge_compact_test.dart`: Verificar renderizado de badge provisional `3.0 ★` y adaptación visual en anchos estrechos.
2. **Pruebas de Nuevos Componentes:**
   - `test/presentation/widgets/landlord_reputation_bottom_sheet_test.dart`: Verificar apertura del modal, renderizado de encabezado, lista de reseñas históricas y cierre amigable.
3. **Pruebas de Integración en Pantallas:**
   - `test/presentation/pages/propiedades/detalles_propiedades_rating_integration_test.dart`:
     - Renderizado de la insignia de calificación del arrendador junto al nombre.
     - Manejo de arrendador verificado con 0 reseñas (`3.0 ★ Inicial`).
     - Manejo de arrendador no verificado sin reseñas (`Sin calificaciones aún`).
     - Apertura del bottom sheet al pulsar la insignia.
     - Resiliencia ante error de carga de reputación (no rompe la pantalla).
   - `test/presentation/pages/navegation/perfil_page_rating_integration_test.dart`:
     - Renderizado de `UserReputationHeader` con el promedio y contador del usuario autenticado.
     - Visualización del listado de opiniones recibidas.
     - Refresco mediante `RefreshIndicator`.
   - `test/presentation/pages/navegation/panel_page_rating_integration_test.dart`:
     - Renderizado del ranking de estrellas y promedio del arrendador en la cabecera de su panel.
     - Manejo de estados: arrendador verificado con calificación inicial `3.0 ★`, estado neutral y con reseñas reales.
     - Interacción para consultar opiniones y refresco de datos con `RefreshIndicator`.
   - `test/presentation/pages/navegation/ranking_navigation_listener_integration_test.dart`:
     - Sincronización automática de reputación y opiniones al conmutar pestañas hacia el Perfil o Panel en `HomePage`.
     - Actualización reactiva de las pantallas ante la emisión de una nueva calificación registrada en `ReviewProvider`.
     - Consulta y frescura de la reputación del propietario al navegar hacia `DetallesPropiedadesPage`.
   - `test/presentation/pages/profile/verified_user_review_integration_test.dart`:
     - Registro automático de calificación de 3 estrellas con comentario "Usuario verificado" al completar perfil de arrendador.
     - Registro automático de calificación de 3 estrellas con comentario "Usuario verificado" al completar perfil de arrendatario.
     - Verificación de idempotencia (no duplicidad en actualizaciones subsiguientes).
     - Resiliencia ante fallos de red al registrar la calificación inicial.
4. **Verificación de Regresión y Calidad:**
   - `flutter analyze`: Cero advertencias y cero errores (código de salida 0).
   - `flutter test`: 100% de la suite completa aprobada (298 + nuevos tests, código de salida 0).

---

## 6. Comandos de Verificación y Códigos de Salida

* **Análisis estático:**
  ```bash
  flutter analyze
  # Salida esperada: No issues found!
  # Código de salida: 0
  ```
* **Ejecución de pruebas automatizadas:**
  ```bash
  flutter test
  # Salida esperada: All tests passed!
  # Código de salida: 0
  ```

---

## 7. Mapeo de Requisitos Funcionales vs. Componentes del Plan

| Requisito Funcional | Componente / Archivo en el Plan | Prueba Automatizada |
| :--- | :--- | :--- |
| **RF-29.1, RF-29.3** | `perfil_page.dart` con `UserReputationHeader` | `perfil_page_rating_integration_test.dart` |
| **RF-29.2, CL-28** | `ReviewListItem` con toggle de expansión | `review_list_item_expansion_test.dart` |
| **RF-30.1, RF-30.2** | `detalles_propiedades_page.dart` con `RatingBadge` | `detalles_propiedades_rating_integration_test.dart` |
| **RF-30.3** | `landlord_reputation_bottom_sheet.dart` | `landlord_reputation_bottom_sheet_test.dart` |
| **RF-30.4** | `detalles_propiedades_page.dart` (propietario como espectador) | `detalles_propiedades_rating_integration_test.dart` |
| **RF-31.1, RF-31.2, RF-31.3** | `UserReputationHeader` & `RatingBadge` | `rating_badge_compact_test.dart` |
| **RF-32.1, RF-32.2** | Paleta unificada y esqueleto de carga | `detalles_propiedades_rating_integration_test.dart` |
| **RF-33.1, RF-33.2, CL-29** | Micro-estado asíncrono y resiliencia en `ReviewProvider` | `detalles_propiedades_rating_integration_test.dart` |
| **RF-34.1, RF-34.2, RF-34.3** | `panel_page.dart` con ranking del arrendador | `panel_page_rating_integration_test.dart` |
| **RF-35.1, RF-35.2, RF-35.3, RF-35.4** | `home_page.dart`, `perfil_page.dart`, `panel_page.dart`, `detalles_propiedades_page.dart` & `ReviewProvider` | `ranking_navigation_listener_integration_test.dart` |
| **RF-36.1, RF-36.2, RF-36.3, RF-36.4, RF-36.5** | `complete_landlord_profile_page.dart`, `complete_tenant_profile_page.dart`, `ReviewRemoteDataSource`, `ReviewRepository` & `ReviewProvider` | `verified_user_review_integration_test.dart` |
| **RNF-19, RNF-20, RNF-21, RNF-22** | Etiquetas de accesibilidad, sincronización fluida y diseño adaptativo a 320 px | `rating_badge_compact_test.dart`, `ranking_navigation_listener_integration_test.dart` |


