# Tareas de Implementación y Verificación: ViHome MVP (001-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (duración estimada de 20 a 30 minutos cada una), ordenadas estrictamente por dependencias. Cada tarea especifica los Requisitos Funcionales (RF) que cubre y un criterio de aceptación verificable ("Hecho cuando:").

---

## Fase 1: Infraestructura de Pruebas y Mocks Base

- [x] **Tarea 1.1: Configuración de Helpers y Mocks Base para Pruebas**
  - **RF Cubiertos:** Base para RF-01 a RF-07
  - **Descripción:** Crear utilidades de prueba, objetos simulados (fakes/fixtures) y datos de prueba JSON válidos e inválidos en `test/fixtures/` para usuarios, propiedades, solicitudes y suscripciones.
  - **Hecho cuando:** `flutter test test/fixtures/` o análisis estático valide que los fixtures y mocks compilan y se pueden importar sin errores.

- [x] **Tarea 1.2: Pruebas Unitarias de Fallos y Excepciones de Dominio**
  - **RF Cubiertos:** RNF-01, RF-01.2, RF-04.4
  - **Descripción:** Implementar pruebas unitarias para las clases de error y fallos de dominio (`Failure`, `ServerFailure`, `NetworkFailure`, `ValidationFailure`) que mapean mensajes limpios de error.
  - **Hecho cuando:** `flutter test test/core/errors/failure_test.dart` retorne exit code 0 con todos los casos pasando.

---

## Fase 2: Pruebas Unitarias de Entidades y Modelos de Datos

- [x] **Tarea 2.1: Pruebas Unitarias de Modelos de Usuario (`UserModel`)**
  - **RF Cubiertos:** RF-01.1, RF-01.2
  - **Descripción:** Implementar pruebas unitarias de serialización (`fromJson`, `toJson`) e inmutabilidad para `UserModel` y `UserEntity`.
  - **Hecho cuando:** `flutter test test/data/models/user_model_test.dart` retorne exit code 0 validando campos válidos, nulos y tipos incorrectos.

- [x] **Tarea 2.2: Pruebas Unitarias de Modelos de Propiedad (`PropertyModel`)**
  - **RF Cubiertos:** RF-02.1, RF-03.1, RF-05.1
  - **Descripción:** Implementar pruebas unitarias de serialización y validación de campos obligatorios (título, precio, ciudad, fotos) para `PropertyModel`.
  - **Hecho cuando:** `flutter test test/data/models/property_model_test.dart` retorne exit code 0 verificando la correcta conversión de datos y validaciones de foto mínima.

- [x] **Tarea 2.3: Pruebas Unitarias de Modelos de Solicitud Financiera (`ApplicationModel`)**
  - **RF Cubiertos:** RF-04.1, RF-04.2, RF-06.1
  - **Descripción:** Implementar pruebas unitarias para `ApplicationModel` y documentos adjuntos, asegurando soporte para ingresos mensuales y lista de comprobantes.
  - **Hecho cuando:** `flutter test test/data/models/application_model_test.dart` retorne exit code 0 validando la serialización de ingresos y lista de comprobantes.

- [x] **Tarea 2.4: Pruebas Unitarias de Modelos de Suscripción (`SubscriptionModel`)**
  - **RF Cubiertos:** RF-05.2, RF-07.1, RF-07.2, RF-07.3
  - **Descripción:** Implementar pruebas unitarias para `SubscriptionModel` validando atributos de estado activo/inactivo, límites de propiedades y supresión de anuncios.
  - **Hecho cuando:** `flutter test test/data/models/subscription_model_test.dart` retorne exit code 0 con verificación de planes y límites.

---

## Fase 3: Pruebas Unitarias de Casos de Uso (Lógica de Negocio)

- [x] **Tarea 3.1: Pruebas Unitarias de Casos de Uso de Autenticación**
  - **RF Cubiertos:** RF-01.1, RF-01.2, RF-01.3
  - **Descripción:** Implementar pruebas unitarias para `LoginUseCase`, `RegisterUseCase` y `GetCurrentUserUseCase` validando escenarios de éxito y credenciales inválidas.
  - **Hecho cuando:** `flutter test test/domain/usecases/auth/` retorne exit code 0 validando respuestas de éxito y manejo de fallos.

- [x] **Tarea 3.2: Pruebas Unitarias de Búsqueda y Filtrado de Propiedades**
  - **RF Cubiertos:** RF-02.1, RF-02.2, RF-02.3
  - **Descripción:** Implementar pruebas unitarias para `GetPropertiesUseCase` y `FilterPropertiesUseCase` con filtros combinados por ciudad, tipo de inmueble y rango de precios, incluyendo listas vacías.
  - **Hecho cuando:** `flutter test test/domain/usecases/property/filter_properties_test.dart` retorne exit code 0 verificando el filtrado exacto y respuestas vacías.

- [x] **Tarea 3.3: Pruebas Unitarias de Creación y Reglas de Publicación de Propiedades**
  - **RF Cubiertos:** RF-05.1, RF-05.2, RF-05.3, CL-01
  - **Descripción:** Implementar pruebas unitarias para `CreatePropertyUseCase` validando el bloqueo de publicación cuando un usuario gratuito supera el límite de 1 propiedad activa y el permiso ilimitado con plan activo.
  - **Hecho cuando:** `flutter test test/domain/usecases/property/create_property_test.dart` retorne exit code 0 validando tanto el caso permitido como la excepción por límite de plan.

- [x] **Tarea 3.4: Pruebas Unitarias de Envío de Solicitud Financiera**
  - **RF Cubiertos:** RF-04.1, RF-04.2, RF-04.4, CL-04
  - **Descripción:** Implementar pruebas unitarias para `SubmitApplicationUseCase` validando el bloqueo por campos obligatorios ausentes (ingresos <= 0 o sin comprobantes) y bloqueo de postulaciones duplicadas.
  - **Hecho cuando:** `flutter test test/domain/usecases/tenant/submit_application_test.dart` retorne exit code 0 con validación de ingresos y comprobantes requeridos.

- [x] **Tarea 3.5: Pruebas Unitarias de Gestión de Solicitudes por el Arrendador**
  - **RF Cubiertos:** RF-06.1, RF-06.2, RF-06.3
  - **Descripción:** Implementar pruebas unitarias para `GetPropertyApplicationsUseCase` y `UpdateApplicationStatusUseCase` validando cambios de estado y visualización de comprobantes.
  - **Hecho cuando:** `flutter test test/domain/usecases/landlord/` retorne exit code 0 validando las transiciones de estado de solicitudes.

---

## Fase 4: Pruebas Unitarias de Manejo de Estado (Providers)

- [x] **Tarea 4.1: Pruebas Unitarias para `AuthProvider`**
  - **RF Cubiertos:** RF-01.1, RF-01.2, RF-01.3
  - **Descripción:** Implementar pruebas unitarias para `AuthProvider` validando los estados de `loading`, `authenticated`, `unauthenticated` y propagación de mensajes de error limpios.
  - **Hecho cuando:** `flutter test test/presentation/providers/auth_provider_test.dart` retorne exit code 0 en todos los escenarios de autenticación.

- [x] **Tarea 4.2: Pruebas Unitarias para `PropertyProvider`**
  - **RF Cubiertos:** RF-02.1, RF-02.2, RF-02.3, RF-03.1
  - **Descripción:** Implementar pruebas unitarias para `PropertyProvider` validando la carga del catálogo, aplicación de filtros de búsqueda y manejo de resultados vacíos.
  - **Hecho cuando:** `flutter test test/presentation/providers/property_provider_test.dart` retorne exit code 0 verificando la lista de inmuebles reactiva.

- [x] **Tarea 4.3: Pruebas Unitarias para `LandlordPropertiesProvider`**
  - **RF Cubiertos:** RF-05.1, RF-05.2, RF-05.3
  - **Descripción:** Implementar pruebas unitarias para `LandlordPropertiesProvider` verificando la creación de propiedades, control de límite de 1 inmueble para plan gratuito y actualización inmediata de estado.
  - **Hecho cuando:** `flutter test test/presentation/providers/landlord_properties_provider_test.dart` retorne exit code 0 validando límites de publicación y retroalimentación.

- [x] **Tarea 4.4: Pruebas Unitarias para `ApplicationProvider`**
  - **RF Cubiertos:** RF-04.1, RF-04.2, RF-04.3, RF-04.4, RF-06.1, RF-06.2
  - **Descripción:** Implementar pruebas unitarias para `ApplicationProvider` cubriendo el envío de postulaciones financieras, retención de datos ante fallo de red y actualización de estados por el arrendador.
  - **Hecho cuando:** `flutter test test/presentation/providers/application_provider_test.dart` retorne exit code 0 en escenarios de postulación y evaluación.

- [x] **Tarea 4.5: Pruebas Unitarias para `SubscriptionProvider`**
  - **RF Cubiertos:** RF-07.1, RF-07.2, RF-07.3
  - **Descripción:** Implementar pruebas unitarias para `SubscriptionProvider` validando la alternancia de visibilidad de publicidad comercial, expiración de suscripción y permisos de publicación.
  - **Hecho cuando:** `flutter test test/presentation/providers/subscription_provider_test.dart` retorne exit code 0 verificando el estado de anuncios y límites.

---

## Fase 5: Verificación Integral de Suite de Pruebas y Calidad

- [x] **Tarea 5.1: Ejecución y Corrección de la Suite Completa de Tests**
  - **RF Cubiertos:** RF-01 a RF-07
  - **Descripción:** Ejecutar la totalidad de las pruebas unitarias del proyecto asegurando que no existan tests fallidos, regresiones o advertencias.
  - **Hecho cuando:** El comando `flutter test` ejecute todas las suites de prueba retornando exit code 0 (`All tests passed!`).

- [x] **Tarea 5.2: Verificación de Análisis Estático y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal (docs/constitution.md)
  - **Descripción:** Ejecutar el análisis estático en todo el proyecto asegurando cero errores y cumplimiento estricto de las reglas de linter definidas en `analysis_options.yaml`.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).
