# Especificación: Flujo de Onboarding Inicial de ViHome (MVP)

## 1. Contexto y Objetivo

### Contexto
ViHome es una plataforma móvil inmobiliaria para la búsqueda, compra, venta, arrendamiento y gestión digital de propiedades y proyectos. Actualmente, cuando una persona instala la aplicación por primera vez, ingresa directamente al flujo de acceso sin una introducción previa que explique qué ofrece la plataforma ni qué la diferencia de los procesos inmobiliarios tradicionales.

### Objetivo
Incorporar un flujo de bienvenida (onboarding) de cuatro pantallas secuenciales que se muestre **una única vez tras la instalación de la aplicación**. Su propósito es:

- Comunicar de forma clara, breve y visual los cuatro pilares de valor de ViHome: descubrimiento de propiedades certificadas, comunicación directa sin intermediarios, contratos digitales con validez legal y gestión integral del hogar.
- Reducir la fricción inicial antes del acceso a la cuenta, permitiendo avanzar a su ritmo, omitir la introducción o ir directamente al inicio de sesión.
- Evitar interrupciones innecesarias en usos posteriores, garantizando que el onboarding no vuelva a mostrarse una vez completado u omitido, ni a usuarios que ya cuentan con una sesión activa tras actualizar la aplicación.

---

## 2. Perfiles de Usuario

| Perfil de usuario | Descripción | Necesidad principal frente al onboarding |
| :--- | :--- | :--- |
| **Usuario nuevo (instalación limpia)** | Persona que descarga y abre ViHome por primera vez en su dispositivo y no tiene sesión activa. | Entender rápidamente qué puede hacer en ViHome y avanzar sin fricción hacia el inicio de sesión o registro. |
| **Usuario nuevo con cuenta previa** | Persona que instala ViHome en un nuevo dispositivo (o tras reinstalarla o borrar los datos de la aplicación), pero ya posee una cuenta registrada. | Saltar rápidamente la introducción o acceder de inmediato al inicio de sesión desde cualquier pantalla del onboarding. |
| **Usuario existente que actualiza la app con sesión activa** | Persona que ya tenía ViHome instalada y mantiene una sesión activa al actualizar a esta versión. | Entrar directamente a la aplicación sin ser interrumpido por una introducción dirigida a usuarios nuevos. |
| **Usuario existente que actualiza la app sin sesión activa** | Persona que tenía una versión previa de ViHome instalada sin sesión activa ni registro previo de onboarding. | Recibir la bienvenida una única vez y poder omitirla o ir directamente al inicio de sesión. |
| **Usuario recurrente** | Persona que ya completó u omitió el onboarding en una apertura anterior (tenga o no sesión iniciada en ese momento). | Nunca volver a ver el flujo de bienvenida al abrir la aplicación ni al cerrar sesión. |

---

## 3. Historias de Usuario

### HU-01: Flujo de Onboarding Inicial (Única Vez tras Instalación)
**Como** usuario nuevo que instala la aplicación ViHome por primera vez,
**quiero** visualizar una guía interactiva de bienvenida de cuatro pasos al abrir la aplicación por primera vez,
**para** conocer rápidamente la propuesta de valor de la plataforma antes de iniciar sesión o crear una cuenta, sin que esta guía vuelva a aparecer en aperturas posteriores.

---

## 4. Requisitos Funcionales (RF-x)

### RF-1: Activación del onboarding únicamente en la primera apertura sin sesión activa
El sistema determina al iniciar la aplicación si corresponde mostrar el flujo de bienvenida o continuar con el flujo habitual de la aplicación.

**Criterios de aceptación (EARS):**
- **RF-1.1:** CUANDO la aplicación finalice su carga inicial y no exista registro de que el onboarding fue visto ni exista una sesión de usuario activa, el sistema DEBERÁ mostrar la pantalla del paso 1 del onboarding.
- **RF-1.2:** MIENTRAS exista registro de que el onboarding ya fue visto, el sistema DEBERÁ omitir el onboarding al finalizar la carga inicial y dirigir al usuario al flujo habitual correspondiente a su estado de sesión (inicio de sesión si no está autenticado, o vista principal si tiene sesión activa).
- **RF-1.3:** CUANDO un usuario existente abra la aplicación tras una actualización y posea una sesión activa sin registro previo del onboarding, el sistema DEBERÁ omitir el onboarding, registrar automáticamente que el onboarding ya fue visto y dirigir al usuario a la vista principal.
- **RF-1.4:** CUANDO un usuario existente abra la aplicación tras una actualización sin sesión activa y sin registro previo del onboarding, el sistema DEBERÁ mostrar la pantalla del paso 1 del onboarding una única vez.

---

### RF-2: Presentación secuencial y estructura consistente de las cuatro pantallas
El onboarding presenta exactamente cuatro pasos en orden fijo, respetando los títulos, mensajes descriptivos, composiciones visuales ilustrativas, controles comunes e identidad gráfica de ViHome:

1. **Paso 1 — Conecta con tu Espacio Ideal**
   - **Título:** *Conecta con tu Espacio Ideal*
   - **Descripción:** *Encuentra propiedades exclusivas, contacta directamente con arrendadores certificados y gestiona contratos seguros.*
   - **Contenido visual ilustrativo:** Tarjeta de propiedad destacada de ejemplo (propiedad verificada de lujo, ubicación y canon mensual ilustrativos) rodeada de insignias visuales de mensajería, verificación, arrendador disponible y favoritos.
   - **Acción principal:** *Continuar*
2. **Paso 2 — Conexión Directa**
   - **Título:** *Conexión Directa y Transparente*
   - **Descripción:** *Comunícate en tiempo real con arrendadores y constructoras certificadas, sin intermediarios ni demoras innecesarias.*
   - **Contenido visual ilustrativo:** Escena de asesoría inmobiliaria con sello de verificación, indicador de respuesta rápida en línea e insignias de envío de mensajes, asesor disponible y seguridad.
   - **Acción principal:** *Continuar*
3. **Paso 3 — Contratos Digitales**
   - **Título:** *Contratos Digitales Seguros*
   - **Descripción:** *Genera y firma contratos de arriendo con total respaldo jurídico y validez legal al instante, desde cualquier lugar.*
   - **Contenido visual ilustrativo:** Escena de firma digital con sello de validez legal, indicador de certificación inmediata e insignias de seguridad, respaldo notarial y protección.
   - **Acción principal:** *Continuar*
4. **Paso 4 — Gestión Integral**
   - **Título:** *Gestión Integral Sin Fricción*
   - **Descripción:** *Administra solicitudes, pagos automáticos y el mantenimiento de tu nuevo hogar con una experiencia digital fluida.*
   - **Contenido visual ilustrativo:** Tarjeta de gestión de vivienda conectada (estado de pago al día, gestión continua y mantenimiento cubierto) acompañada de insignias de acceso, débito automático activo y confirmación.
   - **Acción principal:** *Comenzar Ahora*

**Criterios de aceptación (EARS):**
- **RF-2.1:** MIENTRAS el usuario visualice cualquiera de los cuatro pasos del onboarding, el sistema DEBERÁ mostrar la composición visual ilustrativa correspondiente al paso, el título, la descripción, el botón superior derecho *"Saltar"*, el indicador de progreso de cuatro posiciones, el botón de acción principal y el enlace inferior *"¿Ya tienes una cuenta? Iniciar Sesión"*.
- **RF-2.2:** MIENTRAS el usuario se encuentre en el paso 1, el sistema DEBERÁ ocultar el botón superior izquierdo de retroceso para evitar un control sin acción disponible.
- **RF-2.3:** MIENTRAS el usuario se encuentre en los pasos 2, 3 o 4, el sistema DEBERÁ mostrar activo el botón superior izquierdo de retroceso.
- **RF-2.4:** MIENTRAS el usuario se encuentre en los pasos 1, 2 o 3, el sistema DEBERÁ mostrar la etiqueta *"Continuar"* en el botón de acción principal.
- **RF-2.5:** MIENTRAS el usuario se encuentre en el paso 4, el sistema DEBERÁ mostrar la etiqueta *"Comenzar Ahora"* en el botón de acción principal.
- **RF-2.6:** El sistema DEBERÁ tratar los elementos internos de las ilustraciones (precios, etiquetas, insignias e iconos decorativos) y el indicador de progreso de cuatro posiciones únicamente como elementos visuales informativos no interactivos.

---

### RF-3: Navegación bidireccional, límites y sincronización de progreso
El usuario puede avanzar y retroceder entre los cuatro pasos manteniendo sincronizados el contenido visible y el indicador de progreso.

**Criterios de aceptación (EARS):**
- **RF-3.1:** CUANDO el usuario presione el botón *"Continuar"* o deslice horizontalmente hacia el paso siguiente mientras se encuentra en los pasos 1, 2 o 3, el sistema DEBERÁ avanzar exactamente un paso hacia adelante.
- **RF-3.2:** CUANDO el usuario presione el botón superior izquierdo de retroceso, deslice horizontalmente hacia el paso anterior o utilice la acción *"Atrás"* del dispositivo mientras se encuentra en los pasos 2, 3 o 4, el sistema DEBERÁ retroceder exactamente un paso hacia atrás.
- **RF-3.3:** MIENTRAS el usuario se encuentre en el paso 1, el sistema DEBERÁ impedir cualquier retroceso a un paso inexistente mediante deslizamiento horizontal.
- **RF-3.4:** MIENTRAS el usuario se encuentre en el paso 4, el sistema DEBERÁ impedir salir automáticamente del onboarding mediante deslizamiento horizontal hacia adelante.
- **RF-3.5:** CUANDO el usuario utilice la acción *"Atrás"* del dispositivo mientras se encuentra en el paso 1, el sistema DEBERÁ permitir la salida estándar de la aplicación manteniendo el onboarding como no visto.
- **RF-3.6:** CUANDO cambie el paso activo del onboarding, el sistema DEBERÁ actualizar el indicador de progreso de cuatro posiciones destacando visualmente el paso actual de forma diferenciada respecto a los tres restantes.
- **RF-3.7:** CUANDO ocurran pulsaciones rápidas consecutivas o acciones simultáneas (como deslizar mientras se presiona *"Continuar"* o *"Saltar"*), el sistema DEBERÁ procesar una única transición válida manteniendo sincronizados el paso visible y el indicador de progreso.

---

### RF-4: Finalización del recorrido desde el último paso
Al completar la lectura de los cuatro pasos, el usuario inicia su experiencia de acceso a ViHome sin posibilidad de regresar al onboarding mediante el historial de navegación.

**Criterios de aceptación (EARS):**
- **RF-4.1:** CUANDO el usuario presione el botón *"Comenzar Ahora"* mientras se encuentra en el paso 4, el sistema DEBERÁ registrar el onboarding como visto, reemplazar el historial de navegación del onboarding y dirigir al usuario a la pantalla de inicio de sesión.

---

### RF-5: Omisión del onboarding mediante la acción "Saltar"
El usuario puede omitir el recorrido desde cualquier pantalla del onboarding sin obligación de revisar los pasos restantes.

**Criterios de aceptación (EARS):**
- **RF-5.1:** CUANDO el usuario presione el botón *"Saltar"* en cualquiera de los cuatro pasos del onboarding, el sistema DEBERÁ registrar el onboarding como visto, reemplazar el historial de navegación del onboarding y dirigir al usuario inmediatamente a la pantalla de inicio de sesión.

---

### RF-6: Acceso directo al inicio de sesión desde el pie de página
El usuario que ya posee cuenta dispone de un acceso explícito y constante hacia el inicio de sesión en las cuatro pantallas.

**Criterios de aceptación (EARS):**
- **RF-6.1:** CUANDO el usuario presione el enlace *"¿Ya tienes una cuenta? Iniciar Sesión"* en cualquiera de los cuatro pasos del onboarding, el sistema DEBERÁ registrar el onboarding como visto, reemplazar el historial de navegación del onboarding y dirigir al usuario inmediatamente a la pantalla de inicio de sesión.

---

### RF-7: Persistencia del estado visto, historial y ciclo de vida de la app
El onboarding se presenta una única vez por instalación, respeta la continuidad temporal en segundo plano y nunca reaparece una vez cerrado formalmente ni tras cerrar sesión.

**Criterios de aceptación (EARS):**
- **RF-7.1:** CUANDO el onboarding haya sido marcado como visto (por completar el paso 4, pulsar *"Saltar"*, pulsar *"Iniciar Sesión"* o abrir la app con sesión activa), el sistema DEBERÁ conservar ese estado de forma persistente entre cierres y reaperturas de la aplicación.
- **RF-7.2:** CUANDO el usuario llegue a la pantalla de inicio de sesión tras completar u omitir el onboarding y presione la acción *"Atrás"* del dispositivo, el sistema DEBERÁ impedir regresar al flujo del onboarding.
- **RF-7.3:** CUANDO un usuario que ya completó u omitió el onboarding cierre su sesión en la aplicación, el sistema DEBERÁ mantener el onboarding registrado como visto y omitirlo al regresar al inicio de sesión o al reabrir la aplicación.
- **RF-7.4:** CUANDO el usuario cierre completamente la aplicación estando en cualquiera de los cuatro pasos (1, 2, 3 o 4) sin haber pulsado *"Comenzar Ahora"*, *"Saltar"* ni *"Iniciar Sesión"*, el sistema DEBERÁ mantener el onboarding como no visto y mostrarlo desde el paso 1 en la siguiente apertura.
- **RF-7.5:** CUANDO el usuario envíe la aplicación a segundo plano sin cerrarla mientras recorre cualquiera de los pasos y regrese posteriormente a primer plano, el sistema DEBERÁ conservar el paso exacto en el que se encontraba sin marcar el onboarding como visto.

---

### RF-8: Disponibilidad sin conexión y resiliencia ante fallos
El flujo de bienvenida no depende de conectividad externa y garantiza continuidad sin bloquear al usuario frente a fallos internos de almacenamiento local.

**Criterios de aceptación (EARS):**
- **RF-8.1:** MIENTRAS el dispositivo carezca de conexión a internet, el sistema DEBERÁ mostrar íntegras todas las imágenes, textos y controles de las cuatro pantallas del onboarding y permitir completar u omitir el flujo hacia la pantalla de inicio de sesión.
- **RF-8.2:** SI ocurre un error interno al guardar el estado de que el onboarding fue visto, ENTONCES el sistema DEBERÁ evitar bloquear al usuario, descartar el onboarding del historial de navegación actual y dirigirlo igualmente a la pantalla de inicio de sesión sin mostrar mensajes técnicos confusos. (Nota de experiencia: dado que el error no impide al usuario continuar con su objetivo inmediato de acceder a la aplicación, se prioriza una recuperación transparente sin interrupción; si vuelve a abrir la app sin sesión, el flujo podrá reintentar el registro en una apertura futura).
- **RF-8.3:** SI ocurre un error interno al leer el estado inicial del onboarding durante el arranque de la aplicación, ENTONCES el sistema DEBERÁ continuar sin cerrar ni congelar la aplicación y aplicar como respaldo determinista la visualización del paso 1 del onboarding si no existe sesión activa (o la vista principal si existe sesión activa).

---

## 5. Requisitos No Funcionales (RNF-x)

- **RNF-1 — Disponibilidad sin conexión completa:** Todos los textos e imágenes del onboarding DEBERÁN estar integrados localmente desde la instalación de la aplicación, sin depender de descargas remotas ni conectividad a internet.
- **RNF-2 — Fluidez y respuesta visual:** Las transiciones entre pasos y la actualización del indicador de progreso DEBERÁN completarse de forma fluida en menos de 350 milisegundos tras la acción del usuario, sin bloqueos ni parpadeos perceptibles.
- **RNF-3 — Adaptabilidad en orientación vertical:** El flujo DEBERÁ operar en orientación vertical en dispositivos móviles compactos y de pantalla grande, permitiendo que todo el contenido sea legible y que los botones de acción permanezcan visibles y accesibles sin recortes ni solapamientos, incluso cuando el tamaño de fuente del sistema esté aumentado.
- **RNF-4 — Coherencia visual e idioma:** Todos los textos DEBERÁN presentarse en español neutro y consistente con la identidad visual clara de ViHome (paleta azul profundo sobre fondo claro, jerarquía tipográfica nítida y tarjetas flotantes suavizadas), manteniendo dicha apariencia de marca independientemente del modo claro u oscuro configurado en el dispositivo.
- **RNF-5 — Accesibilidad:**
  - Los textos principales y secundarios DEBERÁN cumplir una relación de contraste mínima de 4.5:1 frente a su fondo (nivel AA).
  - Todos los controles interactivos (*"Continuar"*, *"Comenzar Ahora"*, *"Saltar"*, botón de retroceso y *"Iniciar Sesión"*) DEBERÁN ofrecer un área táctil mínima de 48 × 48 puntos/dp.
  - Los controles y el indicador de progreso DEBERÁN exponer descripciones comprensibles para lectores de pantalla (por ejemplo, *"Paso 2 de 4"*, *"Volver al paso anterior"*, *"Saltar introducción"*).

---

## 6. Casos Límite y Excepciones

| Caso límite / Excepción | Comportamiento esperado |
| :--- | :--- |
| **Cierre forzado a mitad del recorrido (pasos 1, 2, 3 o 4 sin confirmar salida)** | El estado permanece como no visto; al reabrir la aplicación, el onboarding comienza nuevamente en el paso 1. |
| **Aplicación enviada a segundo plano y reanudada (llamada o cambio de app)** | Si el sistema operativo no cerró el proceso, la aplicación retoma exactamente el paso donde estaba el usuario sin marcarlo como visto. |
| **Presionar *"Atrás"* del dispositivo justo después de salir del onboarding** | En la pantalla de inicio de sesión, presionar *"Atrás"* nunca regresa al onboarding; este ya fue descartado del historial. |
| **Pulsación repetida / doble toque rápido o gesto simultáneo con toque** | Una sola transición válida prevalece; no se producen pantallas duplicadas, saltos múltiples accidentales ni desincronización del indicador de progreso. |
| **Deslizamiento horizontal más allá de los límites (paso 1 atrás / paso 4 adelante)** | No produce errores ni cierra el onboarding; salir desde el paso 4 requiere pulsar *"Comenzar Ahora"*, *"Saltar"* o *"Iniciar Sesión"*. |
| **Usuario existente actualiza la app teniendo sesión iniciada** | El onboarding se omite por completo y se marca como visto para que tampoco aparezca si posteriormente cierra sesión. |
| **Usuario existente actualiza la app sin sesión iniciada** | Al no existir registro previo ni sesión activa, el onboarding se muestra una única vez y puede completarse u omitirse con normalidad. |
| **Usuario cierra sesión después de haber visto u omitido el onboarding** | El estado visto se conserva; el onboarding no vuelve a aparecer al volver al inicio de sesión ni al reabrir la app. |
| **Desinstalación y reinstalación, o borrado manual de datos de la app** | Al eliminarse el almacenamiento local y la sesión, se trata como una instalación limpia y el onboarding vuelve a mostrarse una única vez. |
| **Apertura en modo avión / sin conexión a internet** | Las cuatro pantallas se muestran completas con sus imágenes y textos, y el usuario puede avanzar hasta la pantalla de inicio de sesión sin errores. |
| **Fallo interno al guardar el estado visto** | El usuario no queda atrapado en el onboarding; avanza igualmente a la pantalla de inicio de sesión sin alertas técnicas confusas. |
| **Fallo interno al leer el estado inicial del onboarding** | La aplicación no se cierra ni se congela; aplica el respaldo determinista (muestra el paso 1 si no hay sesión activa, o la vista principal si hay sesión activa). |
| **Rotación física del dispositivo a orientación horizontal** | El flujo permanece protegido en orientación vertical (o sin recortes ni fallos) respetando la exclusión de orientación horizontal del MVP. |
| **Modo oscuro activado en el sistema operativo** | El onboarding conserva su paleta clara de marca y legibilidad de contraste sin inversiones no deseadas de color. |
| **Pantallas móviles pequeñas o tamaño de texto del sistema al máximo** | El contenido se adapta ordenadamente (permitiendo desplazamiento interno si es necesario) manteniendo accesibles los controles sin desbordamientos visuales. |

---

## 7. Fuera de Alcance

Quedan explícitamente excluidos de este MVP:

1. **Opción para volver a ver el onboarding** desde el perfil, ajustes o sección de ayuda.
2. **Soporte multilenguaje** (esta versión contempla únicamente español).
3. **Diseño dedicado para orientación horizontal**, tabletas o pantallas de escritorio.
4. **Interactividad sobre las tarjetas ilustrativas** (no se permite marcar favoritos, abrir propiedades de ejemplo, chatear ni navegar desde elementos decorativos de las cuatro pantallas) ni salto directo tocando los puntos del indicador de progreso.
5. **Instrumentación de analítica o seguimiento de eventos** (tasas de abandono, clics en *"Saltar"* o tiempo por pantalla).
6. **Diferenciación de pantalla de destino entre registro e inicio de sesión** desde el onboarding (todas las acciones de salida convergen en la pantalla de inicio de sesión).
7. **Gestión remota o dinámica del contenido del onboarding** (los cuatro pasos y sus textos son fijos en esta versión).
8. **Variante visual de modo oscuro** dedicada para el onboarding.
9. **Manejo diferenciado para primera apertura desde enlaces externos compartidos o notificaciones** (el enrutamiento previo desde enlaces compartidos o notificaciones hacia pantallas específicas queda fuera de esta entrega).

---

## 8. Criterios de Finalización (Definition of Done)

La entrega se considerará finalizada y verificada cuando se cumpla todo lo siguiente:

- [ ] Un usuario en instalación limpia y sin sesión activa visualiza el onboarding desde el paso 1 al abrir la aplicación por primera vez.
- [ ] Las cuatro pantallas muestran exactamente los títulos, descripciones, composiciones visuales, visibilidad condicional del botón de retroceso (oculto en paso 1, visible en pasos 2–4), botón *"Saltar"* visible en los cuatro pasos, indicador de progreso y etiquetas de acción definidos en RF-2.
- [ ] La navegación bidireccional funciona por deslizamiento horizontal, botones y acción *"Atrás"* del dispositivo, respetando los límites del paso 1 y paso 4, así como la protección ante toques rápidos o simultáneos.
- [ ] Las acciones *"Comenzar Ahora"* (paso 4), *"Saltar"* e *"¿Ya tienes una cuenta? Iniciar Sesión"* registran el onboarding como visto, reemplazan el historial de navegación del onboarding (impidiendo volver con *"Atrás"*) y dirigen a la pantalla de inicio de sesión.
- [ ] Al cerrar y volver a abrir la aplicación tras completar u omitir el onboarding —incluso después de cerrar sesión—, el onboarding ya no vuelve a mostrarse.
- [ ] Si el usuario cierra completamente la aplicación en cualquiera de los pasos (1 a 4) sin terminar ni omitir, el onboarding vuelve a mostrarse desde el paso 1 en la siguiente apertura; si solo la envía a segundo plano, conserva el paso actual al regresar.
- [ ] Un usuario existente con sesión activa al actualizar la app no ve el onboarding y tampoco lo ve si cierra sesión posteriormente.
- [ ] El flujo completo funciona sin conexión a internet, mantiene su identidad visual clara y legibilidad sin desbordamientos en pantallas móviles verticales de distintos tamaños y cumple los criterios básicos de accesibilidad (contraste, área táctil y etiquetas de lector de pantalla).
- [ ] Ante fallos internos de lectura o guardado del estado local, la aplicación no se cierra ni bloquea al usuario y aplica el comportamiento de respaldo definido en RF-8.
- [ ] Existe una suite de pruebas automatizadas que verifica los criterios de aceptación funcionales y los casos límite críticos, y se ejecuta completamente en verde sin regresiones.

---

## 9. Dudas Abiertas

No quedan dudas abiertas ni elementos pendientes marcados con `[NECESITA ACLARACIÓN]`. Todas las decisiones funcionales y de alcance del MVP han sido confirmadas y cerradas para pasar a la fase de planificación.
