# Plan Técnico: Mitigación de Deuda Técnica y Calidad Integral (002-vihomeapp-mvp)

## 1. Alineación y Cobertura de Requisitos

Este plan técnico aborda la mitigación de deuda técnica arquitectónica, el desacoplamiento de servicios en tiempo real y la automatización de pruebas de interfaz de usuario para [specs/002-vihomeapp-mvp/spec.md](file:///Users/diego/FlutterProjects/vihomeapp/specs/002-vihomeapp-mvp/spec.md), respetando [docs/constitution.md](file:///Users/diego/FlutterProjects/vihomeapp/docs/constitution.md).

| Requisito Funcional | Módulos Responsables | Estrategia de Verificación / Tests |
| :--- | :--- | :--- |
| **RF-08: Formulario de Creación de Inmueble** | `presentation/pages/propiedades/crear_propiedad_page.dart` & `presentation/providers/landlord_properties_provider.dart` | `test/presentation/pages/propiedades/crear_propiedad_widget_test.dart` (validación visual, fotos y bloqueo) |
| **RF-09: Edición Segura de Inmueble** | `presentation/pages/propiedades/editar_propiedades_page.dart` & `presentation/providers/landlord_properties_provider.dart` | `test/presentation/pages/propiedades/editar_propiedades_widget_test.dart` (precarga y retención de foto mínima) |
| **RF-10: Formulario de Solicitud Financiera** | `presentation/pages/tenant/solicitud_de_arriendo_page.dart` & `presentation/providers/application_provider.dart` | `test/presentation/pages/tenant/solicitud_de_arriendo_widget_test.dart` (formato moneda `$ 2.500.000` y peso de archivo) |
| **RF-11: Reactividad y Sincronización Desacoplada** | `infrastructure/services/realtime_service.dart`, `presentation/providers/application_provider.dart` | `test/infrastructure/services/realtime_service_test.dart` & `test/presentation/providers/application_provider_realtime_test.dart` |
| **RF-12: Suscripciones y Restauración** | `infrastructure/services/iap_service.dart`, `presentation/providers/subscription_provider.dart` | `test/presentation/providers/subscription_provider_flow_test.dart` (diálogo modal, cancelación y recuperación) |

---

## 2. Estructura de Módulos y Desacoplamiento

Para eliminar el acoplamiento a singletons de infraestructura en providers y vistas, se introducen abstracciones limpias inyectables:

```
lib/
├── core/
│   ├── network/
│   │   └── network_info.dart                      # [RF-11.2] Verificación desacoplada de conexión
│   └── utils/
│       ├── currency_formatter.dart                # [RF-10.1] Formateador de moneda colombiana
│       └── file_validator.dart                    # [RF-10.2, RF-10.3, CL-08] Validación de peso y tipo
├── domain/
│   └── services/
│       ├── i_realtime_service.dart                # [RF-11] Contrato para escucha de eventos reactivos
│       └── i_iap_service.dart                     # [RF-12] Contrato para pagos y restauración IAP
├── infrastructure/
│   └── services/
│       ├── supabase_realtime_service.dart         # Implementación concreta de IRealtimeService
│       └── in_app_purchase_service.dart           # Implementación concreta de IIapService
└── presentation/
    ├── pages/
    │   ├── propiedades/
    │   │   ├── crear_propiedad_page.dart          # [RF-08] Formulario con validación en vivo
    │   │   └── editar_propiedades_page.dart       # [RF-09] Edición con regla de foto mínima
    │   ├── tenant/
    │   │   └── solicitud_de_arriendo_page.dart    # [RF-10] Formulario de postulación con comprobante
    │   └── suscripciones/
    │       └── subscription_page.dart             # [RF-12] Diálogo bloqueante y feedback de compra
    └── providers/
        ├── landlord_properties_provider.dart      # [RF-08, RF-09] Estado de formularios y guardado
        ├── application_provider.dart              # [RF-10, RF-11] Inyección de IRealtimeService
        └── subscription_provider.dart             # [RF-12] Inyección de IIapService
```

---

## 3. Modelo de Datos JSON

### 3.1. Carga de Formulario de Propiedad con Fotos Validadas [RF-08, RF-09]
```json
{
  "arrendador_id": "usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "titulo": "Apartamento acogedor cerca al parque",
  "descripcion": "Apartamento remodelado con iluminación natural y balcón privado.",
  "tipo_propiedad": "apartamento",
  "ciudad": "Bogotá",
  "direccion": "Carrera 15 # 85-30",
  "precio": 3200000,
  "habitaciones": 2,
  "banos": 2,
  "metros_cuadrados": 68.0,
  "fotos": [
    "https://storage.vihome.app/properties/prop_temp_01.jpg",
    "https://storage.vihome.app/properties/prop_temp_02.jpg"
  ],
  "publicado": true
}
```

### 3.2. Carga de Solicitud Financiera con Validación de Archivo [RF-10]
```json
{
  "arrendatario_id": "usr_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "propiedad_id": "prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a",
  "ingresos_mensuales": 8500000,
  "documento_url": "https://storage.vihome.app/applications/app_2026/extracto_bancario.pdf",
  "file_metadata": {
    "file_name": "extracto_bancario.pdf",
    "file_size_bytes": 2457600,
    "mime_type": "application/pdf"
  }
}
```

### 3.3. Evento de Escucha en Tiempo Real Desacoplado [RF-11]
```json
{
  "event_type": "INSERT",
  "schema": "public",
  "table": "solicitudes",
  "channel": "solicitudes:arrendador:usr_9b1deb4d",
  "payload": {
    "id": "app_new_99",
    "arrendador_id": "usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "propiedad_id": "prop_8f3a1290",
    "estado": "Pendiente",
    "created_at": "2026-03-22T16:00:00.000Z"
  }
}
```

---

## 4. Decisiones Técnicas Justificadas

### 4.1. Desacoplamiento de Servicios Reactivos (`IRealtimeService`)
- **Decisión:** Extraer las escuchas de sockets y canales Postgres a una interfaz inyectable `IRealtimeService` con implementaciones simulables mediante `StreamController`.
- **Justificación:** Resuelve el hallazgo de deuda técnica donde `ApplicationProvider` invocaba directamente `SupabaseService.instance.client`, permitiendo probar el 100% de la lógica de reconexión y llegada de solicitudes sin red.
- **Alternativa descartada:** Mantener las llamadas a Supabase dentro del Provider protegidas por condicionales `if (kDebugMode)`. Se descarta porque genera código sucio y frágil.

### 4.2. Formateo Reactivo en UI vía InputFormatters y Controladores Desacoplados
- **Decisión:** Implementar `CurrencyTextInputFormatter` reutilizable para validar y formatear los ingresos en vivo sin depender de parseos en el Provider.
- **Justificación:** Ofrece retroalimentación inmediata (< 100 ms) al usuario y garantiza que la entrada siempre sea un entero positivo.
- **Alternativa descartada:** Formatear el texto solo al perder el foco del campo. Se descarta por mala experiencia de usuario (UX).

### 4.3. Aislamiento del Cliente de Compras (`IIapService`)
- **Decisión:** Inyectar una abstracción `IIapService` en `SubscriptionProvider` para manejar las llamadas al plugin `in_app_purchase`.
- **Justificación:** Permite simular los flujos de compra exitosa, compra cancelada, compras no disponibles y restauración en pruebas unitarias y de widgets.
- **Alternativa descartada:** Llamar a `InAppPurchase.instance` directamente como singleton global. Se descarta porque causa errores `MissingPluginException` en entornos de test.

---

## 5. Estrategia de Pruebas Unitarias y de Widgets

```
test/
├── core/
│   └── utils/
│       ├── currency_formatter_test.dart       # Formato $ 2.500.000 [RF-10.1]
│       └── file_validator_test.dart           # Validación 10 MB y formatos [RF-10.2, RF-10.3, CL-08]
├── domain/
│   └── services/
│       ├── fake_realtime_service.dart         # Double de prueba para eventos reactivos [RF-11]
│       └── fake_iap_service.dart              # Double de prueba para compras [RF-12]
├── presentation/
│   ├── providers/
│   │   ├── application_provider_realtime_test.dart # Reconexión y desuscripción [RF-11.1, RF-11.4]
│   │   └── subscription_provider_flow_test.dart    # Flujo modal de compra y restauración [RF-12.1, RF-12.3]
│   └── pages/
│       ├── propiedades/
│       │   ├── crear_propiedad_widget_test.dart    # Validación visual, fotos y bloqueo [RF-08]
│       │   └── editar_propiedades_widget_test.dart # Retención de foto mínima [RF-09]
│       └── tenant/
│           └── solicitud_de_arriendo_widget_test.dart # Formulario interactivo [RF-10]
```

---

## 6. Comandos de Verificación y Salidas Esperadas

### 6.1. Ejecución de Análisis Estático
- **Comando:**
  ```bash
  flutter analyze
  ```
- **Salida Esperada (Exit Code: 0):**
  ```
  Analyzing vihomeapp...
  No issues found! (ran in 1.6s)
  ```

### 6.2. Ejecución Completa de Pruebas Unitarias y Widgets
- **Comando:**
  ```bash
  flutter test
  ```
- **Salida Esperada (Exit Code: 0):**
  ```
  00:06 +85: All tests passed!
  ```

### 6.3. Cobertura de Código
- **Comando:**
  ```bash
  flutter test --coverage
  ```
- **Salida Esperada (Exit Code: 0):**
  ```
  Generates coverage/lcov.info
  ```

---

## 7. Criterios de Finalización del Plan Técnico

1. Todos los requisitos funcionales (RF-08 a RF-12) tienen pruebas de widgets o pruebas unitarias aisladas asociadas.
2. Se eliminan las referencias a singletons de infraestructura en las clases sujetas a pruebas.
3. Se garantizan comandos de verificación con código de salida `0`.
4. No se introduce código de producción sin la aprobación del plan de tareas subsiguiente.
