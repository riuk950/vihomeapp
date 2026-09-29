# Plan Técnico de Implementación: Mejora de Interfaz (UI) en la Tabla de Solicitudes (004-vihomeapp-mvp)

Este documento define la arquitectura técnica, la estructura modular, el modelo de datos, las decisiones de diseño justificadas y la estrategia de verificación automatizada para la modernización de la interfaz de la tabla y lista de solicitudes de arrendamiento (para Arrendador y Arrendatario), resolviendo integralmente los 17 hallazgos detectados por la auditoría de QA y respetando los principios de la [Constitución del Proyecto](docs/constitution.md).

---

## 1. Resolución Integral de Hallazgos de Auditoría QA

El siguiente cuadro formaliza la subsanación técnica y de diseño para cada una de las observaciones identificadas en la auditoría de la especificación funcional:

| ID QA | Hallazgo Detectado por QA | Solución Técnica en el Plan | Cobertura |
| :--- | :--- | :--- | :--- |
| **1.1** | Ambigüedad en la modalidad operativa del botón de contacto rápido (¿Llamada o WhatsApp?). | Se implementa una fila de acciones directas compactas (`ContactActionsRow`): presenta botones independientes y claros con ícono de llamada (`tel:`) y con ícono de WhatsApp (`https://wa.me/`). Si el contacto tiene teléfono, el usuario elige el canal deseado en un solo toque. | RF-18.2, RF-19.2, RF-20.2 |
| **1.2** | Ambigüedad en formato legible de fecha y localización. | Se crea el componente utilitario `ApplicationDateFormatter` basado en `intl` (`es_CO` / `es`). Aplica regla de frescura: *"Hoy, HH:mm"* si es de hoy; *"Ayer, HH:mm"* si fue ayer; *"Hace X días"* si es de la última semana; o *"d MMM yyyy"* para fechas anteriores. | RF-18.2, RF-18.3 |
| **1.3** | Persistencia del filtro activo ante navegación al detalle y refresco. | El estado del filtro (`_currentFilter`) se conserva en `ApplicationProvider`. Al navegar al detalle y volver (`pop`), el filtro seleccionado no se reinicia. Durante el *pull-to-refresh*, se recargan los datos del servidor manteniendo la pestaña actualmente activa. | RF-20.1, RF-21.1, RF-21.2, RF-22.3 |
| **1.4** | Fallo en dispositivos sin soporte telefónico o sin WhatsApp instalado. | Se encapsula el lanzamiento en `ExternalContactLauncher` utilizando `canLaunchUrl` y `launchUrl`. Ante excepciones o falta de aplicación compatible, captura el error y despliega un `SnackBar` accesible con el número telefónico y opción rápida para copiar al portapapeles. | RF-20.2, CL-16 |
| **1.5** | Alcance de la vista de solicitudes del Arrendador. | La bandeja del arrendador consolida **todas** las solicitudes recibidas de la totalidad de sus inmuebles. Cada tarjeta exhibe prominentemente el título de la propiedad (`tituloPropiedad`), permitiendo una supervisión global inmediata. | RF-18.2, RF-21.3 |
| **1.6** | Efecto de aprobación sobre solicitudes concurrentes al mismo inmueble. | La aceptación de una postulación actualiza localmente dicha solicitud a `Aceptada`. Las demás solicitudes para ese inmueble permanecen como `Pendientes` hasta que el arrendador las evalúe o el backend aplique reglas de disponibilidad. | RF-19.1, RF-19.2, CL-17 |
| **1.7** | Contradicción en contacto para solicitudes Rechazadas (Arrendador vs Arrendatario). | Regla simétrica unificada: Cuando una solicitud está en estado `Rechazada`, los botones de contacto directo rápido se omiten tanto para el Arrendatario como para el Arrendador, previniendo confusiones sobre procesos concluidos negativamente. | RF-18.2, RF-19.3 |
| **1.8** | Truncamiento de campos no listados ("descripciones"). | Se clarifica que la tarjeta presenta el título del inmueble (`maxLines: 1`), el nombre del postulante/contacto (`maxLines: 1`) y el motivo breve o paso siguiente (`maxLines: 1`), todos asegurados con `TextOverflow.ellipsis`. | RF-18.4, CL-15 |
| **1.9** | Criterio de orden cronológico descendente ante cambios de estado. | El ordenamiento se calcula con base en `application.createdAt` de forma descendente (más recientes primero), garantizando una lista estable sin brincos visuales durante la visualización activa. | RF-21.3 |
| **1.10** | Solicitud huérfana (Inmueble eliminado o dado de baja). | Si el inmueble asociado fue despublicado o borrado, `ApplicationModel` asigna un valor seguro de fallback: `tituloPropiedad = "Inmueble no disponible"` con estilo tipográfico atenuado y sin romper el renderizado. | CL-15, RNF-12 |
| **1.11** | Usuario contraparte con cuenta eliminada o suspendida. | Si el postulante o propietario no cuenta con perfil activo, se presenta el snapshot registrado en la postulación o *"Usuario no disponible"*, ocultando los botones de llamada/WhatsApp. | CL-16 |
| **1.12** | Manejo de solicitudes con estados no mapeados (`cancelada`, etc.). | Se establece una categoría de fallback `otro` en el modelo. En la interfaz se presenta únicamente en la pestaña `Todas` con un distintivo visual neutral grisáceo (*"Inactiva / Cancelada"*), sin alterar las pestañas específicas. | RF-21.1, CL-17 |
| **1.13** | Fallo en la invocación de servicios externos de comunicación. | `ExternalContactLauncher` captura excepciones de sistema operativo y ofrece retroalimentación amigable vía `SnackBar` con acción de copiado directo (`Clipboard.setData`). | RF-20.2, CL-16 |
| **1.14** | Error de red durante refresco manual vs carga inicial. | Manejo de error en dos fases: Si la lista ya contiene elementos en pantalla y falla el refresco (*pull-to-refresh*), se retienen los datos visibles y se alerta con un `SnackBar` informativo. La pantalla completa de error solo se activa si la lista estaba vacía y la carga inicial falló. | RF-22.3, RNF-09 |
| **1.15** | Sanitización de saltos de línea y emojis masivos en títulos y nombres. | Se crea `TextSanitizer.cleanSingleLine(String text)` que colapsa saltos de línea `\n` en espacios y recorta espacios redundantes (`trim()`), preservando la altura fija de la tarjeta. | RF-18.4, CL-15 |
| **1.16** | Corrección de sintaxis formal EARS (Conflicto Constitución 2.2). | Se corrigen y formalizan las cláusulas en el plan técnico: `MIENTRAS la solicitud esté Pendiente...` (estado), `CUANDO el usuario seleccione el filtro...` (evento), y `SI ocurre un error de red, ENTONCES...` (excepción). | Constitución 2.2 |
| **1.17** | Resolución formal de las 2 Dudas Abiertas: | **a) Contadores numéricos en chips de filtro:** SÍ, cada chip de filtro exhibe su badge numérico dinámico: `Todas (N)`, `Pendientes (N)`, `Aceptadas (N)`, `Rechazadas (N)`.<br>**b) Mensaje predeterminado de WhatsApp:** SÍ, el enlace de WhatsApp pre-carga el mensaje codificado: *"Hola [Nombre], te contacto desde ViHome respecto a la postulación para el inmueble [Título]"*. | Constitución 3.9, RF-20.2, RF-21.1 |

---

## 2. Estructura de Módulos (Clean Architecture)

El diseño respeta la separación estricta en tres capas (Dominio, Datos, Presentación) y el patrón de inyección de dependencias (`get_it`):

```
lib/
├── core/
│   └── utils/
│       ├── application_date_formatter.dart       # Formateo cronológico inteligente y localizado (RF-18.2, RF-18.3)
│       ├── external_contact_launcher.dart        # Lanzamiento seguro de llamada y WhatsApp con fallback (RF-20.2, CL-16)
│       └── text_sanitizer.dart                   # Sanitización de cadenas a una sola línea anti-overflow (RF-18.4, CL-15)
├── domain/
│   └── entities/
│       └── application.dart                      # Entidad extendida con teléfono y contacto contraparte opcionales
├── data/
│   └── models/
│       └── application_model.dart                # Deserialización segura con soporte para joins y snapshots de contacto
└── presentation/
    ├── providers/
    │   └── application_provider.dart             # Lógica de filtros ('Todas', 'Pendientes', 'Aceptadas', 'Rechazadas') y conteos
    ├── widgets/
    │   ├── solicitudes_filter_bar.dart           # Barra de chips de segmentación rápida con contadores dinámicos (RF-21.1)
    │   ├── solicitudes_empty_state.dart          # Estados vacíos con mensaje y botón de acción ilustrado (RF-22.1, RF-22.2)
    │   └── contact_actions_row.dart              # Botones duales compactos para llamada y WhatsApp (RF-20.2, RF-20.3)
    └── pages/
        ├── landlord/
        │   ├── solicitudes_arrendador_page.dart  # Pantalla del Arrendador con pull-to-refresh y filtros reactivos (RF-18.2, RF-21)
        │   └── widgets/
        │       └── application_card_landlord.dart# Tarjeta de alta densidad para postulaciones recibidas (RF-18.2, RF-18.4)
        └── tenant/
            ├── solicitudes_arrendatario_page.dart# Pantalla del Arrendatario con pull-to-refresh y filtros reactivos (RF-18.3, RF-21)
            └── widgets/
                └── application_card_tenant.dart  # Tarjeta de alta densidad con bloque de "Paso siguiente" (RF-18.3, RF-19)
```

---

## 3. Modelo de Datos JSON con Ejemplos Concretos

### 3.1. Ejemplo 1: Solicitud en Estado `Pendiente` (Vista Arrendador y Arrendatario)
* **RF Cubiertos:** RF-18.2, RF-18.3, RF-19.1, RF-20.2, RF-21.3
* **Comportamiento:** En la vista del Arrendatario muestra paso siguiente *"Esperando respuesta del propietario"* y sin botón de contacto. En la vista del Arrendador muestra el postulante con botón de llamada/WhatsApp activo.

```json
{
  "id": "sol-1001-aaaa-bbbb",
  "arrendatario_id": "usr-tenant-01",
  "arrendador_id": "usr-landlord-01",
  "propiedad_id": "prop-apt-402",
  "estado": "pendiente",
  "ingresos_mensuales": "$ 3.800.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/soporte_01.pdf",
  "nombre_arrendatario": "Carlos Alberto Restrepo",
  "telefono_arrendatario": "3124567890",
  "nombre_arrendador": "Beatriz Eugenia Salazar",
  "telefono_arrendador": "3009876543",
  "titulo_propiedad": "Apartamento 402 Edificio Los Sauces",
  "direccion_propiedad": "Calle 45 # 18-32, Bogotá",
  "precio_renta": 2100000.0,
  "created_at": "2026-09-29T14:15:00.000Z",
  "updated_at": "2026-09-29T14:15:00.000Z"
}
```

### 3.2. Ejemplo 2: Solicitud en Estado `Aceptada` (Contacto Habilitado)
* **RF Cubiertos:** RF-18.2, RF-18.3, RF-19.2, RF-20.2, RF-21.1
* **Comportamiento:** La postulación muestra insignia verde (*Aceptada*). El arrendatario visualiza *"Contacto habilitado"* y se activan los botones directos de llamada y WhatsApp hacia Beatriz Eugenia Salazar (`3009876543`).

```json
{
  "id": "sol-1002-cccc-dddd",
  "arrendatario_id": "usr-tenant-01",
  "arrendador_id": "usr-landlord-01",
  "propiedad_id": "prop-casa-campestre",
  "estado": "aceptada",
  "ingresos_mensuales": "$ 6.500.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/extracto.pdf",
  "nombre_arrendatario": "Carlos Alberto Restrepo",
  "telefono_arrendatario": "3124567890",
  "nombre_arrendador": "Beatriz Eugenia Salazar",
  "telefono_arrendador": "3009876543",
  "titulo_propiedad": "Casa Campestre El Retiro",
  "direccion_propiedad": "Vereda La Luz Km 4, Rionegro",
  "precio_renta": 4500000.0,
  "created_at": "2026-09-28T09:00:00.000Z",
  "updated_at": "2026-09-29T10:30:00.000Z"
}
```

### 3.3. Ejemplo 3: Solicitud en Estado `Rechazada` (Contacto Omitido)
* **RF Cubiertos:** RF-18.2, RF-18.3, RF-19.3, RF-21.1
* **Comportamiento:** Insignia roja (*Rechazada*). Paso siguiente: *"Solicitud no aprobada"*. Se omiten los botones de llamada y WhatsApp para ambas partes, evitando roces.

```json
{
  "id": "sol-1003-eeee-ffff",
  "arrendatario_id": "usr-tenant-02",
  "arrendador_id": "usr-landlord-01",
  "propiedad_id": "prop-hab-03",
  "estado": "rechazada",
  "ingresos_mensuales": "$ 1.200.000",
  "documento_url": "https://supabase.co/storage/v1/object/solicitudes/id.pdf",
  "nombre_arrendatario": "Laura Marcela Morales",
  "telefono_arrendatario": "3151112233",
  "nombre_arrendador": "Beatriz Eugenia Salazar",
  "telefono_arrendador": "3009876543",
  "titulo_propiedad": "Habitación Amoblada Universitaria",
  "direccion_propiedad": "Carrera 9 # 65-10, Chapinero",
  "precio_renta": 750000.0,
  "created_at": "2026-09-20T11:20:00.000Z",
  "updated_at": "2026-09-21T16:00:00.000Z"
}
```

### 3.4. Ejemplo 4: Solicitud con Inmueble No Disponible (Resiliencia / Caso Límite)
* **RF Cubiertos:** RF-18.4, CL-15, CL-16, RNF-12
* **Comportamiento:** El título se reemplaza por *"Inmueble no disponible"*, el teléfono viene vacío por lo que no se muestra botón de llamada, y el sistema no arroja error de renderizado.

```json
{
  "id": "sol-1004-gggg-hhhh",
  "arrendatario_id": "usr-tenant-03",
  "arrendador_id": "usr-landlord-02",
  "propiedad_id": "prop-eliminada-99",
  "estado": "pendiente",
  "ingresos_mensuales": "$ 2.500.000",
  "documento_url": null,
  "nombre_arrendatario": "Juan Pablo Duque",
  "telefono_arrendatario": null,
  "nombre_arrendador": null,
  "telefono_arrendador": null,
  "titulo_propiedad": null,
  "direccion_propiedad": null,
  "precio_renta": null,
  "created_at": "2026-09-25T18:00:00.000Z",
  "updated_at": "2026-09-25T18:00:00.000Z"
}
```

---

## 4. Decisiones Técnicas Justificadas y Alternativas Descartadas

### Decisión 1: Fila de contacto dual directa (Llamada + WhatsApp) en la tarjeta
* **Elección:** Proveer botones independientes con diseño compacto en `ContactActionsRow` (ícono telefónico verde esmeralda e ícono de WhatsApp).
* **Justificación:** Resuelve el hallazgo QA 1.1 y cumple con el principio de agilidad del usuario móvil: un solo toque abre el marcador o la conversación de WhatsApp con el mensaje pre-cargado.
* **Alternativa Descartada:** Desplegar una hoja modal inferior (*BottomSheet*) o diálogo de selección cada vez que se presione un botón genérico de contacto. Se descartó por añadir un paso innecesario y ralentizar la comunicación en solicitudes operativas.

### Decisión 2: Chips de filtro universales con insignias de conteo integradas en `ApplicationProvider`
* **Elección:** Centralizar la lógica de filtrado y conteos reactivos (`totalCount`, `pendingCount`, `acceptedCount`, `rejectedCount`) en `ApplicationProvider`, alimentando la barra compartida `SolicitudesFilterBar`.
* **Justificación:** Garantiza sincronización inmediata en tiempo real (<50 ms), elimina duplicación de lógica entre la pantalla del arrendador y la del arrendatario, y resuelve el hallazgo QA 1.17 con conteos explícitos (`Pendientes (3)`).
* **Alternativa Descartada:** Realizar una consulta de base de datos a Supabase con `.eq('estado', status)` cada vez que el usuario toque un chip de filtro. Se descartó porque provocaría parpadeos en pantalla, mayor latencia y consumo innecesario de red sobre datos que ya se encuentran en memoria.

### Decisión 3: Formateo cronológico inteligente y localizado con `intl`
* **Elección:** Crear `ApplicationDateFormatter` para transformar marcas de tiempo en representaciones legibles contextualmente (*"Hoy, 14:15"*, *"Ayer, 09:00"*, *"Hace 3 días"*, *"14 sep 2026"*).
* **Justificación:** Resuelve el hallazgo QA 1.2, estandarizando la tipografía y facilitando el escaneo rápido de las solicitudes más urgentes.
* **Alternativa Descartada:** Mostrar fechas rígidas numéricas en formato ISO o cadenas brutas (`"2026-09-29 14:15:00"`). Se descartó por ser poco intuitivo y no adaptarse al lenguaje natural de los usuarios.

### Decisión 4: Manejo de errores de red en dos fases (Pantalla completa vs SnackBar flotante)
* **Elección:** Si la lista contiene solicitudes previamente cargadas y el gesto de *pull-to-refresh* falla, el Provider retiene los elementos y emite un `SnackBar` informativo no intrusivo (*"No se pudo actualizar. Mostrando datos anteriores"*). La vista de error a pantalla completa se reserva exclusivamente para cuando la lista se encuentra totalmente vacía y la carga inicial falla.
* **Justificación:** Resuelve el hallazgo QA 1.14 y garantiza una experiencia de usuario resiliente (RNF-09), protegiendo el trabajo y contexto del usuario.
* **Alternativa Descartada:** Borrar la lista existente y pintar una pantalla roja o gris de error bloqueante ante cualquier fallo de red transitorio durante el refresco. Se descartó por degradar severamente la experiencia de usuario.

### Decisión 5: Sanitización estricta de una sola línea y truncamiento elíptico en tarjetas
* **Elección:** Limpiar títulos y nombres mediante `TextSanitizer.cleanSingleLine`, reemplazando cualquier `\n` o salto por un espacio y aplicando `maxLines: 1` con `overflow: TextOverflow.ellipsis`.
* **Justificación:** Resuelve los hallazgos QA 1.8 y 1.15, previniendo deformaciones visuales y garantizando tarjetas simétricas sin *RenderFlex overflow* en cualquier resolución desde 320 px (RNF-12).
* **Alternativa Descartada:** Permitir que los textos crezcan dinámicamente en múltiples líneas sin límite. Se descartó porque altera la densidad visual de la lista y dificulta la navegación fluida.

---

## 5. Estrategia de Tests y Verificación Integral

De acuerdo con el principio de **Desarrollo Guiado por Comportamiento y Verificación** (Constitución 2.3), se establecen suites automatizadas de pruebas en las tres capas:

### 5.1. Matriz de Cobertura de Pruebas

| Capa | Archivo de Prueba | Escenarios Verificados | RF / CL / QA Cubiertos |
| :--- | :--- | :--- | :--- |
| **Core / Utils** | `test/core/utils/application_date_formatter_test.dart` | • Fechas de hoy con hora (`Hoy, 14:30`).<br>• Fechas de ayer con hora (`Ayer, 09:15`).<br>• Fechas de los últimos 7 días (`Hace 3 días`).<br>• Fechas históricas en formato localizado (`14 sep 2026`). | RF-18.2, RF-18.3, QA 1.2 |
| **Core / Utils** | `test/core/utils/text_sanitizer_test.dart` | • Sanitización de títulos con saltos de línea `\n` convertidos a espacios.<br>• Recorte de espacios en blanco múltiples.<br>• Truncamiento seguro para textos extensos con puntos suspensivos. | RF-18.4, CL-15, QA 1.15 |
| **Core / Utils** | `test/core/utils/external_contact_launcher_test.dart` | • Generación correcta de URI telefónica (`tel:3124567890`).<br>• Generación de URI de WhatsApp con mensaje URL-encoded.<br>• Manejo seguro de excepción cuando el dispositivo no puede abrir la URL. | RF-20.2, CL-16, QA 1.1, QA 1.4, QA 1.13 |
| **Datos** | `test/data/models/application_model_extended_test.dart` | • Deserialización de teléfonos de arrendatario y arrendador.<br>• Mapeo seguro ante inmueble nulo / eliminado (`Inmueble no disponible`).<br>• Mapeo seguro ante usuario eliminado / no disponible.<br>• Serialización y deserialización sin pérdida de datos. | RF-18.2, RF-18.3, CL-15, CL-16, QA 1.10, QA 1.11 |
| **Presentación** | `test/presentation/providers/application_provider_filter_test.dart` | • Filtrado reactivo por `Todas`, `Pendientes`, `Aceptadas`, `Rechazadas`.<br>• Cálculo dinámico exacto de conteos (`totalCount`, `pendingCount`, etc.).<br>• Preservación del filtro activo durante recarga de solicitudes.<br>• Resiliencia de pull-to-refresh: retención de datos previos ante fallo de red. | RF-21.1, RF-21.2, RF-22.3, QA 1.3, QA 1.14, QA 1.17 |
| **Widgets** | `test/presentation/pages/landlord/solicitudes_arrendador_page_test.dart` | • Renderizado de lista de alta densidad con tarjetas de solicitudes recibidas.<br>• Presencia de botones de llamada y WhatsApp para solicitudes pendientes/aceptadas.<br>• Ocultamiento de botones de contacto en solicitudes rechazadas.<br>• Interacción con chips de filtro actualizando la vista inmediatamente.<br>• Visualización de estado vacío cuando el filtro seleccionado no tiene elementos. | RF-18.2, RF-20.1, RF-20.2, RF-21.1, RF-22.2, QA 1.7 |
| **Widgets** | `test/presentation/pages/tenant/solicitudes_arrendatario_page_test.dart` | • Renderizado de solicitudes enviadas con bloque de "Paso siguiente".<br>• Estado `Pendiente` exhibe "Esperando respuesta del propietario" sin contacto.<br>• Estado `Aceptada` exhibe "Contacto habilitado" y activa botones de contacto directo.<br>• Estado `Rechazada` exhibe "Solicitud no aprobada" sin botones de contacto.<br>• Estado vacío con botón de acción "Explorar inmuebles". | RF-18.3, RF-19.1 - RF-19.3, RF-20.2, RF-22.1, QA 1.6 |

---

## 6. Comandos de Verificación Automatizada

Los siguientes comandos deben ejecutarse en la terminal para certificar la calidad y el cumplimiento estricto de la entrega:

### Comando 1: Ejecución de Tests Unitarios y de Utilidades Centrales
```bash
flutter test test/core/utils/application_date_formatter_test.dart test/core/utils/text_sanitizer_test.dart test/core/utils/external_contact_launcher_test.dart test/data/models/application_model_extended_test.dart
```
* **Salida Esperada:**
  ```text
  00:02 +18: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 2: Ejecución de Tests de Lógica de Estado y Filtros
```bash
flutter test test/presentation/providers/application_provider_filter_test.dart
```
* **Salida Esperada:**
  ```text
  00:03 +12: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 3: Ejecución de Tests de Widgets e Interfaz de Usuario
```bash
flutter test test/presentation/pages/landlord/solicitudes_arrendador_page_test.dart test/presentation/pages/tenant/solicitudes_arrendatario_page_test.dart
```
* **Salida Esperada:**
  ```text
  00:05 +16: All tests passed!
  ```
* **Código de Salida:** `0`

### Comando 4: Verificación Integral de No Regresión
```bash
flutter test
```
* **Salida Esperada:** Todas las suites de prueba de la aplicación ejecutadas exitosamente (100% passed).
* **Código de Salida:** `0`

### Comando 5: Análisis Estático y Validación de Reglas de Código
```bash
flutter analyze
```
* **Salida Esperada:**
  ```text
  Analyzing vihomeapp...
  No issues found!
  ```
* **Código de Salida:** `0`
