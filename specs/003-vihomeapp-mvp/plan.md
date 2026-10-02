# Plan Técnico de Implementación: Formularios Independientes de Solicitud de Arrendamiento (003-vihomeapp-mvp)

Este documento define la arquitectura técnica, la estructura modular, el modelo de datos, las decisiones de diseño y la estrategia de verificación automatizada para la implementación de formularios contextuales de postulación a arrendamientos, resolviendo integralmente los hallazgos de calidad auditados por QA y respetando los principios de la [Constitución del Proyecto](docs/constitution.md).

---

## 1. Resolución Integral de Hallazgos de Auditoría QA

El siguiente cuadro detalla cómo se subsana técnicamente cada observación identificada en la auditoría de la especificación:

| ID QA | Hallazgo Detectado | Solución Técnica en el Plan | Cobertura |
| :--- | :--- | :--- | :--- |
| **1.1** | Ambigüedad en normalización de tipos de propiedad con tildes/sinónimos. | Se crea `PropertyCategoryResolver`, un servicio de dominio que sanitiza cadenas (`trim()`, minúsculas, remoción de acentos diacríticos) y mapea a un enum canónico: `PropertyCategory.residential`, `PropertyCategory.individual`, `PropertyCategory.commercial`. | RF-13.1, RF-13.2, CL-14 |
| **1.2** | Falta de límite superior en número de ocupantes. | Se establece un rango estricto de enteros entre 1 y 20 personas en `ContextualFormValidator.validateOccupants()`. | RF-14.1, CL-10 |
| **1.3** | Universo de ocupaciones en habitaciones. | Se implementa un selector cerrado con 4 opciones estándar: `Estudiante`, `Empleado`, `Independiente`, `Otro / Sin actividad fija`. | RF-15.1 |
| **1.4** | Restricción de caracteres en nombre de acudiente. | Se aplica la expresión regular `^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]{5,80}$` que admite espacios, apóstrofes y caracteres del alfabeto en español. | RF-15.3, CL-11 |
| **1.5** | Formato y puntuación del NIT comercial. | Se valida mediante `^[a-zA-Z0-9.\-]{6,20}$`, admitiendo números, letras, puntos separadores y guion de verificación. | RF-16.2 |
| **1.6** | Tratamiento de solicitudes legacy / previas en visualización. | El renderizador del arrendador evalúa si `datosContextuales` es nulo o vacío; en tal caso, despliega un banner informativo neutral: *"Solicitud estándar previa (sin datos contextuales adicionales)"* sin arrojar excepciones. | RF-17.1, RF-17.2 |
| **1.7** | Dudas abiertas de parentesco y umbral de edad. | *Parentesco:* Se implementa un menú cerrado (`Padre/Madre`, `Tutor Legal`, `Familiar Cercano`, `Otro`).<br>*Edad:* Para el MVP no se exige fecha de nacimiento; se valida la declaración afirmativa `esMenorDeEdad == true`. | RF-15.2, RF-15.3, CL-11 |
| **2.1** | Contradicción entre comprobante universal y menor de edad sin ingresos. | En el formulario individual, cuando `esMenorDeEdad == true`, la interfaz informa que los ingresos declarados y el comprobante adjunto deben corresponder al acudiente o responsable económico. | RF-13.3, RF-15.1 |
| **2.2** | Discrepancia entre longitud de mascotas (3-150) y campo vacío. | La validación de mascotas es condicional: si `tieneMascotas == true`, se exige que la longitud del texto cumpla estrictamente `longitud >= 3 && longitud <= 150`. | RF-14.3, CL-12 |
| **2.3** | Preservación de datos vs toggle de switches condicionales. | Los controladores de texto en `ApplicationProvider` retienen el contenido en memoria aunque el switch cambie a "No". Si el usuario vuelve a activar "Sí", los datos previos reaparecen intactos. Solo al enviar la petición final se descartan si el switch quedó en "No". | RNF-08, RNF-09 |
| **3.1** | Propiedad despublicada o alterada durante el llenado. | El caso de uso valida la disponibilidad previa del inmueble; si no está disponible, retorna un `PropertyNotAvailableFailure` controlado que la vista muestra mediante un diálogo descriptivo. | CL-13, RNF-10 |
| **3.2** | Postulaciones duplicadas al mismo inmueble. | `CreateApplicationUseCase` valida si existe una solicitud activa (`pendiente` o `en_revision`) del mismo usuario para la propiedad; en caso afirmativo, retorna `DuplicateApplicationFailure`. | CL-10 |
| **3.3** | Inmuebles de tipología mixta o no catalogada. | La resolución aplica regla de precedencia canónica: Comercial > Residencial > Individual. Ante cualquier ambigüedad residual no catalogada, recurre a `PropertyCategory.residential`. | CL-14 |
| **3.4** | Consistencia de archivo adjunto ante fallos de red. | El objeto `PlatformFile` seleccionado permanece referenciado en el estado del Provider para no obligar al usuario a buscar nuevamente el archivo en su dispositivo tras un fallo. | RNF-09, CL-13 |
| **3.5** | Teléfono de acudientes internacionales. | Se valida longitud numérica de 10 dígitos (estándar nacional móvil de Colombia) o de 7 a 15 dígitos con prefijo internacional opcional (`+`). | RF-15.3, CL-11 |
| **4.1-4.2** | Corrección de sintaxis formal EARS. | Se formalizan los criterios bajo `CUANDO` (eventos de interacción/envío) y `SI... ENTONCES...` (manejo de excepciones y validaciones de campo), eliminando el uso erróneo de `MIENTRAS` en validaciones transaccionales. | Constitución 2.2 |
| **4.3** | Compatibilidad no destructiva con suite existente. | `Application` y `ApplicationModel` se extienden agregando el campo opcional `datosContextuales: ApplicationContextData?`. Los tests unitarios y de widgets previos de `001-` y `002-` continuarán pasando al 100%. | Constitución 2.3 |
| **4.4** | Alineación de rutas de especificación. | Se estandariza formalmente la ubicación de documentos en `specs/003-vihomeapp-mvp/`. | Constitución 3 |

---

## 2. Estructura de Módulos (Clean Architecture)

El diseño respeta la separación estricta en capas (Dominio, Datos, Presentación) y el patrón inyector de dependencias (`get_it`):

```
lib/
├── core/
│   └── utils/
│       ├── context_form_validator.dart         # Validaciones puras de campos contextuales (RF-14 a RF-16)
│       └── property_category_resolver.dart     # Sanitización y clasificación de tipos de propiedad (RF-13.1, RF-13.2)
├── domain/
│   └── entities/
│       ├── application.dart                    # Entidad extendida con ApplicationContextData opcional
│       └── application_context_data.dart       # Jerarquía sellada (sealed class) de datos contextuales
│           ├── ResidentialContextData
│           ├── IndividualContextData
│           └── CommercialContextData
├── data/
│   └── models/
│       ├── application_model.dart              # Mapeo JSON con soporte para 'datos_contextuales'
│       └── application_context_data_model.dart # Serialización bidireccional (fromJson / toJson)
└── presentation/
    ├── providers/
    │   └── application_provider.dart           # Estado reactivo, validaciones en vivo y controladores
    ├── pages/
    │   ├── tenant/
    │   │   ├── solicitud_de_arriendo_page.dart # Orquestador principal que integra las secciones dinámicas
    │   │   └── widgets/
    │   │       ├── form_residencial_widget.dart# Campos de composición familiar y mascotas (RF-14)
    │   │       ├── form_individual_widget.dart # Campos de ocupación y acudiente para menores (RF-15)
    │   │       └── form_comercial_widget.dart  # Campos de razón social, NIT y actividad (RF-16)
    │   └── landlord/
    │       └── widgets/
    │           └── detalle_solicitud_contextual_card.dart # Visualización diferenciada para arrendador (RF-17)
```

---

## 3. Modelo de Datos JSON con Ejemplos

En el backend (Supabase), la tabla `solicitudes` almacena los datos contextuales estructurados en una columna de tipo `jsonb` denominada `datos_contextuales`.

### 3.1. Ejemplo 1: Solicitud Residencial Familiar (Casa / Apartamento / Finca)
**RF Cubiertos:** RF-13.2, RF-14.1, RF-14.2, RF-14.3

```json
{
  "id": "a4b7f8c1-9234-4b55-a123-567890abcdef",
  "arrendatario_id": "usr-1111-2222",
  "arrendador_id": "usr-3333-4444",
  "propiedad_id": "prop-5555-6666",
  "estado": "pendiente",
  "ingresos_mensuales": "$ 4.500.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/soporte_1.pdf",
  "datos_contextuales": {
    "tipo_categoria": "residencial",
    "numero_ocupantes": 4,
    "descripcion_familiar": "Familia conformada por dos adultos (esposos) y dos niños en edad escolar.",
    "tiene_mascotas": true,
    "detalle_mascotas": "Un perro de raza Golden Retriever de 3 años, entrenado y vacunado."
  },
  "created_at": "2026-09-29T16:30:00.000Z",
  "updated_at": "2026-09-29T16:30:00.000Z"
}
```

### 3.2. Ejemplo 2: Solicitud Individual / Estudiantil (Habitación / Apartaestudio)
**RF Cubiertos:** RF-13.2, RF-15.1, RF-15.2, RF-15.3

```json
{
  "id": "b8c2d1e0-4567-4a88-b234-678901bcdefa",
  "arrendatario_id": "usr-7777-8888",
  "arrendador_id": "usr-3333-4444",
  "propiedad_id": "prop-8888-9999",
  "estado": "pendiente",
  "ingresos_mensuales": "$ 2.000.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/soporte_acudiente.pdf",
  "datos_contextuales": {
    "tipo_categoria": "individual",
    "ocupacion": "Estudiante",
    "entidad_laboral_educativa": "Universidad Nacional de Colombia",
    "es_menor_de_edad": true,
    "acudiente": {
      "nombre_completo": "Martha Cecilia Gómez Torres",
      "telefono": "3104567890",
      "parentesco": "Madre"
    }
  },
  "created_at": "2026-09-29T16:35:00.000Z",
  "updated_at": "2026-09-29T16:35:00.000Z"
}
```

### 3.3. Ejemplo 3: Solicitud Comercial (Local / Oficina / Bodega)
**RF Cubiertos:** RF-13.2, RF-16.1, RF-16.2, RF-16.3

```json
{
  "id": "c9d3e2f1-6789-4c99-c345-789012cdefab",
  "arrendatario_id": "usr-9999-0000",
  "arrendador_id": "usr-3333-4444",
  "propiedad_id": "prop-1212-3434",
  "estado": "pendiente",
  "ingresos_mensuales": "$ 12.000.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/balance_comercial.pdf",
  "datos_contextuales": {
    "tipo_categoria": "comercial",
    "razon_social": "Inversiones y Alimentos del Café S.A.S.",
    "nit": "901.345.678-2",
    "actividad_economica": "Comercialización de café especial de origen, panadería artesanal y atención al público."
  },
  "created_at": "2026-09-29T16:40:00.000Z",
  "updated_at": "2026-09-29T16:40:00.000Z"
}
```

### 3.4. Ejemplo 4: Solicitud Histórica / Previa (Compatibilidad hacia atrás)
**RF Cubiertos:** RF-17.1, RF-17.2

```json
{
  "id": "d0e4f3a2-7890-4d00-d456-890123defabc",
  "arrendatario_id": "usr-1234-5678",
  "arrendador_id": "usr-3333-4444",
  "propiedad_id": "prop-0000-1111",
  "estado": "finalizada",
  "ingresos_mensuales": "$ 3.200.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/soporte_antiguo.pdf",
  "datos_contextuales": null,
  "created_at": "2026-08-15T10:00:00.000Z",
  "updated_at": "2026-08-20T12:00:00.000Z"
}
```

---

## 4. Decisiones Técnicas Justificadas y Alternativas Descartadas

### Decisión 1: Modelado de datos contextuales mediante jerarquía polimórfica (`sealed class`) y persistencia `jsonb`
* **Elección:** Utilizar una clase sellada en Dart (`sealed class ApplicationContextData`) con tres subclases inmutables (`ResidentialContextData`, `IndividualContextData`, `CommercialContextData`) y almacenar el payload en Supabase bajo la columna `datos_contextuales jsonb`.
* **Justificación:** Garantiza comprobación exhaustiva en tiempo de compilación con pattern matching (`switch (data)`), evita dispersión de tablas relacionales con claves foráneas nulas y mantiene máxima flexibilidad para futuras extensiones sin migraciones destructivas.
* **Alternativa Descartada:** Crear tres tablas hijas separadas en base de datos (`solicitudes_residenciales`, `solicitudes_habitaciones`, `solicitudes_comerciales`). Se descartó por generar sobrecarga en transacciones, duplicación de claves foráneas y alta complejidad en consultas con joins múltiples.

### Decisión 2: Enrutamiento dinámico mediante componentes modulares embebidos en una sola pantalla orquestadora
* **Elección:** Mantener `SolicitudDeArriendoPage` como la pantalla base orquestadora, la cual consulta a `PropertyCategoryResolver` y renderiza condicionalmente el sub-widget correspondiente (`FormResidencialWidget`, `FormIndividualWidget` o `FormComercialWidget`).
* **Justificación:** Preserva la navegación actual de la aplicación (`go_router`), no rompe los enlaces profundos ni los botones existentes en el detalle de la propiedad, y centraliza los pasos universales (subida de archivos, ingresos y botón de envío).
* **Alternativa Descartada:** Crear tres rutas independientes en el router (`/solicitud-residencial`, `/solicitud-habitacion`, `/solicitud-comercial`). Se descartó porque obligaba a duplicar lógica de autenticación, selección de archivos, manejo de errores de red y sincronización con el `ApplicationProvider`.

### Decisión 3: Normalización agnóstica de categorías en el Dominio (`PropertyCategoryResolver`)
* **Elección:** Implementar la sanitización de cadenas en la capa de dominio (`PropertyCategoryResolver.fromPropertyName(String rawName)`), convirtiendo a minúsculas y normalizando acentos con precedencia lógica (Comercial > Residencial > Individual) y recurriendo a `PropertyCategory.residential` por defecto.
* **Justificación:** Aísla a la aplicación de posibles inconsistencias en las cadenas registradas en el catálogo de Supabase o entradas manuales de propietarios, previniendo errores 404 o caídas inesperadas en la interfaz de usuario.
* **Alternativa Descartada:** Forzar una restricción de clave foránea o tipo `ENUM` estricto en la base de datos de inmediato. Se descartó en este MVP para no generar fallos en inmuebles ya publicados que contengan variaciones de escritura históricas.

### Decisión 4: Preservación no destructiva de estado en `ApplicationProvider`
* **Elección:** Mantener las instancias de los `TextEditingController` activas en el Provider y vincular la validez de los campos condicionales a banderas booleanas en memoria.
* **Justificación:** Cumple con el requisito RNF-09 y la expectativa de experiencia de usuario: si un postulante cambia accidentalmente el switch a "No" y vuelve a "Sí", no pierde la información ya digitada.
* **Alternativa Descartada:** Limpiar los controladores (`controller.clear()`) inmediatamente en el callback del switch `onChanged(false)`. Se descartó porque causaba frustración en el usuario ante toques involuntarios en la pantalla táctil.

---

## 5. Estrategia de Tests y Verificación Integral

Siguiendo el principio de **Desarrollo Guiado por Comportamiento y Verificación** (Constitución 2.3), se establecen las suites de pruebas automáticas requeridas:

### 5.1. Matriz de Cobertura de Pruebas

| Capa | Archivo de Prueba | Escenarios Verificados | RF / CL Cubiertos |
| :--- | :--- | :--- | :--- |
| **Dominio** | `test/core/utils/property_category_resolver_test.dart` | • Mapeo de "Casa", "Apartamento", "Finca" a categoría residencial.<br>• Mapeo de "Habitación", "habitacion", "Apartaestudio" a individual.<br>• Mapeo de "Local", "Oficina", "Bodega" a comercial.<br>• Fallback a residencial ante cadenas vacías o tipos desconocidos. | RF-13.1, RF-13.2, CL-14 |
| **Dominio** | `test/core/utils/context_form_validator_test.dart` | • Ocupantes entre 1 y 20 (válido) vs 0, negativos o >20 (rechazado).<br>• Descripción familiar entre 10 y 500 caracteres.<br>• Detalle de mascotas condicional (3 a 150 caracteres).<br>• Acudiente: nombre alfabético, teléfono de 10 dígitos y parentesco.<br>• Comercial: NIT alfanumérico (6-20) y actividad económica (10-500). | RF-14.1 - RF-14.3, RF-15.1 - RF-15.3, RF-16.1 - RF-16.3, CL-10, CL-11, CL-12 |
| **Datos** | `test/data/models/application_context_data_model_test.dart` | • Serialización y deserialización de `ResidentialContextData`.<br>• Serialización y deserialización de `IndividualContextData`.<br>• Serialización y deserialización de `CommercialContextData`.<br>• Manejo seguro de registros legacy con `datos_contextuales: null`. | RF-14, RF-15, RF-16, RF-17.1, RF-17.2 |
| **Presentación** | `test/presentation/providers/application_provider_contextual_test.dart` | • Selección de categoría y activación de validaciones en vivo.<br>• Preservación de datos tras alternar switches de mascotas y acudiente.<br>• Bloqueo del botón de envío si faltan campos contextuales requeridos.<br>• Prevención de solicitud duplicada ante inmueble ya postulado. | RF-13.3, RNF-08, RNF-09, CL-10, CL-11 |
| **Widgets** | `test/presentation/pages/tenant/solicitud_contextual_widget_test.dart` | • Renderizado dinámico del subformulario correcto según tipo de propiedad.<br>• Aparición reactiva de campos de mascotas y acudiente.<br>• Visualización de errores inline en campos con datos inválidos.<br>• Preservación de campos ante reintento por fallo de conexión simulado. | RF-13.1, RF-14.4, RF-15.4, RNF-08, RNF-10, CL-13 |
| **Widgets** | `test/presentation/pages/landlord/detalle_solicitud_contextual_widget_test.dart` | • Renderizado de tarjeta de Composición Familiar en propiedades residenciales.<br>• Renderizado de tarjeta de Ocupación y Acudiente en habitaciones.<br>• Renderizado de tarjeta de Datos Comerciales en locales/oficinas.<br>• Renderizado de tarjeta legacy amigable en solicitudes previas. | RF-17.1, RF-17.2 |

---

## 6. Comandos de Verificación Automatizada

Los siguientes comandos deben ejecutarse en la terminal para certificar la calidad y el cumplimiento estricto de la entrega:

### Comando 1: Ejecución de Tests Unitarios y de Dominio Contextuales
```bash
flutter test test/core/utils/property_category_resolver_test.dart test/core/utils/context_form_validator_test.dart test/data/models/application_context_data_model_test.dart
```
* **Salida Esperada:**
  ```text
  00:02 +18: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 2: Ejecución de Tests de Integración de Estado y Widgets
```bash
flutter test test/presentation/providers/application_provider_contextual_test.dart test/presentation/pages/tenant/solicitud_contextual_widget_test.dart test/presentation/pages/landlord/detalle_solicitud_contextual_widget_test.dart
```
* **Salida Esperada:**
  ```text
  00:04 +22: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 3: Verificación de No Regresión en la Suite Completa de la Aplicación
```bash
flutter test
```
* **Salida Esperada:** Todas las suites de pruebas del proyecto pasando exitosamente sin fallos ni advertencias.
* **Código de Salida:** `0`

### Comando 4: Análisis Estático y Validación de Reglas de Código
```bash
flutter analyze
```
* **Salida Esperada:**
  ```text
  Analyzing vihomeapp...
  No issues found!
  ```
* **Código de Salida:** `0`
