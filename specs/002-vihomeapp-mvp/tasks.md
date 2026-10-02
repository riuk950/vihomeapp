# Tareas de Implementación: Mitigación de Deuda Técnica y Calidad Integral (002-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), ordenadas estrictamente por dependencias. Cada tarea especifica los Requisitos Funcionales (RF) que cubre y un criterio de aceptación verificable ("Hecho cuando:").

---

## Fase 1: Utilidades y Contratos de Servicio Desacoplados

- [x] **Tarea 1.1: Utilidad y Pruebas de Formato de Moneda (`CurrencyFormatter`)**
  - **RF Cubiertos:** RF-10.1
  - **Descripción:** Implementar pruebas unitarias y la clase utilitaria `CurrencyFormatter` / `CurrencyTextInputFormatter` para dar formato monetario con separador de miles en pesos colombianos (`$ 2.500.000`) y rechazar caracteres inválidos o valores negativos.
  - **Hecho cuando:** `flutter test test/core/utils/currency_formatter_test.dart` retorne exit code 0 con todos los casos de formateo validados.

- [x] **Tarea 1.2: Utilidad y Pruebas de Validación de Documentos (`FileValidator`)**
  - **RF Cubiertos:** RF-10.2, RF-10.3, CL-08
  - **Descripción:** Implementar pruebas unitarias y la clase `FileValidator` para comprobar formatos permitidos (PDF, JPG, PNG), límite de tamaño de 10 MB y detección de archivos vacíos o protegidos.
  - **Hecho cuando:** `flutter test test/core/utils/file_validator_test.dart` retorne exit code 0 en todos los escenarios de validación de archivos.

- [x] **Tarea 1.3: Definición de Interfaces de Servicios Inyectables (`IRealtimeService`, `IIapService`)**
  - **RF Cubiertos:** RF-11.1, RF-12.1, RNF-05
  - **Descripción:** Crear los contratos abstractos en `lib/domain/services/` para la escucha en tiempo real de eventos y para las operaciones del plugin de compras dentro de la app (IAP), junto con sus fakes de prueba en `test/domain/services/`.
  - **Hecho cuando:** `flutter test test/domain/services/fake_services_test.dart` retorne exit code 0 validando la compilación y tipado de los contratos.

---

## Fase 2: Desacoplamiento de Servicios y Gestión de Estado

- [x] **Tarea 2.1: Tests y Desacoplamiento de Reactividad en Tiempo Real**
  - **RF Cubiertos:** RF-11.1, RF-11.2, RF-11.3, RF-11.4, CL-07
  - **Descripción:** Implementar pruebas unitarias para la escucha reactiva mediante `IRealtimeService` simulado, verificando la llegada de inserciones de solicitudes, reconexión progresiva tras fallo de red y cancelación de canales al cerrar sesión.
  - **Hecho cuando:** `flutter test test/infrastructure/services/realtime_service_test.dart` retorne exit code 0.

- [x] **Tarea 2.2: Refactorización y Tests de `ApplicationProvider` con `IRealtimeService`**
  - **RF Cubiertos:** RF-11.1, RF-11.2, RF-11.4
  - **Descripción:** Actualizar `ApplicationProvider` para recibir opcionalmente `IRealtimeService` inyectado en su constructor, eliminando el acceso directo a `SupabaseService.instance.client` en pruebas unitarias.
  - **Hecho cuando:** `flutter test test/presentation/providers/application_provider_test.dart` retorne exit code 0 sin advertencias de inicialización de backend.

- [x] **Tarea 2.3: Tests y Flujo de `SubscriptionProvider` con `IIapService` Inyectable**
  - **RF Cubiertos:** RF-12.1, RF-12.2, RF-12.3, RF-12.4, RF-12.5, CL-09
  - **Descripción:** Implementar pruebas de flujo para `SubscriptionProvider` utilizando `IIapService` simulado, cubriendo compra exitosa, cancelación voluntaria del usuario, catálogo no disponible y sincronización al arranque.
  - **Hecho cuando:** `flutter test test/presentation/providers/subscription_provider_flow_test.dart` retorne exit code 0.

---

## Fase 3: Pruebas de Widgets y Validación Visual de Formularios

- [x] **Tarea 3.1: Pruebas de Widgets para Creación de Propiedad (`crear_propiedad_widget_test.dart`)**
  - **RF Cubiertos:** RF-08.1, RF-08.2, RF-08.3, RF-08.4, CL-05
  - **Descripción:** Implementar pruebas de widgets con `WidgetTester` para `CrearPropiedadPage` verificando validaciones en vivo (título 5-80 chars, precio > 0), selección de fotos, bloqueo ante 0 fotos y estado deshabilitado del botón durante el guardado.
  - **Hecho cuando:** `flutter test test/presentation/pages/propiedades/crear_propiedad_widget_test.dart` retorne exit code 0.

- [x] **Tarea 3.2: Pruebas de Widgets para Edición de Propiedad (`editar_propiedades_widget_test.dart`)**
  - **RF Cubiertos:** RF-09.1, RF-09.2, RF-09.3
  - **Descripción:** Implementar pruebas de widgets para `EditarPropiedadesPage` verificando la precarga correcta de datos y la regla que impide eliminar la última foto sin agregar un reemplazo.
  - **Hecho cuando:** `flutter test test/presentation/pages/propiedades/editar_propiedades_widget_test.dart` retorne exit code 0.

- [x] **Tarea 3.3: Pruebas de Widgets para Solicitud Financiera (`solicitud_de_arriendo_widget_test.dart`)**
  - **RF Cubiertos:** RF-10.1, RF-10.2, RF-10.3, RF-10.4, CL-06
  - **Descripción:** Implementar pruebas de widgets para `SolicitudDeArriendoPage` validando el formateo de moneda en el campo de texto, visualización del archivo adjunto y diálogo de confirmación exitosa.
  - **Hecho cuando:** `flutter test test/presentation/pages/tenant/solicitud_de_arriendo_widget_test.dart` retorne exit code 0.

---

## Fase 4: Verificación Integral de Suite de Pruebas y Calidad

- [x] **Tarea 4.1: Ejecución de la Suite Completa de Tests Automatizados**
  - **RF Cubiertos:** RF-01 a RF-12
  - **Descripción:** Ejecutar todas las pruebas unitarias y de widgets del proyecto asegurando 0 tests fallidos y elevando la cobertura global.
  - **Hecho cuando:** El comando `flutter test` retorne exit code 0 con todas las suites pasando.

- [x] **Tarea 4.2: Verificación de Análisis Estático y Reglas de Linter**
  - **RF Cubiertos:** Calidad transversal (docs/constitution.md)
  - **Descripción:** Ejecutar el análisis estático en todo el proyecto asegurando cero advertencias y cero errores de linter.
  - **Hecho cuando:** El comando `flutter analyze` retorne exit code 0 (`No issues found!`).
