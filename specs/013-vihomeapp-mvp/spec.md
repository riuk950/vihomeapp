# Especificación: Migración de la Librería de Diseño Legada al Paquete Independiente `material_ui`

## 1. Contexto y Objetivo

### 1.1. Contexto
ViHome utiliza actualmente la librería de diseño Material acoplada de forma legada al kit base de desarrollo de la aplicación en todas sus pantallas, componentes reutilizables, tema visual y pruebas automatizadas. Con la evolución hacia una distribución independiente del sistema de diseño (`material_ui`), mantener la aplicación acoplada a la librería legada genera deuda técnica, limita la adopción oportuna de mejoras de componentes visuales y expone al proyecto a futuras deprecaciones o rupturas al actualizar la plataforma base.

### 1.2. Objetivo
Migrar integralmente la aplicación ViHome desde la librería de diseño integrada legada hacia el paquete independiente **`material_ui`**, cumpliendo los siguientes propósitos:

- Desacoplar los componentes visuales y el sistema de tematización de la librería legada hacia el paquete independiente `material_ui` de manera completa y consistente en toda la aplicación y su suite de pruebas.
- Garantizar una transición **100 % transparente** para las personas usuarias finales, preservando sin cambios la identidad visual de marca, los colores, la tipografía, los espaciados, los mensajes y el comportamiento de todos los flujos existentes.
- Resolver de forma controlada cualquier incompatibilidad con librerías o integraciones externas mediante puentes de compatibilidad o actualizaciones a versiones estables compatibles, sin degradar ninguna pantalla ni función.
- Validar de forma verificable que la migración no introduce regresiones de calidad, pruebas ni compilación en los entornos de desarrollo y producción para Android.

### 1.3. Comportamientos Existentes Preservados y Compatibilidad
En cumplimiento de la Constitución del Proyecto (Sección 2.3), esta migración **no modifica reglas de negocio ni flujos de usuario**. Todos los comportamientos funcionales previamente especificados y entregados deben permanecer intactos tras la migración:

| Capacidad existente | Comportamiento que DEBE preservarse íntegro |
| :--- | :--- |
| **Bienvenida inicial (`011-vihomeapp-mvp`)** | Flujo de 4 pasos de única vez, navegación bidireccional, identidad visual clara de marca, disponibilidad sin conexión y persistencia del estado visto. |
| **Rol invitado y entrada a Arriendos (`012-vihomeapp-mvp`)** | Acceso directo a Arriendos tras onboarding y en cada apertura, exploración pública de Arriendos/Ventas/Proyectos/Mapa/Detalles, ocultamiento de notificaciones, banner contextual en inicio de sesión, botón *"Continuar como invitado"* y redirecciones protegidas. |
| **Eliminación de cuenta (`010-account-deletion`)** | Opción destructiva en Perfil y Panel, diálogo modal de confirmación explícita, borrado en cascada, confirmación exitosa hacia Arriendos en modo invitado y preservación de sesión ante fallos. |
| **Flujos de arrendatario y arrendador** | Publicación y edición de propiedades, solicitudes contextuales, seguimiento, calificaciones y reseñas, mapa interactivo, notificaciones, suscripciones y recuperación de contraseña. |
| **Tema e identidad visual de ViHome** | Paleta de marca clara, tipografía corporativa, estilos de barras superiores, diálogos, botones principales, tarjetas, avisos flotantes y navegación inferior. |

---

## 2. Perfiles de Usuario

| Perfil de usuario | Descripción | Necesidad principal |
| :--- | :--- | :--- |
| **Equipo de desarrollo y mantenimiento** | Personas encargadas de evolucionar, mantener y publicar nuevas versiones de ViHome. | Contar con el proyecto completamente migrado al paquete independiente `material_ui`, libre de referencias legadas ambiguas, advertencias de análisis y bloqueos de compilación. |
| **Equipo de aseguramiento de calidad (QA)** | Responsables de verificar ausencia de regresiones visuales, funcionales y de compilación antes de publicar. | Disponer de criterios objetivos de verificación en pruebas automatizadas y compilaciones de desarrollo y producción para confirmar una migración sin impacto adverso. |
| **Usuario final (invitado, arrendatario o arrendador)** | Persona que utiliza ViHome en su dispositivo móvil diariamente. | Continuar usando la aplicación con exactamente la misma apariencia, fluidez y funcionalidad habitual sin notar interrupciones, errores visuales ni comportamientos inesperados. |

---

## 3. Historias de Usuario

### HU-01: Migración Integral hacia el Paquete Independiente `material_ui`
**Como** equipo técnico de ViHome,
**quiero** migrar todas las pantallas, componentes visuales, tematización y pruebas automatizadas de la aplicación desde la librería de diseño legada hacia el paquete independiente `material_ui`,
**para** mantener el proyecto desacoplado, actualizado y libre de deuda técnica sin alterar la experiencia visual ni funcional de los usuarios finales.

---

## 4. Requisitos Funcionales (RF-x)

### RF-1: Verificación de prerrequisitos del entorno antes de migrar
El proceso valida que el entorno base de desarrollo cumple las condiciones mínimas de compatibilidad antes de aplicar cambios sobre el proyecto.

**Criterios de aceptación (EARS):**
- **RF-1.1:** CUANDO se inicie la migración, el sistema DEBERÁ verificar que la versión del entorno base de desarrollo soporta el paquete independiente `material_ui` y la resolución limpia de todas las dependencias del proyecto.
- **RF-1.2:** SI el entorno base de desarrollo no cumple la versión mínima requerida por `material_ui` o presenta incompatibilidades bloqueantes insalvables, ENTONCES el proceso DEBERÁ detener la migración y reportar de forma clara el prerrequisito exacto faltante sin dejar cambios parciales o rotos en el proyecto.

---

### RF-2: Adopción completa del paquete `material_ui` en producción y pruebas
La aplicación y su suite de pruebas migran sus referencias visuales de forma uniforme y libre de ambigüedades.

**Criterios de aceptación (EARS):**
- **RF-2.1:** El sistema DEBERÁ declarar e incorporar el paquete independiente `material_ui` en una versión estable compatible con el resto de dependencias del proyecto.
- **RF-2.2:** El sistema DEBERÁ reemplazar en la totalidad de los módulos de aplicación y pruebas las referencias a la librería de diseño legada por referencias al paquete independiente `material_ui`.
- **RF-2.3:** El sistema DEBERÁ evitar la coexistencia no controlada de referencias legadas y referencias de `material_ui` dentro de un mismo módulo que produzca ambigüedad de componentes o tipos.
- **RF-2.4:** DONDE la aplicación utilice recursos de localización de componentes visuales de diseño, el sistema DEBERÁ vincular dichos recursos a los provistos por `material_ui`.

---

### RF-3: Compatibilidad controlada con librerías e integraciones externas
Las integraciones externas existentes (enrutamiento, mapas, imágenes remotas, animaciones, anuncios, selección de archivos, compartición y actualizaciones) continúan operando sin errores de tipo ni pérdida de funcionalidad.

**Criterios de aceptación (EARS):**
- **RF-3.1:** CUANDO una dependencia externa presente incompatibilidad de tipos visuales o de tema con `material_ui`, el sistema DEBERÁ resolver la incompatibilidad actualizando la dependencia a una versión estable compatible o aplicando el puente de compatibilidad oficial correspondiente.
- **RF-3.2:** MIENTRAS exista cualquier puente de compatibilidad temporal para una dependencia externa, el sistema DEBERÁ garantizar la operación íntegra y sin degradación funcional de todas las pantallas que utilicen dicha integración.

---

### RF-4: Preservación total de identidad visual, tematización y comportamiento funcional
La migración no altera el aspecto ni las interacciones percibidas por las personas usuarias.

**Criterios de aceptación (EARS):**
- **RF-4.1:** MIENTRAS el usuario navegue por cualquiera de las pantallas de ViHome (bienvenida inicial, Arriendos, Ventas, Proyectos, Mapa, Detalles de propiedad y proyecto, inicio de sesión, registro, Perfil, Panel, gestión de propiedades, solicitudes, reseñas, notificaciones y suscripciones), el sistema DEBERÁ conservar intacta la paleta de marca, la tipografía corporativa, los estilos de diálogos, barras, botones, avisos y controles de navegación.
- **RF-4.2:** CUANDO el usuario ejecute cualquier flujo interactivo existente (navegación entre pestañas, apertura de diálogos y hojas inferiores, envío de formularios, manejo de modo invitado, inicio/cierre de sesión y eliminación de cuenta), el sistema DEBERÁ responder de manera idéntica a la versión previa a la migración.
- **RF-4.3:** MIENTRAS el usuario visualice la aplicación en pantallas móviles compactas o grandes, o con el teclado virtual desplegado, el sistema DEBERÁ mantener el diseño libre de recortes, solapamientos y desbordamientos visuales.

---

### RF-5: Manejo de errores, datos incompletos y permisos sin regresiones
Los mecanismos existentes de retroalimentación comprensible y tolerancia a fallos permanecen operativos tras el cambio de librería visual.

**Criterios de aceptación (EARS):**
- **RF-5.1:** SI ocurre un escenario de falta de conexión, fallo de servicio, denegación de permisos del dispositivo o datos incompletos en cualquier pantalla existente, ENTONCES el sistema DEBERÁ continuar mostrando la retroalimentación visual comprensible y las acciones de reintento definidas previamente sin cierres inesperados.

---

### RF-6: Validación integral de calidad, pruebas y compilación en Android
La migración solo se considera válida cuando supera análisis estático, pruebas automatizadas y compilación en ambos entornos de Android.

**Criterios de aceptación (EARS):**
- **RF-6.1:** CUANDO concluya la migración de módulos y pruebas, el análisis estático del proyecto DEBERÁ finalizar con cero errores y cero advertencias.
- **RF-6.2:** CUANDO se ejecute la suite completa de pruebas automatizadas del proyecto, el sistema DEBERÁ aprobar el 100 % de las pruebas existentes y de verificación sin regresiones.
- **RF-6.3:** CUANDO se compile la aplicación para Android en el entorno de desarrollo y en el entorno de producción, ambos artefactos DEBERÁN construirse exitosamente sin errores de compilación.

---

## 5. Requisitos No Funcionales (RNF-x)

- **RNF-1 — Paridad visual y estabilidad:** La aplicación migrada DEBERÁ presentar cero excepciones en tiempo de ejecución derivadas de tipos de tema, componentes o localización, y mantener paridad visual completa frente a la línea base previa.
- **RNF-2 — Rendimiento percibido:** La migración a `material_ui` NO DEBERÁ degradar los tiempos de arranque, fluidez de desplazamiento ni tiempos de transición entre pantallas (manteniendo transiciones por debajo de 350 milisegundos).
- **RNF-3 — Accesibilidad preservada:** Todas las mejoras existentes de contraste (mínimo 4.5:1 nivel AA), áreas táctiles mínimas (48 × 48 puntos táctiles) y descripciones para lectores de pantalla DEBERÁN permanecer intactas tras la migración.
- **RNF-4 — Mantenibilidad y limpieza:** El proyecto DEBERÁ quedar sin dependencias duplicadas innecesarias, sin advertencias de análisis estático y con cualquier puente de compatibilidad externo claramente delimitado para facilitar su retiro futuro.
- **RNF-5 — Idioma consistente:** Todos los textos, avisos y etiquetas de interfaz DEBERÁN continuar presentándose en español neutro sin aparición de textos por defecto en inglés derivados de cambios en localización.

---

## 6. Casos Límite y Excepciones

| Caso límite / Excepción | Comportamiento esperado |
| :--- | :--- |
| **Entorno de desarrollo con versión inferior a la requerida por `material_ui`** | La verificación previa detecta la incompatibilidad, detiene la migración y reporta el prerrequisito exacto sin aplicar modificaciones parciales ni dejar el proyecto sin compilar (`RF-1.2`). |
| **Conflicto de versiones entre `material_ui` y una dependencia externa** | Se evalúa actualización a versión estable compatible o puente de compatibilidad oficial; si existe un conflicto irresoluble, se reporta claramente el paquete bloqueante antes de comprometer la estabilidad (`RF-3.1`, `RF-1.2`). |
| **Incompatibilidad de tipos de tema o contexto con un componente externo (mapas, anuncios, imágenes o enrutamiento)** | Se resuelve mediante actualización estable o puente de compatibilidad asegurando que la pantalla afectada renderice y opere sin excepciones (`RF-3.1`, `RF-3.2`). |
| **Cambio sutil en propiedades por defecto de temas (diálogos, botones, barras superiores, hojas inferiores)** | Se verifica y ajusta la configuración del tema central para conservar exactamente la apariencia previa de marca (`RF-4.1`). |
| **Textos por defecto de componentes (ej. botones de cierre, etiquetas de diálogos o tooltips) cambiando de idioma** | Se verifican los recursos de localización para garantizar continuidad en español sin textos inesperados en inglés (`RF-2.4`, `RNF-5`). |
| **Pruebas automatizadas con referencias mixtas entre librería legada y `material_ui`** | Toda la suite de pruebas se migra de forma consistente para evitar errores de búsqueda de widgets o fallos por tipos distintos (`RF-2.2`, `RF-6.2`). |
| **Compilación exitosa en entorno de desarrollo pero fallo en entorno de producción (ofuscación/optimización)** | Ambos entornos de Android (desarrollo y producción) se validan antes del cierre para detectar y corregir diferencias de empaquetado (`RF-6.3`). |
| **Uso de la app sin conexión, con permisos denegados o datos incompletos tras la migración** | Todos los avisos, diálogos de error y botones de reintento conservan su apariencia y funcionamiento habitual (`RF-5.1`). |

---

## 7. Fuera de Alcance

Quedan explícitamente excluidos de esta entrega:

1. **Rediseño visual**, ajustes estéticos, cambios de paleta/tipografía o activación de un tema oscuro funcional.
2. **Migración de componentes de estilo nativo secundario (Cupertino)**, dado que la aplicación no los utiliza directamente.
3. **Soporte multilenguaje** (la aplicación permanece exclusivamente en español).
4. **Validación de compilación nativa en iOS** (queda diferida a una verificación posterior).
5. **Cambios funcionales o modificaciones de reglas de negocio** en cualquiera de los módulos o historias de usuario existentes.
6. **Actualizaciones masivas de dependencias externas no relacionadas** con la compatibilidad de `material_ui`.

---

## 8. Criterios de Finalización (Definition of Done)

La entrega se considerará finalizada y verificada cuando se cumpla todo lo siguiente:

- [ ] **Prerrequisitos verificados (`RF-1.1`, `RF-1.2`):** Se confirmó compatibilidad del entorno base y resolución limpia de `material_ui` (o, en su defecto, se reportó formalmente el bloqueo sin alterar el proyecto).
- [ ] **Migración completa (`RF-2.1`–`RF-2.4`):** El paquete `material_ui` está incorporado y el 100 % de los módulos de aplicación y pruebas fueron migrados sin referencias ambiguas ni pérdidas de localización.
- [ ] **Compatibilidad externa (`RF-3.1`, `RF-3.2`, `RNF-4`):** Todas las dependencias externas operan sin errores de tipo (actualizadas a versiones estables compatibles o mediante puente de compatibilidad delimitado).
- [ ] **Paridad visual, accesibilidad y resiliencia (`RF-4.1`–`RF-4.3`, `RF-5.1`, `RNF-1`–`RNF-5`):** Identidad visual, accesibilidad, idioma español, fluidez y manejo de errores/permisos/datos incompletos se mantienen intactos en todos los flujos preservados (`010`, `011`, `012` y módulos base).
- [ ] **Análisis estático limpio (`RF-6.1`):** El análisis estático concluye con 0 errores y 0 advertencias.
- [ ] **Regresión en verde (`RF-6.2`, Constitución 2.3):** El 100 % de la suite automatizada de pruebas pasa sin regresiones.
- [ ] **Compilación Android verificada (`RF-6.3`):** La compilación para Android concluye con éxito tanto en el entorno de desarrollo como en el de producción.

---

## 9. Dudas Abiertas

No quedan dudas abiertas ni elementos pendientes marcados con `[NECESITA ACLARACIÓN]`. Todas las decisiones funcionales, criterios de compatibilidad y límites de alcance han sido confirmados para avanzar a la fase de planificación técnica (`specs/013-vihomeapp-mvp/plan.md`).
