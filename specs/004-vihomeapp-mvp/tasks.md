# Tareas de Implementación: Mejora de Interfaz (UI) en la Tabla de Solicitudes (004-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), ordenadas estrictamente por dependencias arquitectónicas. Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF), Casos Límite (CL) y Hallazgos de QA que cubre, junto con un criterio de aceptación verificable ("Hecho cuando:").

---

## Fase 1: Utilidades Centrales y Lógica Pura (Core / Utils)

- [x] **Tarea 1.1: Formateador Cronológico Inteligente y Localizado (`ApplicationDateFormatter`)**
  - **RF Cubiertos:** RF-18.2, RF-18.3, QA 1.2
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `ApplicationDateFormatter` en `lib/core/utils/` utilizando `intl` configurado en español. Debe transformar timestamps en representaciones cronológicas naturales según su frescura: *"Hoy, HH:mm"*, *"Ayer, HH:mm"*, *"Hace X días"* (última semana) o formato localizado *"d MMM yyyy"* (ej. *"14 sep 2026"*).
  - **Hecho cuando:** `flutter test test/core/utils/application_date_formatter_test.dart` retorne exit code 0 validando todos los rangos temporales y la localización idiomática.

- [x] **Tarea 1.2: Sanitizador de Texto a Una Sola Línea Anti-Desbordamiento (`TextSanitizer`)**
  - **RF Cubiertos:** RF-18.4, CL-15, QA 1.8, QA 1.15
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `TextSanitizer` en `lib/core/utils/` con métodos para limpiar títulos y nombres: colapsar saltos de línea explícitos (`\n`), normalizar secuencias de espacios en blanco múltiples y proveer truncamiento seguro con puntos suspensivos para prevenir distorsiones en las tarjetas compactas.
  - **Hecho cuando:** `flutter test test/core/utils/text_sanitizer_test.dart` retorne exit code 0 validando la sanitización de saltos de línea, espacios redundantes y truncamiento elíptico.

- [x] **Tarea 1.3: Servicio Seguro de Lanzamiento de Contactos Externos (`ExternalContactLauncher`)**
  - **RF Cubiertos:** RF-20.2, CL-16, QA 1.1, QA 1.4, QA 1.13, QA 1.17
  - **Descripción:** Implementar pruebas unitarias y la clase `ExternalContactLauncher` en `lib/core/utils/` para gestionar la apertura de llamadas telefónicas (`tel:`) y enlaces de WhatsApp (`https://wa.me/` con mensaje codificado predeterminado en URL). Debe incluir manejo de excepciones de plataforma y emitir una respuesta controlada con facilitación de copiado al portapapeles si la aplicación de destino no está instalada.
  - **Hecho cuando:** `flutter test test/core/utils/external_contact_launcher_test.dart` retorne exit code 0 validando URIs generadas, codificación de plantillas y captura segura de fallos de invocación.

---

## Fase 2: Capa de Dominio y Modelos de Datos (Domain & Data)

- [x] **Tarea 2.1: Extensión de la Entidad `Application` con Soporte de Contacto Contraparte**
  - **RF Cubiertos:** RF-18.2, RF-18.3, RF-20.2, Constitución 2.3
  - **Descripción:** Extender la entidad inmutable `Application` en `lib/domain/entities/application.dart` incorporando los campos opcionales `telefonoArrendatario`, `nombreArrendador` y `telefonoArrendador`, actualizando el constructor, el método `copyWith` y las pruebas de entidad sin alterar los atributos preexistentes.
  - **Hecho cuando:** `flutter test test/domain/entities/application_test.dart` retorne exit code 0 validando la asignación inmutable de los nuevos campos y la preservación de compatibilidad.

- [x] **Tarea 2.2: Deserialización Robusta y Manejo Resiliente en `ApplicationModel`**
  - **RF Cubiertos:** RF-18.2, RF-18.3, CL-15, CL-16, QA 1.10, QA 1.11, QA 1.12
  - **Descripción:** Actualizar `ApplicationModel` en `lib/data/models/application_model.dart` para parsear los datos de contacto provenientes de joins o payloads directos. Incorporar fallbacks defensivos: si el inmueble fue eliminado, asignar `tituloPropiedad = "Inmueble no disponible"`; si el usuario fue dado de baja, asignar `"Usuario no disponible"`; y tolerar estados no mapeados sin arrojar excepciones.
  - **Hecho cuando:** `flutter test test/data/models/application_model_extended_test.dart` retorne exit code 0 validando la deserialización completa, serialización simétrica y todos los casos de fallback defensivo.

---

## Fase 3: Gestión de Estado, Filtros Reactivos y Resiliencia (`ApplicationProvider`)

- [x] **Tarea 3.1: Filtros de Segmentación Rápida con Contadores Dinámicos en `ApplicationProvider`**
  - **RF Cubiertos:** RF-21.1, RF-21.2, RF-21.3, QA 1.3, QA 1.17
  - **Descripción:** Implementar pruebas unitarias y extender `ApplicationProvider` en `lib/presentation/providers/application_provider.dart` para soportar las categorías canónicas de filtro (`Todas`, `Pendientes`, `Aceptadas`, `Rechazadas`), calcular los conteos reactivos exactos (`totalCount`, `pendingCount`, `acceptedCount`, `rejectedCount`) y garantizar orden cronológico descendente por fecha de solicitud.
  - **Hecho cuando:** `flutter test test/presentation/providers/application_provider_filter_test.dart` retorne exit code 0 validando la alternancia instantánea de filtros, el cálculo de contadores y el orden cronológico.

- [x] **Tarea 3.2: Resiliencia de Red en Dos Fases y Preservación de Estado de Filtro**
  - **RF Cubiertos:** RF-22.3, RNF-09, QA 1.3, QA 1.14
  - **Descripción:** Extender los métodos `fetchLandlordApplications` y `fetchTenantApplications` en `ApplicationProvider` para preservar el filtro seleccionado tras recargar datos. Si el refresco (*pull-to-refresh*) falla y la lista ya contenía datos en memoria, mantener los datos visibles y notificar el incidente mediante un mensaje de error no destructivo, reservando el error bloqueante solo para listas vacías.
  - **Hecho cuando:** `flutter test test/presentation/providers/application_provider_resilience_test.dart` retorne exit code 0 validando la persistencia de datos previos ante fallos de refresco y la conservación del filtro activo.

---

## Fase 4: Componentes Reutilizables de Interfaz de Usuario (Widgets)

- [x] **Tarea 4.1: Barra de Filtros Segmentada con Contadores (`SolicitudesFilterBar`)**
  - **RF Cubiertos:** RF-21.1, RF-21.2, QA 1.17, RNF-14
  - **Descripción:** Implementar pruebas de widgets y el componente `SolicitudesFilterBar` en `lib/presentation/widgets/solicitudes_filter_bar.dart` con chips horizontales (`Todas`, `Pendientes`, `Aceptadas`, `Rechazadas`) que muestran badges numéricos con la cantidad de solicitudes coincidentes, animaciones sutiles de selección y tiempo de respuesta inmediato.
  - **Hecho cuando:** `flutter test test/presentation/widgets/solicitudes_filter_bar_test.dart` retorne exit code 0 validando la renderización de chips, la presencia de contadores numéricos y la respuesta al toque.

- [x] **Tarea 4.2: Fila de Acciones Duales de Contacto (`ContactActionsRow`) y Estados Vacíos (`SolicitudesEmptyState`)**
  - **RF Cubiertos:** RF-20.2, RF-20.3, RF-22.1, RF-22.2, QA 1.1, QA 1.7
  - **Descripción:** Implementar pruebas de widgets y los componentes compartidos:
    1. `ContactActionsRow` en `lib/presentation/widgets/contact_actions_row.dart`: botones compactos para llamada telefónica y WhatsApp, con validación de teléfono y ocultamiento automático si la solicitud está rechazada o carece de número.
    2. `SolicitudesEmptyState` en `lib/presentation/widgets/solicitudes_empty_state.dart`: vista ilustrada para listas sin elementos, con mensaje descriptivo y botón de acción contextual ("Explorar inmuebles" o "Ver mis propiedades").
  - **Hecho cuando:** `flutter test test/presentation/widgets/solicitudes_shared_widgets_test.dart` retorne exit code 0 verificando el comportamiento de los botones de contacto y la renderización de estados vacíos.

---

## Fase 5: Modernización de Pantallas Principales (Arrendador y Arrendatario)

- [x] **Tarea 5.1: Tarjeta de Alta Densidad y Pantalla de Solicitudes del Arrendador (`SolicitudesArrendadorPage`)**
  - **RF Cubiertos:** RF-18.1, RF-18.2, RF-18.4, RF-20.1, RF-20.2, RF-21.1, RF-21.3, RF-22.2, RF-22.3, CL-15, CL-16, QA 1.5, QA 1.7
  - **Descripción:** Implementar `ApplicationCardLandlord` e integrarlo en `SolicitudesArrendadorPage` (`lib/presentation/pages/landlord/`):
    - Presentación en tarjetas compactas con nombre de solicitante, título de la propiedad, fecha formateada e insignia de estado.
    - Acciones rápidas de contacto (llamada y WhatsApp) activas para solicitudes pendientes y aceptadas, y omitidas para rechazadas.
    - Integración de `SolicitudesFilterBar`, soporte para *pull-to-refresh* resiliente y navegación al detalle al presionar el cuerpo de la tarjeta.
  - **Hecho cuando:** `flutter test test/presentation/pages/landlord/solicitudes_arrendador_page_test.dart` retorne exit code 0 validando la presentación de tarjetas, filtrado en vivo, acciones de contacto y navegación.

- [x] **Tarea 5.2: Tarjeta con "Paso Siguiente" y Pantalla de Solicitudes del Arrendatario (`SolicitudesArrendatarioPage`)**
  - **RF Cubiertos:** RF-18.1, RF-18.3, RF-18.4, RF-19.1, RF-19.2, RF-19.3, RF-20.1, RF-20.2, RF-21.1, RF-22.1, RF-22.3, CL-15, CL-16, QA 1.6
  - **Descripción:** Implementar `ApplicationCardTenant` e integrarlo en `SolicitudesArrendatarioPage` (`lib/presentation/pages/tenant/`):
    - Tarjeta compacta con título del inmueble, nombre del arrendador, fecha de postulación e insignia de estado.
    - Bloque de "Paso siguiente": *"Esperando respuesta del propietario"* (Pendiente), *"Contacto habilitado"* con botones de llamada y WhatsApp hacia el propietario (Aceptada), o *"Solicitud no aprobada"* sin contacto (Rechazada).
    - Integración de `SolicitudesFilterBar`, soporte para *pull-to-refresh* resiliente y estado vacío ilustrado con acción "Explorar inmuebles".
  - **Hecho cuando:** `flutter test test/presentation/pages/tenant/solicitudes_arrendatario_page_test.dart` retorne exit code 0 validando el ciclo de estados del paso siguiente, la habilitación de contacto en solicitudes aceptadas y los filtros reactivos.

---

## Fase 6: Verificación Integral de Suite de Pruebas y Calidad Transversal

- [x] **Tarea 6.1: Ejecución Completa de la Suite de Pruebas Automatizadas de la Aplicación**
  - **RF Cubiertos:** Cobertura transversal de la entrega (RF-01 a RF-22, CL-01 a CL-18)
  - **Descripción:** Ejecutar la totalidad de suites de pruebas unitarias, de integración de estado y de widgets en el proyecto, asegurando que todos los tests pasen exitosamente y que no exista regresión sobre funcionalidades previas.
  - **Hecho cuando:** El comando `flutter test` retorne exit code 0 con el 100% de suites pasando.

- [x] **Tarea 6.2: Verificación de Análisis Estático y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal del código (Constitución 2.1, 2.3)
  - **Descripción:** Ejecutar el análisis estático en todo el árbol de código fuente del proyecto garantizando cero advertencias y cero errores de linter.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).
