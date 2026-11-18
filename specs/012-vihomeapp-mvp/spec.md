# Especificación: Rol Invitado, Exploración Pública y Acceso Inicial a Arriendos (MVP)

## 1. Contexto y Objetivo

### 1.1. Contexto
ViHome es una plataforma móvil inmobiliaria orientada a la búsqueda, arrendamiento, compra y exploración de proyectos de vivienda. Actualmente, una persona que termina la introducción inicial o abre la aplicación sin haber iniciado sesión es obligada a pasar por la pantalla de inicio de sesión o registro antes de poder ver cualquier inmueble disponible. Esta barrera temprana genera fricción para usuarios nuevos que desean conocer primero la oferta real de propiedades antes de crear una cuenta.

### 1.2. Objetivo
Habilitar el **rol invitado** en ViHome para que cualquier persona sin cuenta ni sesión activa pueda explorar libremente la oferta pública de **Arriendos**, **Ventas** y **Proyectos** desde el primer instante, cumpliendo los siguientes propósitos:

- Llevar al usuario directamente a la sección de **Arriendos** tanto al finalizar u omitir la pantalla de bienvenida inicial (onboarding) como en cada apertura posterior de la aplicación, eliminando la pantalla de acceso como barrera obligatoria de entrada.
- Permitir la navegación fluida y en modo de solo lectura por listados, filtros, mapa y detalles de propiedades y proyectos sin requerir registro previo.
- Proteger las funciones personales y transaccionales redirigiendo a la pantalla de inicio de sesión —con un aviso informativo contextual— únicamente cuando el usuario invitado demuestre intención activa (al navegar a **Perfil** o al intentar realizar una solicitud u otra acción interactiva dentro de los detalles).
- Ofrecer una experiencia coherente y sin bloqueos al cancelar el inicio de sesión, al autenticarse, al cerrar sesión, al eliminar una cuenta o ante sesiones expiradas.

### 1.3. Comportamientos Existentes Modificados y Compatibilidad
En cumplimiento de la Constitución del Proyecto (Sección 2.3), esta especificación identifica explícitamente los comportamientos previos del sistema que se actualizan y los que se preservan:

| Especificación previa | Comportamiento previo | Cambio en esta especificación (`012`) |
| :--- | :--- | :--- |
| **`011-vihomeapp-mvp` (`RF-1.2`, `RF-4.1`, `RF-5.1`, `RF-7.3`, `RF-8.1`, `RF-8.2`)** | Al completar u omitir el onboarding, reabrir sin sesión o cerrar sesión, la app dirigía a la pantalla de **inicio de sesión**. | Se actualiza el destino hacia la pantalla principal en **Arriendos** en **modo invitado**. Se preserva intacta la visualización única del onboarding, su enlace *"¿Ya tienes una cuenta? Iniciar Sesión"* hacia inicio de sesión, la prohibición de volver al onboarding con *"Atrás"* y la persistencia del estado visto tras cerrar sesión o eliminar cuenta. |
| **`010-account-deletion` (`RF-56`, `CA-4`)** | Al eliminar la cuenta exitosamente, la app limpiaba los datos, mostraba confirmación y redirigía a la pantalla de autenticación. | Se actualiza el destino final hacia **Arriendos** en **modo invitado**, **preservando** la limpieza integral de datos, el mensaje de confirmación exitosa y el manejo de fallo sin cerrar sesión (`RF-57`, `CA-5`). |
| **Navegación de usuarios autenticados** | Al iniciar la app con sesión activa se abría Arriendos y, si la app se abría desde una notificación push, se procesaba el destino de la notificación. | Se preserva íntegro para usuarios autenticados. El comportamiento de invitados aplica exclusivamente cuando no existe sesión activa. |

---

## 2. Perfiles de Usuario

| Perfil de usuario | Descripción | Necesidad principal |
| :--- | :--- | :--- |
| **Usuario invitado nuevo (tras onboarding)** | Persona que instala ViHome por primera vez, completa u omite la bienvenida inicial y aún no tiene cuenta. | Entrar de inmediato a ver propiedades en arriendo y explorar ventas y proyectos sin verse obligada a registrarse antes de conocer la oferta. |
| **Usuario invitado recurrente** | Persona que ya vio la bienvenida en una apertura anterior y vuelve a abrir la aplicación sin iniciar sesión. | Acceder directamente a la sección de Arriendos en cada apertura sin pasar obligatoriamente por el inicio de sesión. |
| **Usuario invitado con intención de acción** | Persona en modo invitado que decide acceder a su perfil o intentar solicitar/contactar una propiedad o proyecto de su interés. | Entender claramente por qué se le solicita autenticarse, poder iniciar sesión o registrarse con facilidad, o bien regresar a seguir explorando si cambia de opinión. |
| **Usuario autenticado que cierra sesión, elimina cuenta o pierde sesión** | Persona que tenía cuenta activa y cierra sesión, elimina su cuenta o abre la app con una sesión expirada o revocada. | Volver sin bloqueos a la sección de Arriendos en modo invitado y poder seguir explorando o iniciar sesión cuando lo desee. |
| **Usuario autenticado (arrendatario o arrendador)** | Persona con sesión válida activa en la plataforma. | Conservar acceso completo a todas las funcionalidades correspondientes a su rol (Perfil o Panel, solicitudes, notificaciones y gestión) iniciando en Arriendos al abrir la aplicación o autenticarse. |

---

## 3. Historias de Usuario

### HU-01: Rol Invitado (Navegación Pública, Acceso Inicial a Arriendos y Redirección a Inicio de Sesión)
**Como** usuario invitado (visitante sin cuenta ni sesión iniciada en ViHome),
**quiero** ingresar directamente a la sección de **Arriendos** al terminar la bienvenida inicial y cada vez que abra la aplicación, poder explorar libremente **Arriendos**, **Ventas** y **Proyectos** en modo de solo lectura, y ser redirigido a **inicio de sesión** con un aviso contextual únicamente cuando intente acceder a **Perfil** o ejecutar una solicitud u otra acción interactiva en los detalles,
**para** conocer la oferta inmobiliaria real sin barreras de entrada y decidir registrarme o iniciar sesión en el momento en que realmente desee interactuar.

---

## 4. Requisitos Funcionales (RF-x)

### RF-1: Navegación directa a Arriendos al finalizar el onboarding y en cada apertura
El sistema garantiza que la entrada habitual a la aplicación sea siempre la sección de **Arriendos**, eliminando el bloqueo obligatorio por inicio de sesión.

**Criterios de aceptación (EARS):**
- **RF-1.1:** CUANDO un usuario sin sesión activa finalice el onboarding pulsando *"Comenzar Ahora"* u omita el recorrido pulsando *"Saltar"*, el sistema DEBERÁ registrar que el onboarding ya fue visto y dirigir directamente al usuario a la pantalla principal con la sección de **Arriendos** activa en modo invitado, descartando el onboarding del historial de navegación.
- **RF-1.2:** SI ocurre un fallo interno al guardar que el onboarding fue visto tras pulsar *"Comenzar Ahora"* o *"Saltar"*, ENTONCES el sistema DEBERÁ evitar bloquear al usuario, descartar el onboarding del historial y dirigirlo igualmente a la sección de **Arriendos** en modo invitado.
- **RF-1.3:** CUANDO un usuario pulse el enlace *"¿Ya tienes una cuenta? Iniciar Sesión"* dentro del onboarding, el sistema DEBERÁ registrar que el onboarding ya fue visto, descartar el onboarding del historial y dirigir al usuario a la pantalla de inicio de sesión sin mostrar aviso de restricción de invitado.
- **RF-1.4:** CUANDO la aplicación finalice su carga inicial y exista registro de que el onboarding ya fue visto, el sistema DEBERÁ dirigir al usuario directamente a la pantalla principal con la sección de **Arriendos** activa (tanto si posee sesión autenticada como si ingresa en modo invitado), preservando el procesamiento posterior de notificaciones abiertas únicamente para usuarios autenticados.
- **RF-1.5:** SI durante la carga inicial la sesión de un usuario previamente autenticado se encuentra expirada o revocada, ENTONCES el sistema DEBERÁ activar el modo invitado y dirigir al usuario a la sección de **Arriendos** sin bloquear el acceso ni forzar el inicio de sesión.
- **RF-1.6:** SI durante la carga inicial falla la verificación de sesión por un error inesperado, ENTONCES el sistema DEBERÁ continuar en modo invitado hacia la sección de **Arriendos** (o hacia el onboarding si aún no ha sido visto) sin cerrar ni congelar la aplicación.
- **RF-1.7:** SI la sesión de un usuario autenticado expira o es revocada mientras navega activamente, ENTONCES el sistema DEBERÁ transicionar a modo invitado si se encuentra en una vista pública, o redirigir a la pantalla de inicio de sesión con un aviso informativo si intenta continuar en una vista o acción privada.

---

### RF-2: Acceso público del rol invitado a Arriendos, Ventas, Proyectos, Mapa y Detalles
El usuario invitado dispone de exploración libre y en modo de solo lectura sobre todo el catálogo inmobiliario público de la plataforma.

**Criterios de aceptación (EARS):**
- **RF-2.1:** MIENTRAS el usuario se encuentre en modo invitado, el sistema DEBERÁ permitirle navegar libremente entre las pestañas **Arriendos**, **Ventas** y **Proyectos** de la barra de navegación inferior.
- **RF-2.2:** MIENTRAS el usuario se encuentre en modo invitado en **Arriendos**, **Ventas** o **Proyectos**, el sistema DEBERÁ permitirle consultar los listados completos, aplicar búsquedas y filtros disponibles y abrir la vista de **Mapa** (incluyendo visualización y selección de marcadores y uso opcional de ubicación actual) sin exigir autenticación.
- **RF-2.3:** CUANDO un usuario invitado seleccione una propiedad (en arriendo o en venta) o un proyecto desde los listados o desde el mapa, el sistema DEBERÁ abrir la vista de **Detalle de la Propiedad** o **Detalle del Proyecto** en modo de solo lectura, permitiendo deslizar la galería de imágenes, recorrer el contenido descriptivo y consultar precio, características, ubicación visual e insignia resumida de reputación cuando esté disponible, sin errores por ausencia de cuenta.
- **RF-2.4:** MIENTRAS el usuario se encuentre en modo invitado en **Arriendos**, **Ventas** o **Proyectos**, el sistema DEBERÁ ocultar el ícono de notificaciones en la barra superior.
- **RF-2.5:** MIENTRAS el usuario se encuentre en modo invitado, el sistema DEBERÁ aplicar el comportamiento estándar de usuario sin suscripción activa para cualquier elemento condicionado a beneficios de suscripción.

---

### RF-3: Restricción y redirección a inicio de sesión al navegar a Perfil
La pestaña **Perfil** es exclusiva de usuarios registrados y actúa como punto de entrada hacia la autenticación para los invitados.

**Criterios de aceptación (EARS):**
- **RF-3.1:** CUANDO un usuario en modo invitado pulse la pestaña **Perfil** en la barra de navegación inferior, el sistema DEBERÁ interceptar la navegación sin mostrar la vista de perfil y redirigir al usuario a la pantalla de inicio de sesión.
- **RF-3.2:** CUANDO el sistema redirija a un usuario invitado a la pantalla de inicio de sesión desde la pestaña **Perfil**, el sistema DEBERÁ mostrar un aviso informativo contextual visible dentro de la pantalla de inicio de sesión indicando que necesita iniciar sesión o registrarse para acceder a su perfil.
- **RF-3.3:** CUANDO un usuario invitado sea redirigido desde la pestaña **Perfil**, el sistema DEBERÁ conservar como pestaña activa subyacente la sección pública desde la cual realizó la acción (**Arriendos**, **Ventas** o **Proyectos**), preservando su estado y evitando renderizar la vista de perfil.
- **RF-3.4:** CUANDO un usuario invitado pulse la pestaña **Perfil** de forma repetida o mediante doble toque rápido, el sistema DEBERÁ abrir una única instancia de la pantalla de inicio de sesión sin apilar pantallas duplicadas.

---

### RF-4: Restricción y redirección a inicio de sesión en acciones interactivas dentro de los Detalles
Dentro de las vistas de detalle de propiedades y proyectos, la consulta de información es libre, mientras que toda acción de solicitud, contacto o interacción externa requiere una cuenta autenticada.

**Criterios de aceptación (EARS):**
- **RF-4.1:** MIENTRAS un usuario invitado visualice el **Detalle de una Propiedad** o el **Detalle de un Proyecto**, el sistema DEBERÁ mantener visibles con su apariencia habitual los botones de acción disponibles (*"Solicitar Arriendo"* en propiedades en arriendo, *"Contactar por WhatsApp"* en propiedades, y *"Contactar"* en proyectos) para que las capacidades sean descubribles.
- **RF-4.2:** CUANDO un usuario invitado pulse el botón *"Solicitar Arriendo"* en el **Detalle de la Propiedad**, el sistema DEBERÁ redirigirlo a la pantalla de inicio de sesión mostrando un aviso informativo contextual indicando que requiere iniciar sesión para realizar una solicitud, sin mostrar diálogos de perfil incompleto ni abrir el formulario de solicitud.
- **RF-4.3:** CUANDO un usuario invitado pulse cualquier otra acción interactiva restringida dentro del **Detalle de la Propiedad** o del **Detalle del Proyecto** —específicamente: *"Contactar por WhatsApp"*, *"Contactar"* en proyecto, abrir el desglose detallado de reseñas/reputación del arrendador, pulsar *"Compartir"* o abrir la ubicación en aplicaciones de mapas externas—, el sistema DEBERÁ interceptar la acción sin ejecutarla y redirigirlo a la pantalla de inicio de sesión mostrando un aviso informativo contextual.
- **RF-4.4:** CUANDO un usuario invitado pulse de forma repetida o con doble toque rápido cualquiera de los botones restringidos en los detalles, el sistema DEBERÁ abrir una única instancia de la pantalla de inicio de sesión sin apilar pantallas duplicadas.

---

### RF-5: Protección de funcionalidades y pantallas privadas
Ninguna funcionalidad exclusiva de usuarios registrados puede ser accedida en modo invitado.

**Criterios de aceptación (EARS):**
- **RF-5.1:** CUANDO un usuario en modo invitado intente navegar directamente hacia cualquier pantalla o funcionalidad privada (creación o seguimiento de solicitudes, completar perfil, información personal, gestión de propiedades propias, panel de arrendador, centro de notificaciones o suscripciones), el sistema DEBERÁ bloquear el acceso y redirigir a la pantalla de inicio de sesión mostrando un aviso informativo contextual.

---

### RF-6: Salida desde la pantalla de inicio de sesión y regreso al modo invitado
Un usuario invitado que llega a la pantalla de inicio de sesión nunca queda atrapado en ella si decide no autenticarse todavía.

**Criterios de aceptación (EARS):**
- **RF-6.1:** MIENTRAS un usuario no autenticado visualice la pantalla de inicio de sesión, el sistema DEBERÁ mostrar un botón explícito *"Continuar como invitado"* accesible y visible sin requerir registro.
- **RF-6.2:** CUANDO un usuario invitado pulse *"Continuar como invitado"* o utilice el control/acción *"Atrás"* desde la pantalla de inicio de sesión habiendo llegado desde la exploración pública (Arriendos, Ventas, Proyectos o un Detalle), el sistema DEBERÁ devolverlo a la vista pública exacta anterior preservando su contexto de exploración (pestaña activa, filtros y desplazamiento cuando la vista siga en el historial).
- **RF-6.3:** CUANDO un usuario no autenticado pulse *"Continuar como invitado"* o utilice el control/acción *"Atrás"* desde la pantalla de inicio de sesión sin existir una vista pública previa en el historial (por ejemplo, al llegar desde el enlace *"Iniciar Sesión"* del onboarding), el sistema DEBERÁ dirigirlo a la pantalla principal en la sección de **Arriendos** en modo invitado, impidiendo regresar al onboarding.
- **RF-6.4:** CUANDO un usuario invitado navegue desde inicio de sesión hacia la pantalla de registro y decida cancelar o volver atrás, el sistema DEBERÁ permitirle regresar a inicio de sesión y desde allí continuar como invitado sin quedar bloqueado.
- **RF-6.5:** SI un usuario invitado realiza uno o más intentos fallidos de inicio de sesión (credenciales incorrectas, cancelación de proveedor externo o fallo de red) o abre la recuperación externa de contraseña, ENTONCES el sistema DEBERÁ mostrar el error correspondiente sin perder la capacidad de regresar a la vista pública anterior mediante *"Continuar como invitado"* o *"Atrás"*.

---

### RF-7: Transición a usuario autenticado y retorno a modo invitado al cerrar sesión o eliminar cuenta
El cambio de estado entre invitado y usuario registrado es inmediato, limpio y predecible.

**Criterios de aceptación (EARS):**
- **RF-7.1:** CUANDO un usuario invitado complete exitosamente el inicio de sesión (con correo/contraseña o proveedor externo) o el registro de una nueva cuenta, el sistema DEBERÁ finalizar el modo invitado y habilitar de inmediato los permisos de su rol registrado (arrendatario o arrendador, incluyendo acceso a Perfil o Panel, notificaciones y solicitudes).
- **RF-7.2:** CUANDO un usuario invitado complete exitosamente el inicio de sesión o el registro, el sistema DEBERÁ dirigir siempre al usuario a la pantalla principal en la sección de **Arriendos**, limpiando la pila previa de redirección.
- **RF-7.3:** CUANDO un usuario autenticado cierre sesión exitosamente (o aunque falle la notificación remota de cierre de sesión por falta de red), el sistema DEBERÁ limpiar los datos privados de la sesión anterior, revertir la cuarta pestaña a **Perfil**, ocultar el ícono de notificaciones, conservar el onboarding como visto y dirigir directamente al usuario a la sección de **Arriendos** en modo invitado.
- **RF-7.4:** CUANDO un usuario autenticado elimine su cuenta exitosamente, el sistema DEBERÁ limpiar los datos privados de la sesión, conservar el onboarding como visto, dirigir directamente al usuario a la sección de **Arriendos** en modo invitado y mostrar el mensaje de confirmación de cuenta eliminada.
- **RF-7.5:** SI falla la eliminación de cuenta por error de red o servicio, ENTONCES el sistema DEBERÁ mantener intacta la sesión del usuario autenticado y mostrar un mensaje de error con opción de reintentar (en consistencia con `010-account-deletion`).

---

### RF-8: Resiliencia ante errores de red, permisos denegados y datos incompletos en vistas públicas
Los fallos de conectividad, permisos del dispositivo o datos incompletos en vistas públicas nunca se confunden con falta de autenticación ni provocan cierres inesperados.

**Criterios de aceptación (EARS):**
- **RF-8.1:** SI un usuario invitado intenta cargar listados, búsquedas, mapa o detalles de propiedades y proyectos sin conexión a internet o ante un fallo del servidor, ENTONCES el sistema DEBERÁ mostrar el estado de error o sin conexión correspondiente con opción de reintentar en la pantalla actual, sin redirigirlo a inicio de sesión.
- **RF-8.2:** SI un usuario invitado deniega los permisos de ubicación del dispositivo al utilizar la vista de **Mapa**, ENTONCES el sistema DEBERÁ mostrar un aviso comprensible y permitir continuar explorando el mapa en una ubicación predeterminada, sin redirigirlo a inicio de sesión ni bloquear la vista.
- **RF-8.3:** SI el servicio de datos rechaza una lectura pública por permisos insuficientes de configuración, ENTONCES el sistema DEBERÁ mostrar un estado de error comprensible con opción de reintentar y sin cerrar la aplicación.
- **RF-8.4:** SI una propiedad o proyecto consultado por un usuario invitado presenta datos incompletos (ausencia de imágenes, descripción vacía, ausencia de reputación del arrendador o fallo parcial al cargar datos complementarios) o deja de estar disponible, ENTONCES el sistema DEBERÁ presentar respaldos visuales seguros o un mensaje comprensible de contenido no disponible sin cierres inesperados ni redirecciones erróneas a inicio de sesión.

---

## 5. Requisitos No Funcionales (RNF-x)

- **RNF-1 — Estabilidad y tolerancia a ausencia de sesión:** Todas las pantallas públicas y controles compartidos DEBERÁN operar con cero excepciones ni errores visuales cuando no exista una cuenta de usuario asociada.
- **RNF-2 — Seguridad y aislamiento de datos:** Un usuario invitado únicamente podrá consultar información marcada como pública (catálogo de arriendos, ventas, proyectos y datos públicos de sus vistas de detalle); el sistema DEBERÁ impedir cualquier lectura o escritura de datos privados de cuentas, solicitudes o perfiles personales sin sesión válida.
- **RNF-3 — Fluidez de transición:** El cambio entre pestañas públicas, la redirección a inicio de sesión con su aviso informativo contextual y el regreso a modo invitado DEBERÁN completarse en menos de **350 milisegundos** tras la interacción del usuario, sin pantallas intermedias parpadeantes ni bloqueos perceptibles.
- **RNF-4 — Claridad y consistencia de mensajes:** Todos los avisos informativos contextuales mostrados en inicio de sesión y el botón *"Continuar como invitado"* DEBERÁN redactarse en español neutro, claro, no técnico y coherente con la identidad visual de ViHome.
- **RNF-5 — Accesibilidad y adaptabilidad visual:** El botón *"Continuar como invitado"*, el control de retroceso y el banner de aviso informativo DEBERÁN mantener relación de contraste mínima de 4.5:1 (nivel AA), área táctil mínima de **48 × 48 puntos táctiles**, etiquetas comprensibles para lectores de pantalla y adaptación sin recortes ni solapamientos en pantallas compactas, con texto escalado al máximo y con el teclado virtual desplegado.

---

## 6. Casos Límite y Excepciones

| Caso límite / Excepción | Comportamiento esperado |
| :--- | :--- |
| **Primera apertura tras instalación limpia (con o sin conexión)** | Se muestra el onboarding. Al pulsar *"Comenzar Ahora"* o *"Saltar"*, se guarda como visto (si falla el guardado, continúa sin bloquear) y entra directamente a **Arriendos** en modo invitado; si no hay conexión, Arriendos muestra el estado sin conexión con reintento. Si pulsa *"Iniciar Sesión"*, guarda como visto y abre inicio de sesión sin aviso de restricción. |
| **Aperturas subsecuentes sin sesión iniciada** | Tras la carga inicial se omite tanto el onboarding como el inicio de sesión, abriendo directamente **Arriendos** en modo invitado. |
| **Sesión expirada, revocada o fallo al verificar sesión al arrancar** | La aplicación ingresa automáticamente a **Arriendos** en modo invitado sin bloquear al usuario; solicitará iniciar sesión solo al pulsar Perfil o una acción restringida. |
| **Sesión expirada durante navegación activa** | En vistas públicas pasa a modo invitado sin interrupción abrupta; al intentar una acción o vista privada redirige a inicio de sesión con aviso informativo. |
| **Doble toque rápido en Perfil o en botones restringidos de Detalles** | Se abre una única pantalla de inicio de sesión con su aviso contextual, sin apilar pantallas duplicadas. |
| **Invitado pulsa *"Solicitar Arriendo"* en detalle de propiedad** | Redirige a inicio de sesión con aviso contextual de solicitud; nunca valida perfil verificado ni muestra diálogo de *"Perfil incompleto"*. |
| **Invitado pulsa *"Contactar por WhatsApp"*, *"Contactar"* (proyecto), reseñas detalladas, *"Compartir"* o mapa externo** | Intercepta la acción sin abrir apps externas ni hojas de reseñas y redirige a inicio de sesión con aviso contextual. |
| **Invitado regresa sin autenticarse tras uno o varios intentos fallidos de login o tras recuperar contraseña** | Los errores de autenticación se muestran sin romper el historial; *"Continuar como invitado"* y *"Atrás"* devuelven a la vista pública exacta anterior (Detalle o pestaña pública, conservando filtros y desplazamiento si sigue activa). |
| **Invitado regresa sin autenticarse habiendo llegado desde el enlace *"Iniciar Sesión"* del onboarding** | Tanto *"Continuar como invitado"* como *"Atrás"* dirigen a **Arriendos** en modo invitado (nunca regresa al onboarding). |
| **Aplicación enviada a segundo plano estando en inicio de sesión como invitado** | Al reanudar la aplicación (sin cierre del sistema operativo), conserva la pantalla de inicio de sesión y el punto de retorno a la vista pública anterior. |
| **Invitado inicia sesión o se registra tras ser redirigido desde Perfil o Detalles** | Adquiere los permisos de su rol (arrendatario o arrendador), aparece el ícono de notificaciones y navega siempre a **Arriendos** (no retoma automáticamente la pantalla anterior). |
| **Arrendador o arrendatario cierra sesión o elimina su cuenta exitosamente** | Se limpian todos los datos privados de la sesión activa, el ícono de notificaciones desaparece, la cuarta pestaña muestra **Perfil**, el onboarding no reaparece y dirige a **Arriendos** en modo invitado (en eliminación de cuenta se muestra además el mensaje de confirmación). |
| **Fallo de red durante cierre de sesión vs. eliminación de cuenta** | En cierre de sesión se limpia el estado local y pasa a modo invitado en Arriendos; en eliminación de cuenta se preserva la sesión activa y se informa el error con reintento. |
| **Invitado sin conexión, fallo parcial de carga, datos incompletos o permisos de ubicación denegados en Mapa** | Muestra retroalimentación comprensible con respaldo o reintento en la vista actual; nunca cierra la app ni redirige a inicio de sesión. |
| **Teclado virtual abierto o texto escalado al máximo en inicio de sesión** | El aviso informativo y el botón *"Continuar como invitado"* permanecen visibles y desplazables sin recortes ni solapamientos. |

---

## 7. Fuera de Alcance

Quedan explícitamente excluidos de este MVP:

1. **Retomar automáticamente la pantalla o acción pendiente tras autenticarse** (por ejemplo, abrir directamente el formulario de solicitud de la propiedad que estaba viendo o aterrizar en la pestaña Perfil; tras iniciar sesión o registrarse siempre se dirige a Arriendos).
2. **Límites de visualización para invitados** (no existe tope de propiedades o proyectos consultados antes de exigir registro).
3. **Persistencia o migración de actividad del invitado** (no se guardan favoritos, búsquedas recientes ni filtros temporales para transferirlos al crear una cuenta).
4. **Banners promocionales de registro dentro de los listados** o una experiencia publicitaria diferenciada para el rol invitado.
5. **Notificaciones push personalizadas** dirigidas a usuarios en modo invitado.
6. **Instrumentación de analítica de conversión** por punto de redirección de invitados.
7. **Soporte multilenguaje** (esta entrega cubre únicamente español).

---

## 8. Criterios de Finalización (Definition of Done)

La entrega se considerará finalizada y verificada cuando se cumpla todo lo siguiente:

- [ ] **Onboarding y arranque (`RF-1.1`–`RF-1.7`):** Completar u omitir el onboarding (incluso ante fallo de guardado) y cada inicio posterior con onboarding visto —incluyendo sesión expirada/revocada o fallo de verificación— dirigen siempre a **Arriendos** en modo invitado; el enlace *"Iniciar Sesión"* del onboarding dirige a inicio de sesión sin aviso de restricción; usuarios autenticados conservan su entrada normal y notificaciones.
- [ ] **Exploración pública (`RF-2.1`–`RF-2.5`):** Un invitado navega sin errores por **Arriendos**, **Ventas**, **Proyectos**, búsqueda, filtros, **Mapa**, **Detalle de Propiedad** y **Detalle de Proyecto** en modo solo lectura, con el ícono de notificaciones oculto.
- [ ] **Redirección desde Perfil (`RF-3.1`–`RF-3.4`):** Pulsar **Perfil** como invitado intercepta la navegación, conserva la pestaña pública subyacente, previene duplicados por doble toque y redirige a inicio de sesión con aviso contextual.
- [ ] **Redirección desde Detalles (`RF-4.1`–`RF-4.4`):** Los botones principales son visibles y pulsar *"Solicitar Arriendo"*, *"Contactar por WhatsApp"*, *"Contactar"* (proyecto), reseñas detalladas, *"Compartir"* o mapa externo redirige a inicio de sesión con aviso contextual sin duplicados ni diálogos de perfil incompleto.
- [ ] **Protección de rutas privadas (`RF-5.1`, `RNF-2`):** Todo acceso directo a pantallas o datos privados sin sesión es bloqueado y redirigido a inicio de sesión, garantizando aislamiento de datos privados.
- [ ] **Salida de inicio de sesión (`RF-6.1`–`RF-6.5`):** El botón *"Continuar como invitado"* y la acción *"Atrás"* regresan a la vista pública anterior (o a Arriendos si se llegó desde onboarding), incluso tras cancelar registro, fallos de inicio de sesión o recuperación de contraseña.
- [ ] **Transiciones de sesión (`RF-7.1`–`RF-7.5`):** Iniciar sesión/registrarse habilita permisos de rol y navega siempre a **Arriendos**; cerrar sesión y eliminar cuenta limpian datos privados, restauran la pestaña **Perfil**, ocultan notificaciones, mantienen el onboarding como visto y dirigen a **Arriendos** en modo invitado (preservando confirmación de borrado y manejo de error de `010-account-deletion`).
- [ ] **Resiliencia (`RF-8.1`–`RF-8.4`, `RNF-1`):** Sin conexión, errores de servidor, permisos de ubicación denegados en Mapa, fallos parciales y datos incompletos muestran respaldos claros con reintento sin redirigir a inicio de sesión ni cerrar la app.
- [ ] **Calidad y accesibilidad (`RNF-3`–`RNF-5`):** Transiciones `< 350 ms`, mensajes en español neutro, contraste >= 4.5:1, áreas táctiles >= 48 × 48, etiquetas de lector de pantalla y layout sin desbordamientos con teclado virtual y texto escalado.
- [ ] **Verificación automatizada (Constitución 2.3):** Suite completa de pruebas automatizadas en verde cubriendo todos los `RF-1`..`RF-8`, `RNF-1`..`RNF-5` y la compatibilidad actualizada de `011-vihomeapp-mvp` y `010-account-deletion`.

---

## 9. Dudas Abiertas

No quedan dudas abiertas ni elementos pendientes marcados con `[NECESITA ACLARACIÓN]`. Todos los hallazgos de revisión QA, compatibilidad con especificaciones previas (`011-vihomeapp-mvp` y `010-account-deletion`), casos límite y requisitos de la Constitución han sido resueltos.
