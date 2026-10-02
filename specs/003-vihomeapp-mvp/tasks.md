# Tareas de Implementación: Formularios Independientes de Solicitud de Arrendamiento (003-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), ordenadas estrictamente por dependencias arquitectónicas. Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF) y Casos Límite (CL) que cubre, junto con un criterio de aceptación verificable ("Hecho cuando:").

---

## Fase 1: Dominio y Utilidades de Validación Puras

- [x] **Tarea 1.1: Clasificador Canónico de Tipos de Inmueble (`PropertyCategoryResolver`)**
  - **RF Cubiertos:** RF-13.1, RF-13.2, CL-14
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `PropertyCategoryResolver` en `lib/core/utils/` para sanitizar cadenas (minúsculas, trim, remoción de acentos) y clasificar tipos de inmueble en categorías canónicas (`residential`, `individual`, `commercial`), con fallback seguro a categoría residencial ante tipos desconocidos o cadenas vacías.
  - **Hecho cuando:** `flutter test test/core/utils/property_category_resolver_test.dart` retorne exit code 0 con todos los casos de normalización y clasificación validados.

- [x] **Tarea 1.2: Validador de Reglas de Negocio de Formularios Contextuales (`ContextualFormValidator`)**
  - **RF Cubiertos:** RF-14.1, RF-14.2, RF-14.3, RF-15.1, RF-15.3, RF-16.1, RF-16.2, RF-16.3, CL-10, CL-11, CL-12
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `ContextualFormValidator` en `lib/core/utils/` con validaciones puras para: aforo de ocupantes (entero de 1 a 20), longitud de descripción familiar (10-500 chars), detalle condicional de mascotas (3-150 chars), nombre alfabético de acudiente en español (5-80 chars), teléfono (10 dígitos o formato internacional) y formato de NIT/actividad comercial.
  - **Hecho cuando:** `flutter test test/core/utils/context_form_validator_test.dart` retorne exit code 0 cubriendo todos los escenarios válidos, extremos y de rechazo.

- [x] **Tarea 1.3: Jerarquía Sellada de Entidades de Dominio (`ApplicationContextData`)**
  - **RF Cubiertos:** RF-13.2, RF-14, RF-15, RF-16
  - **Descripción:** Definir la clase sellada `ApplicationContextData` y sus subtipos inmutables (`ResidentialContextData`, `IndividualContextData`, `CommercialContextData`) en `lib/domain/entities/application_context_data.dart`, junto con sus pruebas de inmutabilidad y pattern matching exhaustivo.
  - **Hecho cuando:** `flutter test test/domain/entities/application_context_data_test.dart` retorne exit code 0 verificando tipos, inmutabilidad y comparación de valores.

---

## Fase 2: Capa de Datos, Modelos y Serialización JSON

- [x] **Tarea 2.1: Modelos de Datos y Serialización Bidireccional (`ApplicationContextDataModel`)**
  - **RF Cubiertos:** RF-14, RF-15, RF-16, RF-17.1, RF-17.2
  - **Descripción:** Implementar pruebas unitarias y la clase `ApplicationContextDataModel` en `lib/data/models/` para serializar y deserializar el campo `datos_contextuales` en formato JSON (`fromJson` / `toJson`), garantizando manejo seguro ante campos nulos, registros legacy y estructuras incompletas.
  - **Hecho cuando:** `flutter test test/data/models/application_context_data_model_test.dart` retorne exit code 0 validando la serialización de todas las categorías y compatibilidad legacy.

- [x] **Tarea 2.2: Extensión de `Application` y `ApplicationModel` con Datos Contextuales**
  - **RF Cubiertos:** RF-13.3, RF-17.1, Constitución 2.3
  - **Descripción:** Extender la entidad `Application` y su modelo `ApplicationModel` para incorporar el atributo opcional `datosContextuales` sin alterar los campos preexistentes ni romper la compatibilidad con las fuentes de datos actuales.
  - **Hecho cuando:** `flutter test test/data/models/application_model_test.dart` retorne exit code 0 garantizando no regresión en la suite de pruebas existente.

---

## Fase 3: Gestión de Estado y Lógica de Negocio (`ApplicationProvider`)

- [x] **Tarea 3.1: Extensión de `ApplicationProvider` para Soporte Contextual y Validación en Vivo**
  - **RF Cubiertos:** RF-13.1, RF-13.3, RNF-08, RNF-09, CL-10, CL-11, CL-12
  - **Descripción:** Implementar pruebas unitarias para `ApplicationProvider` agregando la inicialización según categoría de inmueble, controladores para campos contextuales, validaciones reactivas en tiempo real, preservación de datos en memoria ante alternancia de switches condicionales (mascotas y acudiente) y prevención de postulaciones duplicadas.
  - **Hecho cuando:** `flutter test test/presentation/providers/application_provider_contextual_test.dart` retorne exit code 0 cubriendo todos los flujos de validación, reactividad y preservación de estado.

---

## Fase 4: Componentes de Interfaz de Usuario y Formularios Modulares

- [x] **Tarea 4.1: Widgets Modulares de Entrada para Arrendatario**
  - **RF Cubiertos:** RF-13.1, RF-14.1, RF-14.2, RF-14.3, RF-14.4, RF-15.1, RF-15.2, RF-15.3, RF-15.4, RF-16.1, RF-16.2, RF-16.3, RNF-08, RNF-10
  - **Descripción:** Implementar y probar con `WidgetTester` los subformularios modulares: `FormResidencialWidget`, `FormIndividualWidget` y `FormComercialWidget` en `lib/presentation/pages/tenant/widgets/`, verificando la visualización condicional reactiva (< 100 ms) y mensajes de error inline claros en español.
  - **Hecho cuando:** `flutter test test/presentation/pages/tenant/widgets/contextual_form_widgets_test.dart` retorne exit code 0 validando la renderización y comportamiento interactivo de cada subformulario.

- [x] **Tarea 4.2: Integración en la Pantalla Orquestadora `SolicitudDeArriendoPage`**
  - **RF Cubiertos:** RF-13.1, RF-13.3, RNF-09, CL-13
  - **Descripción:** Integrar el enrutamiento dinámico en `SolicitudDeArriendoPage` según la categoría del inmueble detectada por `PropertyCategoryResolver`, manteniendo los campos base de ingresos y comprobante, y validando la retención de datos seleccionados ante fallos simulados de red.
  - **Hecho cuando:** `flutter test test/presentation/pages/tenant/solicitud_contextual_widget_test.dart` retorne exit code 0 confirmando la integración orquestada y el reintento ante errores.

- [x] **Tarea 4.3: Tarjeta de Visualización Contextual para Arrendador en `DetalleSolicitudArrendadorPage`**
  - **RF Cubiertos:** RF-17.1, RF-17.2
  - **Descripción:** Implementar pruebas de widgets y el componente `DetalleSolicitudContextualCard` en `lib/presentation/pages/landlord/widgets/` para presentar al propietario la información adaptada al tipo de inmueble (Composición Familiar, Ocupación y Acudiente, o Datos Comerciales), así como el cartel neutral para solicitudes legacy sin datos adicionales.
  - **Hecho cuando:** `flutter test test/presentation/pages/landlord/detalle_solicitud_contextual_widget_test.dart` retorne exit code 0 validando la presentación para todas las categorías de inmueble y casos legacy.

---

## Fase 5: Verificación Integral de Suite de Pruebas y Calidad

- [x] **Tarea 5.1: Ejecución de la Suite Completa de Tests Automatizados de la Aplicación**
  - **RF Cubiertos:** RF-01 a RF-17, CL-01 a CL-14
  - **Descripción:** Ejecutar todas las pruebas unitarias y de widgets del proyecto asegurando cero fallos y no regresión sobre funcionalidades previas.
  - **Hecho cuando:** El comando `flutter test` retorne exit code 0 con el 100% de suites pasando.

- [x] **Tarea 5.2: Verificación de Análisis Estático y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal (docs/constitution.md)
  - **Descripción:** Ejecutar el análisis estático en todo el proyecto asegurando cero advertencias y cero errores de linter.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).
