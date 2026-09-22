# Plan Técnico de Implementación y Pruebas: ViHome MVP (001-vihomeapp-mvp)

## 1. Alineación y Cobertura de Requisitos

Este plan técnico define la arquitectura modular, el modelo de datos, las decisiones de diseño y la estrategia integral de pruebas unitarias para el MVP de ViHome, respetando estrictamente los principios de [docs/constitution.md](file:///Users/diego/FlutterProjects/vihomeapp/docs/constitution.md) y cubriendo la totalidad de los requisitos funcionales de [specs/001-vihomeapp-mvp/spec.md](file:///Users/diego/FlutterProjects/vihomeapp/specs/001-vihomeapp-mvp/spec.md).

| Requisito Funcional | Módulos Responsables | Cobertura en Pruebas Unitarias |
| :--- | :--- | :--- |
| **RF-01: Autenticación y Perfil** | `auth` (Domain / Data / Presentation) | `test/domain/usecases/auth/` & `test/presentation/providers/auth_provider_test.dart` |
| **RF-02: Búsqueda y Filtrado** | `property` (Domain / Data / Presentation) | `test/domain/usecases/property/` & `test/presentation/providers/property_provider_test.dart` |
| **RF-03: Visualización de Inmuebles** | `property` (Domain / Data) | `test/data/models/property_model_test.dart` & `test/presentation/providers/property_provider_test.dart` |
| **RF-04: Solicitud Financiera** | `tenant`, `application` (Domain / Data / Presentation) | `test/domain/usecases/tenant/` & `test/presentation/providers/application_provider_test.dart` |
| **RF-05: Publicación y Gestión (Límites)** | `landlord`, `property` (Domain / Data / Presentation) | `test/domain/usecases/landlord/` & `test/presentation/providers/landlord_properties_provider_test.dart` |
| **RF-06: Gestión de Solicitudes Arrendador** | `landlord`, `application` (Domain / Data / Presentation) | `test/domain/usecases/landlord/` & `test/presentation/providers/landlord_provider_test.dart` |
| **RF-07: Suscripciones y Publicidad** | `subscription` (Domain / Data / Presentation) | `test/presentation/providers/subscription_provider_test.dart` |

---

## 2. Estructura de Módulos

La arquitectura se organiza en tres capas limpias desacopladas (Clean Architecture) con inyección de dependencias centralizada:

```
lib/
├── core/
│   ├── errors/           # Fallos y Excepciones de Dominio (Failure, ServerException)
│   ├── network/          # Verificación de conectividad (NetworkInfo)
│   ├── router/           # Configuración declarativa de rutas y guards de autenticación [RF-01.3]
│   └── di/               # Contenedor de Inyección de Dependencias (Service Locator)
├── domain/
│   ├── entities/         # Entidades puras e inmutables del negocio
│   │   ├── user.dart                     [RF-01]
│   │   ├── property.dart                 [RF-02, RF-03, RF-05]
│   │   ├── application.dart              [RF-04, RF-06]
│   │   ├── tenant.dart                   [RF-04]
│   │   ├── landlord.dart                 [RF-05, RF-06]
│   │   └── subscription.dart             [RF-07]
│   ├── repositories/     # Contratos e interfaces de repositorio
│   │   ├── auth_repository.dart          [RF-01]
│   │   ├── property_repository.dart      [RF-02, RF-03, RF-05]
│   │   ├── application_repository.dart   [RF-04, RF-06]
│   │   └── subscription_repository.dart  [RF-07]
│   └── usecases/         # Casos de uso específicos por flujo
│       ├── auth/         # Login, Register, Logout, GetCurrentUser [RF-01]
│       ├── property/     # GetProperties, FilterProperties, GetPropertyById, CreateProperty, UpdateProperty [RF-02, RF-03, RF-05]
│       ├── tenant/       # SubmitApplication, GetMyApplications [RF-04]
│       ├── landlord/     # GetLandlordProperties, GetPropertyApplications, UpdateApplicationStatus [RF-05, RF-06]
│       └── subscription/ # GetSubscriptionStatus, PurchasePlan, CancelSubscription [RF-07]
├── data/
│   ├── models/           # DTOs con serialización/deserialización JSON (fromJson / toJson)
│   │   ├── user_model.dart               [RF-01]
│   │   ├── property_model.dart           [RF-02, RF-03, RF-05]
│   │   ├── application_model.dart        [RF-04, RF-06]
│   │   └── subscription_model.dart       [RF-07]
│   ├── datasources/      # Fuentes de datos remotas y locales
│   │   ├── remote/       # Clientes Supabase / HTTP API
│   │   └── local/        # Almacenamiento seguro / Cache
│   └── repositories/     # Implementaciones concretas de los contratos de dominio
└── presentation/
    ├── providers/        # Notificadores de estado (ChangeNotifier / StateNotifier)
    │   ├── auth_provider.dart                 [RF-01]
    │   ├── property_provider.dart             [RF-02, RF-03]
    │   ├── landlord_properties_provider.dart  [RF-05]
    │   ├── application_provider.dart          [RF-04, RF-06]
    │   └── subscription_provider.dart         [RF-07]
    └── widgets/          # Componentes visuales reutilizables
```

---

## 3. Modelo de Datos JSON

### 3.1. Entidad Usuario (`User`) [RF-01]
```json
{
  "id": "usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "email": "carlos.arrendador@vihome.app",
  "name": "Carlos Mendoza",
  "phone": "+573001234567",
  "role": "landlord",
  "created_at": "2026-03-15T10:30:00.000Z"
}
```

### 3.2. Entidad Propiedad (`Property`) [RF-02, RF-03, RF-05]
```json
{
  "id": "prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a",
  "landlord_id": "usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "title": "Apartamento moderno en Chapinero Alto",
  "description": "Hermoso apartamento con vista panorámica, 2 habitaciones y balcón.",
  "property_type": "apartamento",
  "city": "Bogotá",
  "address": "Calle 65 # 4-20",
  "price": 2800000.0,
  "bedrooms": 2,
  "bathrooms": 2,
  "area_m2": 75.5,
  "is_active": true,
  "photos": [
    "https://storage.vihome.app/properties/prop_8f3a_01.jpg",
    "https://storage.vihome.app/properties/prop_8f3a_02.jpg"
  ],
  "created_at": "2026-03-16T14:00:00.000Z"
}
```

### 3.3. Entidad Solicitud Financiera (`Application`) [RF-04, RF-06]
```json
{
  "id": "app_5e4f2b1a-9c8d-4e7f-1a2b-3c4d5e6f7a8b",
  "property_id": "prop_8f3a1290-7c2a-4b6e-8d5f-9e123456789a",
  "tenant_id": "usr_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "monthly_income": 8500000.0,
  "proof_documents": [
    {
      "document_name": "extracto_bancario_febrero.pdf",
      "document_url": "https://storage.vihome.app/applications/app_5e4f/extracto.pdf"
    }
  ],
  "status": "pending",
  "created_at": "2026-03-17T09:15:00.000Z",
  "updated_at": "2026-03-17T09:15:00.000Z"
}
```

### 3.4. Entidad Suscripción (`Subscription`) [RF-07]
```json
{
  "id": "sub_7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
  "user_id": "usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "plan_type": "premium",
  "status": "active",
  "max_properties": -1,
  "ads_enabled": false,
  "current_period_start": "2026-03-01T00:00:00.000Z",
  "current_period_end": "2026-04-01T00:00:00.000Z"
}
```

---

## 4. Decisiones Técnicas Justificadas

### 4.1. Separación de Dominio Puro vs. DTOs de Datos
- **Decisión:** Mantener entidades de dominio inmutables independientes (`domain/entities/`) y mapeadores serializables (`data/models/`).
- **Justificación:** Protege la lógica de negocio y las reglas de validación (por ejemplo, validación de ingresos mayores a cero o formatos de comprobantes) de los cambios de esquema del backend o API externa.
- **Alternativa descartada:** Usar los modelos serializables directamente en la UI. Se descarta porque acopla la vista y la lógica de validación a la estructura exacta de la base de datos o API.

### 4.2. Inyección de Dependencias Desacoplada (GetIt)
- **Decisión:** Registrar contratos abstractos (`Repository`, `DataSource`) en el Service Locator (`get_it`), resolviendo las implementaciones concretas en tiempo de inicialización.
- **Justificación:** Facilita la creación de mocks y fakes en las pruebas unitarias sin levantar servicios de red reales ni inicializar SDKs pesados.
- **Alternativa descartada:** Instanciar dependencias directamente dentro de los ChangeNotifiers/Providers. Se descarta porque impide la prueba aislada de componentes.

### 4.3. Manejo de Estado Reactivo por Dominio (Provider / ChangeNotifier)
- **Decisión:** Separar los estados por dominio específico (`AuthProvider`, `PropertyProvider`, `LandlordPropertiesProvider`, `ApplicationProvider`, `SubscriptionProvider`).
- **Justificación:** Evita estados monolíticos, reduce re-renderizados innecesarios y permite probar exhaustivamente los casos de éxito, carga y error de cada flujo de forma aislada.
- **Alternativa descartada:** Un único StateManager global. Se descarta por alta complejidad de mantenimiento, riesgo de efectos secundarios cruzados y dificultad para pruebas unitarias limpias.

---

## 5. Estrategia de Pruebas Unitarias

La estrategia de pruebas unitarias valida cada criterio de aceptación EARS sin requerir emuladores ni dispositivos físicos.

### 5.1. Matriz de Cobertura de Tests

```
test/
├── core/
│   └── errors/
│       └── failure_test.dart                 # Validación de mapeo de mensajes de error limpios [RNF-01]
├── domain/
│   ├── entities/
│   │   ├── property_test.dart                # Validación de invariantes de propiedad [RF-05.1]
│   │   └── application_test.dart             # Validación de invariantes de ingresos y documentos [RF-04.1, RF-04.2]
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase_test.dart       # RF-01.1, RF-01.2
│       │   └── register_usecase_test.dart    # RF-01.1, RF-01.3
│       ├── property/
│       │   ├── get_properties_test.dart      # RF-02.1, RF-02.2
│       │   ├── filter_properties_test.dart   # RF-02.1, RF-02.3
│       │   └── create_property_test.dart     # RF-05.1, RF-05.2, RF-05.3
│       ├── tenant/
│       │   └── submit_application_test.dart  # RF-04.1, RF-04.2, RF-04.4, CL-04
│       ├── landlord/
│       │   ├── get_applications_test.dart    # RF-06.1
│       │   └── update_status_test.dart       # RF-06.2, RF-06.3
│       └── subscription/
│           └── check_limits_test.dart        # RF-05.2, RF-07.1, RF-07.2, RF-07.3
├── data/
│   ├── models/
│   │   ├── user_model_test.dart              # Serialización y deserialización JSON [RF-01]
│   │   ├── property_model_test.dart          # Serialización y deserialización JSON [RF-02]
│   │   └── application_model_test.dart       # Serialización y deserialización JSON [RF-04]
│   └── repositories/
│       ├── property_repository_impl_test.dart
│       └── application_repository_impl_test.dart
└── presentation/
    └── providers/
        ├── auth_provider_test.dart           # RF-01.1, RF-01.2
        ├── property_provider_test.dart       # RF-02.1, RF-02.2, RF-02.3
        ├── landlord_properties_provider_test.dart # RF-05.1, RF-05.2, RF-05.3
        ├── application_provider_test.dart    # RF-04.1, RF-04.2, RF-04.3, RF-04.4
        └── subscription_provider_test.dart   # RF-07.1, RF-07.2, RF-07.3
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
  No issues found! (ran in 1.8s)
  ```
- **Salida en caso de Fallo (Exit Code: 1):**
  ```
  info • ... • lib/... • rule_name
  1 issue found.
  ```

### 6.2. Ejecución Completa de Pruebas Unitarias
- **Comando:**
  ```bash
  flutter test
  ```
- **Salida Esperada (Exit Code: 0):**
  ```
  00:04 +28: All tests passed!
  ```
- **Salida en caso de Fallo (Exit Code: 1):**
  ```
  00:03 +25 -1: ... Expected: <true> Actual: <false>
  Some tests failed.
  ```

### 6.3. Cobertura de Código de Pruebas Unitarias
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

1. Todos los requisitos funcionales (RF-01 a RF-07) tienen una correspondencia directa con módulos de dominio, datos y presentación.
2. Cada caso de uso y regla de validación de negocio dispone de una suite de pruebas unitarias definida.
3. Se garantizan comandos reproducibles con validación estricta de códigos de salida (`0` para éxito).
4. No se introduce código de producción ni modificaciones sin antes verificar las pruebas correspondientes según lo dictado en `docs/constitution.md`.
